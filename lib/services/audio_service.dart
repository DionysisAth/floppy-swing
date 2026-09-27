import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../game/game_controller.dart';
import '../game/simulation.dart';
import '../game/skins.dart';
import 'progress.dart';

/// Sound effects, music and haptics. Also the game's [GameFeedback] sink.
///
/// All sounds are generated WAVs in `assets/audio/` (see
/// `tool/gen_audio.py`), so there are no third-party audio licences.
///
/// Every sound gets a small, fixed pool of pre-loaded players that are reused
/// round-robin. Creating a player per effect (what `FlameAudio.play` does)
/// leaks a native player each time and makes the game slow down the longer
/// you play.
class AudioService with WidgetsBindingObserver implements GameFeedback {
  AudioService(this.progress);

  final ProgressStore progress;
  bool _ready = false;
  final Map<String, DateTime> _lastPlayed = {};
  final Map<String, List<AudioPlayer>> _pools = {};
  final Map<String, int> _nextVoice = {};

  AudioPlayer? _music;

  /// Whether the app wants music (menus/game are showing and not muted).
  bool _musicWanted = false;
  bool _musicPlaying = false;
  bool _inForeground = true;

  /// Sound file -> how many can overlap. Frequent sounds get more voices.
  static const sfx = {
    'thwip.wav': 3,
    'whoosh.wav': 3,
    'coin.wav': 4,
    'bonk.wav': 3,
    'bonk_big.wav': 2,
    'squeak.wav': 2,
    'clang.wav': 2,
    'whistle.wav': 2,
    'boing.wav': 2,
    'zing.wav': 1,
    'yelp.wav': 1,
    'win.wav': 1,
    'ding.wav': 3,
    'pop.wav': 3,
    'blip.wav': 2,
    'slowmo.wav': 1,
    'click.wav': 2,
    'buy.wav': 1,
    'shatter.wav': 2,
    'crumble.wav': 2,
    'rocket.wav': 2,
    'boom.wav': 2,
    'flip.wav': 2,
  };
  static const music = 'music.wav';

  /// Each world has its own soundtrack.
  static String trackFor(int world) => switch (world) {
    2 => 'music_factory.wav',
    3 => 'music_city.wav',
    4 => 'music_sky.wav',
    5 => 'music_base.wav',
    _ => music,
  };

  String _track = music;

  /// Music player calls run one at a time, in order, so a track change can't
  /// race a pause or resume.
  Future<void> _musicOps = Future.value();

  void _queueMusic(Future<void> Function() op) {
    _musicOps = _musicOps.then((_) => op()).catchError((_) {});
  }

  /// Sound effects mix with the music and never grab audio focus, so a
  /// "bonk" can't pause the soundtrack (or another app's audio).
  static final _context = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

  Future<void> init() async {
    try {
      for (final entry in sfx.entries) {
        final voices = <AudioPlayer>[];
        for (var i = 0; i < entry.value; i++) {
          final p = AudioPlayer(playerId: 'sfx_${entry.key}_$i');
          await p.setAudioContext(_context);
          await p.setPlayerMode(PlayerMode.lowLatency);
          await p.setReleaseMode(ReleaseMode.stop);
          await p.setSource(AssetSource('audio/${entry.key}'));
          voices.add(p);
        }
        _pools[entry.key] = voices;
      }
      final m = AudioPlayer(playerId: 'music');
      await m.setAudioContext(_context);
      await m.setReleaseMode(ReleaseMode.loop);
      await m.setSource(AssetSource('audio/$_track'));
      _music = m;
      WidgetsBinding.instance.addObserver(this);
      _ready = true;
    } catch (e) {
      debugPrint('Audio disabled: $e');
    }
  }

  // --------------------------------------------------------------- effects

  void play(String name, {double volume = 1, double minGap = 0.04}) {
    final v = progress.sfxVolume * volume;
    if (!_ready || !_inForeground || v <= 0.01) return;
    final voices = _pools[name];
    if (voices == null || voices.isEmpty) return;
    // Avoid machine-gunning the same sample in one frame.
    final now = DateTime.now();
    final last = _lastPlayed[name];
    if (last != null && now.difference(last).inMilliseconds < minGap * 1000) return;
    _lastPlayed[name] = now;
    final i = (_nextVoice[name] ?? 0) % voices.length;
    _nextVoice[name] = i + 1;
    unawaited(_restart(voices[i], v.clamp(0.0, 1.0)));
  }

