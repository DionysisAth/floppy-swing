import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app.dart';
import '../game/cosmetics.dart';
import '../game/level.dart';
import '../game/ragdoll.dart';
import '../game/renderer.dart';
import '../game/simulation.dart';
import '../game/skins.dart';
import 'theme.dart';
import 'widgets.dart';

/// Shop: skins, ropes, trails, fail effects, victory dances and collections.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const _tabs = ['Skins', 'Ropes', 'Trails', 'Fails', 'Dances', 'Sets'];

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE3C2),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: progress,
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      RoundButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('SHOP', style: display(36, color: AppColors.pink))),
                      FittedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CoinBadge(coins: progress.coins),
                            const SizedBox(height: 4),
                            GemBadge(gems: progress.gems),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.ink, width: 3),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: display(18),
                  unselectedLabelStyle: display(18, color: AppColors.ink, shadow: false),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: [for (final t in _tabs) Tab(text: t, height: 40)],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      _grid([for (final skin in skins) _skinCard(context, skin)]),
                      for (final kind in CosmeticKind.values)
                        _grid([
                          for (final c in cosmetics.where((c) => c.kind == kind)) _itemCard(context, c),
                        ]),
                      _collections(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(List<Widget> cards) => GridView.count(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
    crossAxisCount: 2,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.62,
    children: cards,
  );

  Widget _card({
    required Widget preview,
    required String name,
    required String tagline,
    required bool selected,
    required Widget action,
  }) => Panel(
    padding: const EdgeInsets.all(10),
    color: selected ? const Color(0xFFFFF4C9) : Colors.white,
    child: Column(
      children: [
        Expanded(child: preview),
        FittedBox(child: Text(name, textAlign: TextAlign.center, style: display(20, color: AppColors.ink, shadow: false))),
        Text(tagline, textAlign: TextAlign.center, maxLines: 2, style: body(12, color: AppColors.greyDark)),
        const SizedBox(height: 8),
        action,
      ],
    ),
  );

  Widget _skinCard(BuildContext context, Skin skin) {
    final services = AppServices.of(context);
    final progress = services.progress;
    final owned = progress.ownedSkins.contains(skin.id);
    final selected = progress.selectedSkin == skin.id;
    final price = progress.priceOf(skin);
    return _card(
      preview: SkinPreview(skin: skin),
      name: skin.name,
      tagline: skin.tagline,
      selected: selected,
      action: selected
          ? Text('EQUIPPED', style: display(18, color: AppColors.greenDark, shadow: false))
          : owned
          ? _wear(() => progress.selectSkin(skin))
          : skin.exclusive
          ? const _SeasonOnly()
          : _PriceButton(
              coins: price,
              enabled: progress.coins >= price,
              onPressed: () {
                if (progress.buySkin(skin)) {
                  services.audio.play('buy.wav');
                  services.analytics.skinBought(skin.id);
                }
              },
            ),
    );
  }

  Widget _itemCard(BuildContext context, Cosmetic c) {
    final services = AppServices.of(context);
    final progress = services.progress;
    final owned = progress.ownsItem(c);
    final selected = progress.equippedId(c.kind) == c.id;
    return _card(
      preview: CosmeticPreview(item: c),
      name: c.name,
      tagline: c.tagline,
      selected: selected,
      action: selected
          ? Text('EQUIPPED', style: display(18, color: AppColors.greenDark, shadow: false))
          : owned
          ? _wear(() => progress.equip(c))
          : c.exclusive
          ? const _SeasonOnly()
          : _PriceButton(
              coins: c.coins,
              gems: c.gems,
              enabled: progress.canAfford(c),
              onPressed: () {
                if (progress.buyItem(c)) {
                  services.audio.play('buy.wav');
                  services.analytics.skinBought(c.id);
                }
              },
            ),
    );
  }

  Widget _wear(VoidCallback onPressed) => ChunkyButton(
    onPressed: onPressed,
    label: 'Use',
    fontSize: 18,
    color: AppColors.blue,
    shade: AppColors.blueDark,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  Widget _collections(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    String nameOf(String id) =>
        skins.any((s) => s.id == id) ? skinById(id).name : cosmeticById(id).name;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final c in collections)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: display(22, color: AppColors.ink, shadow: false)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final id in c.items)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: progress.owns(id) ? const Color(0xFFC9F2D6) : const Color(0xFFEDE6DC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (progress.owns(id))
                                      const Icon(Icons.check_rounded, size: 14, color: AppColors.greenDark),
                                    Text(nameOf(id), style: body(13, weight: 700)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (progress.claimedCollections.contains(c.id))
                    const Icon(Icons.check_circle_rounded, color: AppColors.greenDark, size: 36)
                  else
                    ChunkyButton(
                      onPressed: progress.collectionComplete(c)
                          ? () {
                              if (progress.claimCollection(c)) services.audio.play('buy.wav');
                            }
                          : null,
                      color: AppColors.green,
                      shade: AppColors.greenDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GemIcon(size: 18),
                          Text(' ${c.gems}', style: display(18)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "Buy" button showing a coin or gem price.
class _PriceButton extends StatelessWidget {
  const _PriceButton({required this.onPressed, required this.enabled, this.coins = 0, this.gems = 0});
  final VoidCallback onPressed;
  final bool enabled;
  final int coins;
  final int gems;

  @override
  Widget build(BuildContext context) => ChunkyButton(
    onPressed: enabled ? onPressed : null,
    color: gems > 0 ? const Color(0xFF3FD0FF) : AppColors.yellow,
    shade: gems > 0 ? const Color(0xFF1C9AD6) : AppColors.yellowDark,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (gems > 0) const GemIcon(size: 18) else const CoinIcon(size: 18),
        const SizedBox(width: 4),
        Text('${gems > 0 ? gems : coins}', style: display(18)),
      ],
    ),
  );
}

class _SeasonOnly extends StatelessWidget {
  const _SeasonOnly();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.workspace_premium_rounded, color: Color(0xFF8F6BC7), size: 20),
      const SizedBox(width: 4),
      Text('Season Pass', style: display(16, color: const Color(0xFF8F6BC7), shadow: false)),
    ],
  );
}

