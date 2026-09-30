import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "VideoEncoderPlugin") {
      VideoEncoderPlugin.register(with: registrar)
    }
  }
}

/// Encodes RGBA frames rendered by the game into an H.264 MP4 for the share
/// button. Channel: `floppy_swing/video` with `start`, `frame`, `finish` and
/// `cancel`.
class VideoEncoderPlugin: NSObject, FlutterPlugin {
  private let queue = DispatchQueue(label: "floppy_swing.video")
  private var writer: AVAssetWriter?
  private var input: AVAssetWriterInput?
  private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
  private var path = ""
  private var width = 0
  private var height = 0
  private var fps: Int32 = 30
  private var frameIndex: Int64 = 0

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "floppy_swing/video", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(VideoEncoderPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    queue.async {
      do {
        switch call.method {
        case "start":
          let args = call.arguments as! [String: Any]
          try self.start(
            path: args["path"] as! String,
            width: args["width"] as! Int,
            height: args["height"] as! Int,
            fps: args["fps"] as! Int)
          DispatchQueue.main.async { result(nil) }
        case "frame":
          let data = (call.arguments as! FlutterStandardTypedData).data
          try self.addFrame(data)
          DispatchQueue.main.async { result(nil) }
        case "finish":
          self.finish { path in DispatchQueue.main.async { result(path) } }
        case "cancel":
          self.cancel()
          DispatchQueue.main.async { result(nil) }
        default:
          DispatchQueue.main.async { result(FlutterMethodNotImplemented) }
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "encoder", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private func start(path: String, width: Int, height: Int, fps: Int) throws {
    cancel()
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: width,
      AVVideoHeightKey: height,
      AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 6_000_000],
    ])
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ])
    writer.add(input)
    guard writer.startWriting() else {
      throw writer.error ?? NSError(domain: "encoder", code: 1)
    }
    writer.startSession(atSourceTime: .zero)
    self.writer = writer
    self.input = input
    self.adaptor = adaptor
    self.path = path
    self.width = width
    self.height = height
    self.fps = Int32(fps)
    self.frameIndex = 0
  }

  private func addFrame(_ rgba: Data) throws {
    guard let input = input, let adaptor = adaptor, let pool = adaptor.pixelBufferPool else {
      throw NSError(domain: "encoder", code: 2, userInfo: [NSLocalizedDescriptionKey: "Encoder not started"])
    }
    while !input.isReadyForMoreMediaData { usleep(2000) }
    var buffer: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    guard let pb = buffer else {
      throw NSError(domain: "encoder", code: 3, userInfo: [NSLocalizedDescriptionKey: "No pixel buffer"])
    }
    CVPixelBufferLockBaseAddress(pb, [])
    let dst = CVPixelBufferGetBaseAddress(pb)!.assumingMemoryBound(to: UInt8.self)
    let dstRow = CVPixelBufferGetBytesPerRow(pb)
    rgba.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
      let src = raw.bindMemory(to: UInt8.self).baseAddress!
      for y in 0..<height {
        let s = src + y * width * 4
        let d = dst + y * dstRow
        for x in 0..<width {
          let i = x * 4
          d[i] = s[i + 2]      // B
          d[i + 1] = s[i + 1]  // G
          d[i + 2] = s[i]      // R
          d[i + 3] = s[i + 3]  // A
        }
      }
    }
    CVPixelBufferUnlockBaseAddress(pb, [])
    adaptor.append(pb, withPresentationTime: CMTime(value: frameIndex, timescale: fps))
    frameIndex += 1
  }

  private func finish(_ done: @escaping (String?) -> Void) {
    guard let writer = writer, let input = input else {
      done(nil)
      return
    }
    input.markAsFinished()
    let path = self.path
    writer.finishWriting { done(writer.status == .completed ? path : nil) }
    self.writer = nil
    self.input = nil
    self.adaptor = nil
  }

  private func cancel() {
    writer?.cancelWriting()
    writer = nil
    input = nil
    adaptor = nil
  }
}