  Future<void> _restart(AudioPlayer p, double volume) async {
    try {
      // Stop first: low-latency players don't report completion, so resume()
      // alone would do nothing once a sound has played through.
      await p.stop();
      await p.setVolume(volume);
      await p.resume();
    } catch (_) {
      // A missed sound effect is never worth crashing over.
    }
  }

  void click() => play('click.wav', volume: 0.6);

  // ----------------------------------------------------------------- music

  /// Starts (or re-applies the volume of) the background music, switching
  /// to [world]'s track when given.
  void startMusic({int? world}) {
    _musicWanted = true;
    if (world != null) _setTrack(trackFor(world));
    _syncMusic();
  }

  void _setTrack(String name) {
    final m = _music;
    if (name == _track) return;
    _track = name;
    if (!_ready || m == null) return;
    _musicPlaying = false;
    _queueMusic(() async {
      await m.stop();
      await m.setSource(AssetSource('audio/$name'));
    });
  }

  void stopMusic() {
    _musicWanted = false;
    _syncMusic();
  }

  void _syncMusic() {
    final m = _music;
    if (!_ready || m == null) return;
    final v = progress.musicVolume;
    final shouldPlay = _musicWanted && _inForeground && v > 0.01;
    if (shouldPlay) {
      final resume = !_musicPlaying;
      _musicPlaying = true;
      _queueMusic(() async {
        await m.setVolume(v);
        if (resume) await m.resume();
      });
    } else if (_musicPlaying) {
      _musicPlaying = false;
      _queueMusic(m.pause);
    }
  }

  /// Pause everything when the app leaves the screen (home button, app
  /// switcher, phone call) and pick the music back up on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _inForeground) return;
    _inForeground = foreground;
    if (!foreground) {
      for (final voices in _pools.values) {
        for (final p in voices) {
          unawaited(p.stop().catchError((_) {}));
        }
      }
    }
    _syncMusic();
  }

  // ------------------------------------------------------------- haptics

  void _haptic(Future<void> Function() fn) {
    if (progress.haptics) unawaited(fn().then((_) {}, onError: (_) {}));
  }

  // ------------------------------------------------------------ feedback

  @override
  void onEvent(SimEvent e, Skin skin) {
    switch (e.kind) {
      case EventKind.grab:
        play('thwip.wav');
        _haptic(HapticFeedback.selectionClick);
      case EventKind.launch:
        play('whoosh.wav');
        play('boing.wav', volume: 0.5);
        _haptic(HapticFeedback.mediumImpact);
      case EventKind.release:
        play('whoosh.wav', volume: 0.7);
      case EventKind.miss:
        play('blip.wav', volume: 0.5);
      case EventKind.coin:
        play('coin.wav', volume: 0.8, minGap: 0.02);
      case EventKind.checkpoint:
        play('ding.wav');
        _haptic(HapticFeedback.mediumImpact);
      case EventKind.bounce:
        play('boing.wav');
        _haptic(HapticFeedback.mediumImpact);
      case EventKind.bonk:
        final big = e.value > 11;
        play(big ? 'bonk_big.wav' : 'bonk.wav', volume: (e.value / 12).clamp(0.4, 1.0), minGap: 0.08);
        if (big) _haptic(HapticFeedback.lightImpact);
      case EventKind.death:
        final cause = DeathCause.values[e.value.toInt()];
        if (cause == DeathCause.saw) play('zing.wav');
        play('${skin.failSound}.wav');
        play('yelp.wav', volume: 0.8);
        _haptic(HapticFeedback.heavyImpact);
      case EventKind.finish:
        play('win.wav');
        _haptic(HapticFeedback.mediumImpact);
      case EventKind.style:
        play('pop.wav', volume: 0.7);
      case EventKind.shatter:
        play('shatter.wav');
        _haptic(HapticFeedback.mediumImpact);
      case EventKind.crumble:
        play('crumble.wav', volume: e.label == 'fall' ? 1.0 : 0.5);
      case EventKind.rocket:
        play('rocket.wav', volume: 0.6);
      case EventKind.boom:
        play('boom.wav', volume: e.label == 'hit' ? 1.0 : 0.5);
        if (e.label == 'hit') _haptic(HapticFeedback.heavyImpact);
      case EventKind.flip:
        play('flip.wav', volume: 0.7);
    }
  }

  @override
  void onReplayStart(Skin skin) {
    play('slowmo.wav', volume: 0.8);
    // The punchline gets a second, slow-motion helping.
    Future<void>.delayed(const Duration(milliseconds: 750), () => play('${skin.failSound}.wav', volume: 0.8));
  }
}
