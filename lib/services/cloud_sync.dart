import 'dart:async';

import 'package:flutter/widgets.dart';

import 'online_service.dart';
import 'progress.dart';

/// Keeps the local save and the cloud save in step, and collects rewards the
/// server sends (e.g. for winning Fail of the Week).
///
/// - On sign-in it pulls the cloud save and merges it in
///   ([ProgressStore.mergeFrom]), so a new phone picks up where the old one
///   left off.
/// - Local changes are pushed a few seconds later, and right away when the
///   app goes to the background.
/// - If another device saved in between, the server refuses the upload; the
///   newer copy is merged in and the upload retried.
class CloudSync with WidgetsBindingObserver {
  CloudSync(this.progress, this.online, {this.delay = const Duration(seconds: 8)});

  final ProgressStore progress;
  final OnlineService online;
  final Duration delay;

  Timer? _timer;
  bool _dirty = false;
  bool _pushing = false;
  bool _applying = false;
  bool _wasOnline = false;
  bool _started = false;

  /// Pending work, for tests and for flushing before the app suspends.
  Future<void> _work = Future.value();

  void start() {
    if (_started) return;
    _started = true;
    progress.addListener(_onProgress);
    online.addListener(_onOnline);
    WidgetsBinding.instance.addObserver(this);
    _onOnline();
  }

  void dispose() {
    _timer?.cancel();
    progress.removeListener(_onProgress);
    online.removeListener(_onOnline);
    if (_started) WidgetsBinding.instance.removeObserver(this);
  }

  void _onProgress() {
    if (_applying) return;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(delay, () => _queue(push));
  }

  void _onOnline() {
    final nowOnline = online.isOnline;
    if (nowOnline && !_wasOnline) _queue(pull);
    _wasOnline = nowOnline;
  }

  /// Call after the account changed (moved in from another device).
  Future<void> accountChanged() {
    progress.cloudRevision = 0;
    return _queue(pull);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _timer?.cancel();
      _queue(push);
      unawaited(online.flushEvents());
    }
  }

  Future<void> _queue(Future<void> Function() job) {
    _work = _work.then((_) => job()).catchError((Object e) => debugPrint('Cloud sync: $e'));
    return _work;
  }

  /// Waits for queued syncs (tests).
  Future<void> idle() => _work;

  void _apply(Map<String, dynamic> data) {
    _applying = true;
    try {
      progress.mergeFrom(data);
    } finally {
      _applying = false;
    }
  }

  Future<void> pull() async {
    if (!online.isOnline) return;
    final cloud = await online.loadSave();
    if (cloud != null && cloud.revision != progress.cloudRevision) {
      _apply(cloud.data);
      progress.cloudRevision = cloud.revision;
    }
    // Upload our side too (it may have progress the cloud lacks).
    _dirty = true;
    await push();
  }

  Future<void> push() async {
    if (!_dirty || _pushing || !online.isOnline) return;
    _pushing = true;
    try {
      for (var attempt = 0; attempt < 3; attempt++) {
        _dirty = false;
        final r = await online.storeSave(progress.toJson(), progress.cloudRevision);
        if (r.revision != null) {
          progress.cloudRevision = r.revision!;
          return;
        }
        // Another device saved first: merge its copy and try again.
        if (r.conflictData != null) _apply(r.conflictData!);
        progress.cloudRevision = r.conflictRevision ?? 0;
      }
    } catch (e) {
      _dirty = true;
      rethrow;
    } finally {
      _pushing = false;
    }
  }

  /// Claims server rewards and adds them to the save. Returns what was
  /// granted so the UI can celebrate.
  Future<List<ServerReward>> collectRewards() async {
    if (!online.isOnline) return const [];
    final granted = <ServerReward>[];
    for (final r in await online.rewards()) {
      await online.claimReward(r.id);
      if (r.coins > 0) progress.addCoins(r.coins);
      if (r.gems > 0) progress.addGems(r.gems);
      final item = r.item;
      if (item != null) progress.grantItem(item);
      granted.add(r);
    }
    return granted;
  }
}
