package com.floppyswing.floppy_swing

import android.media.Image
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Encodes RGBA frames rendered by the game into an H.264 MP4 for the share
 * button. Channel: `floppy_swing/video` with `start`, `frame`, `finish` and
 * `cancel`. Work happens on a background thread.
 */
class VideoEncoderPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var encoder: VideoEncoder? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "floppy_swing/video")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        executor.execute { encoder?.release() }
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> run(result) {
                encoder?.release()
                encoder = VideoEncoder(
                    call.argument<String>("path")!!,
                    call.argument<Int>("width")!!,
                    call.argument<Int>("height")!!,
                    call.argument<Int>("fps")!!,
                )
                null
            }
            "frame" -> run(result) {
                val enc = encoder ?: throw IllegalStateException("Encoder not started")
                enc.addFrame(call.arguments as ByteArray)
                null
            }
            "finish" -> run(result) {
                val enc = encoder ?: throw IllegalStateException("Encoder not started")
                encoder = null
                enc.finish()
                enc.path
            }
            "cancel" -> run(result) {
                encoder?.release()
                encoder = null
                null
            }
            else -> result.notImplemented()
        }
    }

    private fun run(result: MethodChannel.Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("encoder", e.message, null) }
            }
        }
    }
}

private class VideoEncoder(val path: String, private val width: Int, private val height: Int, private val fps: Int) {
    private val codec: MediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
    private val muxer = MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
    private val info = MediaCodec.BufferInfo()
    private var track = -1
    private var muxerStarted = false
    private var frameIndex = 0L
    private var released = false

    init {
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible,
            )
            setInteger(MediaFormat.KEY_BIT_RATE, 6_000_000)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        codec.start()
    }

    private fun ptsUs(index: Long) = index * 1_000_000L / fps

    fun addFrame(rgba: ByteArray) {
        val index = dequeueInput()
        val image = codec.getInputImage(index) ?: throw IllegalStateException("No input image")
        writeYuv(image, rgba)
        codec.queueInputBuffer(index, 0, width * height * 3 / 2, ptsUs(frameIndex), 0)
        frameIndex++
        drain(false)
    }

    fun finish() {
        val index = dequeueInput()
        codec.queueInputBuffer(index, 0, 0, ptsUs(frameIndex), MediaCodec.BUFFER_FLAG_END_OF_STREAM)
        drain(true)
        release()
    }

    fun release() {
        if (released) return
        released = true
        try { codec.stop() } catch (_: Exception) {}
        codec.release()
        try { if (muxerStarted) muxer.stop() } catch (_: Exception) {}
        muxer.release()
    }

    private fun dequeueInput(): Int {
        while (true) {
            val index = codec.dequeueInputBuffer(10_000)
            if (index >= 0) return index
            drain(false)
        }
    }

    private fun drain(endOfStream: Boolean) {
        while (true) {
            val index = codec.dequeueOutputBuffer(info, 10_000)
            when {
                index == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!endOfStream) return
                index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    track = muxer.addTrack(codec.outputFormat)
                    muxer.start()
                    muxerStarted = true
                }
                index >= 0 -> {
                    val buffer = codec.getOutputBuffer(index)!!
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) info.size = 0
                    if (info.size > 0 && muxerStarted) {
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        muxer.writeSampleData(track, buffer, info)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                }
            }
        }
    }

    /** RGBA -> YUV 4:2:0 (BT.601), honouring the codec's plane layout. */
    private fun writeYuv(image: Image, rgba: ByteArray) {
        val planes = image.planes
        val y = planes[0].buffer
        val yRow = planes[0].rowStride
        val yPix = planes[0].pixelStride
        val u = planes[1].buffer
        val v = planes[2].buffer
        val uvRow = planes[1].rowStride
        val uvPix = planes[1].pixelStride
        for (row in 0 until height) {
            var src = row * width * 4
            val yBase = row * yRow
            val chromaRow = row % 2 == 0
            val uvBase = (row / 2) * uvRow
            for (col in 0 until width) {
                val r = rgba[src].toInt() and 0xFF
                val g = rgba[src + 1].toInt() and 0xFF
                val b = rgba[src + 2].toInt() and 0xFF
                src += 4
                y.put(yBase + col * yPix, (((66 * r + 129 * g + 25 * b + 128) shr 8) + 16).toByte())
                if (chromaRow && col % 2 == 0) {
                    val off = uvBase + (col / 2) * uvPix
                    u.put(off, (((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128).toByte())
                    v.put(off, (((112 * r - 94 * g - 18 * b + 128) shr 8) + 128).toByte())
                }
            }
        }
    }
}