WorldRenderer _previewRenderer() => WorldRenderer(
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

/// Animated sample of a rope, trail, fail effect or dance.
class CosmeticPreview extends StatefulWidget {
  const CosmeticPreview({super.key, required this.item});
  final Cosmetic item;

  @override
  State<CosmeticPreview> createState() => _CosmeticPreviewState();
}

class _CosmeticPreviewState extends State<CosmeticPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..repeat();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.kind == CosmeticKind.dance) {
      return AnimatedBuilder(
        animation: _a,
        builder: (_, _) {
          final t = _a.value * math.pi * 2;
          final (icon, turn, hop) = switch (widget.item.id) {
            'backflip' => (Icons.u_turn_left_rounded, -t, math.sin(t).abs()),
            'spin' => (Icons.cyclone_rounded, t * 2, 0.3),
            'flail' => (Icons.waving_hand_rounded, math.sin(t * 6) * 0.5, math.sin(t * 3).abs() * 0.5),
            _ => (Icons.celebration_rounded, 0.0, math.sin(t * 3).abs()),
          };
          return Center(
            child: Transform.translate(
              offset: Offset(0, -hop * 18),
              child: Transform.rotate(angle: turn, child: Icon(icon, size: 64, color: AppColors.orange)),
            ),
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) => CustomPaint(
        painter: _CosmeticPainter(widget.item, _a.value * 3),
        size: Size.infinite,
      ),
    );
  }
}

class _CosmeticPainter extends CustomPainter {
  _CosmeticPainter(this.item, this.time);
  final Cosmetic item;

  /// Seconds into the looping preview.
  final double time;

  static final _renderer = _previewRenderer();

  @override
  void paint(Canvas canvas, Size size) {
    // Preview space: 4 metres across (fail effects are bigger).
    final scale = size.width / (item.kind == CosmeticKind.failEffect ? 7.5 : 4);
    // A patch of sky so white trails and sparkles show up.
    final box = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(
      box,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CC8FF), Color(0xFFCDEBFF)],
        ).createShader(Offset.zero & size),
    );
    canvas.save();
    canvas.clipRRect(box);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    switch (item.kind) {
      case CosmeticKind.rope:
        const anchor = Offset(0, -1.6);
        final swing = math.sin(time * math.pi * 2 / 1.5) * 0.7;
        final hand = anchor + Offset(math.sin(swing), math.cos(swing)) * 2.6;
        _renderer.drawRopeStyled(canvas, hand, Offset.lerp(hand, anchor, 0.5)!, anchor, time, item.id);
        final fill = Paint()..color = const Color(0xFF2D9CFF);
        canvas.drawCircle(anchor, 0.22, fill);
        canvas.drawCircle(hand, 0.16, Paint()..color = const Color(0xFFFFD2A8));
      case CosmeticKind.trail:
        Offset at(double t) => Offset(math.cos(t * 6) * 1.3, math.sin(t * 12) * 0.6);
        final trail = [for (var k = 13; k >= 0; k--) at(time - k / 60)];
        _renderer.drawTrailStyled(canvas, trail, time, item.id);
        canvas.drawCircle(trail.last, 0.2, Paint()..color = const Color(0xFFFF8A3D));
      case CosmeticKind.failEffect:
        final t = (time % 1.5) / 1.2;
        if (t < 1) _renderer.drawFailEffect(canvas, 0, 1.2, t, 3, item.id, 'OUCH!');
      case CosmeticKind.dance:
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CosmeticPainter old) => old.time != time || old.item != item;
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

  static final _renderer = _previewRenderer();

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
      coins: Bits.empty,
      checkpoints: Bits.empty,
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
