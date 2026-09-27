import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app.dart';
import '../game/level.dart';
import '../game/ragdoll.dart';
import '../game/renderer.dart';
import '../game/simulation.dart';
import '../game/skins.dart';
import 'theme.dart';
import 'widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3C2),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    RoundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('SKINS', style: display(36, color: AppColors.pink))),
                    CoinBadge(coins: progress.coins),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: skins.length,
                  itemBuilder: (context, i) {
                    final skin = skins[i];
                    final owned = progress.ownedSkins.contains(skin.id);
                    final selected = progress.selectedSkin == skin.id;
                    final price = progress.priceOf(skin);
                    return Panel(
                      padding: const EdgeInsets.all(10),
                      color: selected ? const Color(0xFFFFF4C9) : Colors.white,
                      child: Column(
                        children: [
                          Expanded(child: SkinPreview(skin: skin)),
                          Text(skin.name, textAlign: TextAlign.center, style: display(20, color: AppColors.ink, shadow: false)),
                          Text(skin.tagline, textAlign: TextAlign.center, maxLines: 2,
                              style: body(12, color: AppColors.greyDark)),
                          const SizedBox(height: 8),
                          if (selected)
                            Text('EQUIPPED', style: display(18, color: AppColors.greenDark, shadow: false))
                          else if (owned)
                            ChunkyButton(
                              onPressed: () => progress.selectSkin(skin),
                              label: 'Wear',
                              fontSize: 18,
                              color: AppColors.blue,
                              shade: AppColors.blueDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            )
                          else
                            ChunkyButton(
                              onPressed: progress.coins >= price
                                  ? () {
                                      if (progress.buySkin(skin)) {
                                        services.audio.play('buy.wav');
                                        services.analytics.skinBought(skin.id);
                                      }
                                    }
                                  : null,
                              color: AppColors.yellow,
                              shade: AppColors.yellowDark,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CoinIcon(size: 18),
                                  const SizedBox(width: 4),
                                  Text('$price', style: display(18)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a skin in a cheerful standing pose with the game renderer.
class SkinPreview extends StatefulWidget {
  const SkinPreview({super.key, required this.skin});
  final Skin skin;

  @override
  State<SkinPreview> createState() => _SkinPreviewState();
}

class _SkinPreviewState extends State<SkinPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => CustomPaint(
      painter: _SkinPainter(widget.skin, _a.value * math.pi * 2),
      size: Size.infinite,
    ),
  );
}

class _SkinPainter extends CustomPainter {
  _SkinPainter(this.skin, this.t);
  final Skin skin;
  final double t;

  static final _renderer = WorldRenderer(
    Level(
      id: 0,
      name: '',
      targetTime: 0,
      start: const P(0, 0),
      finish: const Box(100, 0, 1, 1),
      killY: 100,
      platforms: const [],
      anchors: const [],
      spikes: const [],
      saws: const [],
      pads: const [],
      coins: const [],
      checkpoints: const [],
    ),
    skins.first,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Pose: a little wave with the front arm.
    final wave = math.sin(t) * 0.5;
    final angles = <int, double>{
      Part.torso: math.sin(t) * 0.05,
      Part.head: math.sin(t + 0.5) * 0.15,
      Part.upperArmBack: 0.35,
      Part.lowerArmBack: 0.2,
      Part.upperArmFront: -2.4 + wave,
      Part.lowerArmFront: -2.6 + wave * 1.4,
      Part.upperLegBack: 0.15,
      Part.lowerLegBack: 0.15,
      Part.upperLegFront: -0.15,
      Part.lowerLegFront: -0.15,
    };
    final parts = Float32List(Part.count * 3);
    // Lay out the body from the torso by walking the joint chain.
    final pos = <int, Offset>{Part.torso: Offset.zero};
    for (final j in jointSpecs) {
      final parentAngle = angles[j.a]!;
      final childAngle = angles[j.b]!;
      final parentSpec = partSpecs[j.a];
      final childSpec = partSpecs[j.b];
      // Joint position in parent's frame (rest pose relative to parent centre).
      final jx = j.x - parentSpec.dx, jy = j.y - parentSpec.dy;
      final pc = pos[j.a]!;
      final joint = pc + _rot(Offset(jx, jy), parentAngle);
      final cx = childSpec.dx - j.x, cy = childSpec.dy - j.y;
      pos[j.b] = joint + _rot(Offset(cx, cy), childAngle);
    }
    for (var i = 0; i < Part.count; i++) {
      parts[i * 3] = pos[i]!.dx;
      parts[i * 3 + 1] = pos[i]!.dy;
      parts[i * 3 + 2] = angles[i]!;
    }
    final snap = Snapshot(
      t: 0,
      parts: parts,
      saws: Float32List(0),
      ropeAnchor: -1,
      ropeLength: 0,
      targetAnchor: -1,
      coins: 0,
      checkpoints: 0,
      vx: 0,
      vy: 0,
      status: SimStatus.running,
      runTime: 0,
    );
    final scale = math.min(size.width / 2.4, size.height / 2.6);
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.46);
    canvas.scale(scale);
    canvas.translate(0, math.sin(t * 2).abs() * -0.08);
    _renderer.drawRagdoll(canvas, snap, skin, t);
    canvas.restore();
  }

  Offset _rot(Offset o, double a) =>
      Offset(o.dx * math.cos(a) - o.dy * math.sin(a), o.dx * math.sin(a) + o.dy * math.cos(a));

  @override
  bool shouldRepaint(_SkinPainter old) => old.t != t || old.skin != skin;
}
