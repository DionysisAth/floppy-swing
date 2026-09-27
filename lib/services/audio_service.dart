import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import '../game/simulation.dart';
import '../game/skins.dart';
import 'progress.dart';

/// Sound effects, music and haptics. Also the game's [GameFeedback] sink.
///
/// All sounds are generated WAVs in `assets/audio/` (see
/// `tool/gen_audio.py`), so there are no third-party audio licences.
class AudioService implements GameFeedback {
  AudioService(this.progress);

  final ProgressStore progress;
  bool _ready = false;
  bool _musicPlaying = false;
  final Map<String, DateTime> _lastPlayed = {};

  static const sfx = [
    'thwip.wav',
    'whoosh.wav',
    'coin.wav',
    'bonk.wav',
    'bonk_big.wav',
    'squeak.wav',
    'clang.wav',
    'whistle.wav',
    'boing.wav',
    'zing.wav',
    'yelp.wav',
    'win.wav',
    'ding.wav',
    'pop.wav',
    'blip.wav',
    'slowmo.wav',
    'click.wav',
    'buy.wav',
  ];
  static const music = 'music.wav';

  Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll([...sfx, music]);
      FlameAudio.bgm.initialize();
      _ready = true;
    } catch (e) {
      debugPrint('Audio disabled: $e');
    }
  }

  void play(String name, {double volume = 1, double minGap = 0.04}) {
    final v = progress.sfxVolume * volume;
    if (!_ready || v <= 0.01) return;
    // Avoid machine-gunning the same sample in one frame.
    final now = DateTime.now();
    final last = _lastPlayed[name];
    if (last != null && now.difference(last).inMilliseconds < minGap * 1000) return;
    _lastPlayed[name] = now;
    unawaited(FlameAudio.play(name, volume: v.clamp(0.0, 1.0)).then((_) {}, onError: (_) {}));
  }

  void click() => play('click.wav', volume: 0.6);

  void startMusic() {
    if (!_ready) return;
    final v = progress.musicVolume;
    if (v <= 0.01) {
      stopMusic();
      return;
    }
    if (_musicPlaying) {
      FlameAudio.bgm.audioPlayer.setVolume(v);
      return;
    }
    _musicPlaying = true;
    unawaited(FlameAudio.bgm.play(music, volume: v).then((_) {}, onError: (_) {}));
  }

  void stopMusic() {
    if (!_musicPlaying) return;
    _musicPlaying = false;
    unawaited(FlameAudio.bgm.stop().then((_) {}, onError: (_) {}));
  }

  void _haptic(Future<void> Function() fn) {
    if (progress.haptics) unawaited(fn().then((_) {}, onError: (_) {}));
  }

  @override
  void onEvent(SimEvent e, Skin skin) {
    switch (e.kind) {
      case EventKind.grab:
        play('thwip.wav');
        _haptic(HapticFeedback.selectionClick);
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
        play(big ? 'bonk_big.wav' : 'bonk.wav', volume: (e.value / 12).clamp(0.4, 1.0));
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
    }
  }

  @override
  void onReplayStart(Skin skin) {
    play('slowmo.wav', volume: 0.8);
    // The punchline gets a second, slow-motion helping.
    Future<void>.delayed(const Duration(milliseconds: 750), () => play('${skin.failSound}.wav', volume: 0.8));
  }
}
