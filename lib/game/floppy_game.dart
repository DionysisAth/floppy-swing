import 'dart:ui';

import 'package:flame/game.dart';

import 'game_controller.dart';

/// Thin Flame wrapper: Flame provides the frame loop and lifecycle, the
/// [GameController] does the rest.
class FloppyGame with Game {
  FloppyGame(this.controller, {this.dim = 0});

  final GameController controller;

  /// Darkens the scene (used for the menu's demo background).
  final double dim;

  @override
  void update(double dt) => controller.tick(dt);

  @override
  void render(Canvas canvas) {
    final s = size;
    if (s.x <= 0 || s.y <= 0) return;
    final sz = Size(s.x, s.y);
    final frame = controller.frame;
    controller.renderer.render(
      canvas,
      sz,
      frame,
      events: controller.events,
      wallTime: controller.wallTime,
      showTarget: controller.autopilot == null,
      trail: controller.trailAt(frame.s.t),
    );
    if (dim > 0) {
      canvas.drawRect(Offset.zero & sz, Paint()..color = Color.fromARGB((dim * 255).round(), 43, 29, 20));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    controller.setViewport(size.x, size.y);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        controller.autopilot == null &&
        (controller.phase == GamePhase.playing || controller.phase == GamePhase.ready)) {
      controller.setPaused(true);
    }
  }
}
