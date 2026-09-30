import 'dart:math' as math;

import 'package:forge2d/forge2d.dart';

import 'config.dart';

/// Shape of one ragdoll body part, relative to the torso centre in the
/// standing pose (character faces right, y points down).
class PartSpec {
  const PartSpec(this.name, this.dx, this.dy, this.hw, this.hh, {this.circle = false});
  final String name;
  final double dx;
  final double dy;

  /// Half width (or radius for circles).
  final double hw;

  /// Half height.
  final double hh;
  final bool circle;
}

class JointSpec {
  const JointSpec(this.a, this.b, this.x, this.y, {this.lower, this.upper});
  final int a;
  final int b;
  final double x;
  final double y;
  final double? lower;
  final double? upper;
}

/// Indices into [Ragdoll.parts].
abstract final class Part {
  static const torso = 0;
  static const head = 1;
  static const upperArmBack = 2;
  static const lowerArmBack = 3;
  static const upperArmFront = 4;
  static const lowerArmFront = 5;
  static const upperLegBack = 6;
  static const lowerLegBack = 7;
  static const upperLegFront = 8;
  static const lowerLegFront = 9;
  static const count = 10;

  /// The rope is fired from this part's far end (the front hand).
  static const ropeHand = lowerArmFront;
}

const partSpecs = <PartSpec>[
  PartSpec('torso', 0, 0, 0.21, 0.33),
  PartSpec('head', 0, -0.56, 0.25, 0.25, circle: true),
  PartSpec('upperArmBack', 0, -0.09, 0.075, 0.17),
  PartSpec('lowerArmBack', 0, 0.25, 0.07, 0.17),
  PartSpec('upperArmFront', 0, -0.09, 0.075, 0.17),
  PartSpec('lowerArmFront', 0, 0.25, 0.07, 0.17),
  PartSpec('upperLegBack', 0, 0.5, 0.095, 0.2),
  PartSpec('lowerLegBack', 0, 0.9, 0.085, 0.2),
  PartSpec('upperLegFront', 0, 0.5, 0.095, 0.2),
  PartSpec('lowerLegFront', 0, 0.9, 0.085, 0.2),
];

const jointSpecs = <JointSpec>[
  JointSpec(Part.torso, Part.head, 0, -0.33, lower: -0.55, upper: 0.55),
  // Shoulders are unlimited: flailing arms are half the comedy.
  JointSpec(Part.torso, Part.upperArmBack, 0, -0.26),
  JointSpec(Part.upperArmBack, Part.lowerArmBack, 0, 0.08, lower: -2.5, upper: 0),
  JointSpec(Part.torso, Part.upperArmFront, 0, -0.26),
  JointSpec(Part.upperArmFront, Part.lowerArmFront, 0, 0.08, lower: -2.5, upper: 0),
  JointSpec(Part.torso, Part.upperLegBack, 0, 0.3, lower: -1.9, upper: 0.7),
  JointSpec(Part.upperLegBack, Part.lowerLegBack, 0, 0.7, lower: 0, upper: 2.4),
  JointSpec(Part.torso, Part.upperLegFront, 0, 0.3, lower: -1.9, upper: 0.7),
  JointSpec(Part.upperLegFront, Part.lowerLegFront, 0, 0.7, lower: 0, upper: 2.4),
];

/// Identifies a ragdoll body part in contact callbacks.
class PartTag {
  const PartTag(this.index);
  final int index;
}

/// A floppy 2D ragdoll made of boxes and a round head joined by revolute
/// joints with loose limits.
class Ragdoll {
  Ragdoll(World world, PhysicsConfig cfg, Vector2 torsoPos, {Vector2? velocity}) {
    for (var i = 0; i < partSpecs.length; i++) {
      final s = partSpecs[i];
      final isLimb = i >= Part.upperArmBack;
      final body = world.createBody(
        BodyDef(
          type: BodyType.dynamic,
          position: Vector2(torsoPos.x + s.dx, torsoPos.y + s.dy),
          linearVelocity: velocity?.clone(),
          linearDamping: cfg.linearDamping,
          angularDamping: isLimb ? cfg.jointFloppiness : 0.05,
          userData: PartTag(i),
          // A slightly tilted start keeps the collapse from looking too tidy.
          angle: i == Part.upperArmFront ? -0.6 : (i == Part.upperArmBack ? 0.5 : 0),
        ),
      );
      final Shape shape = s.circle
          ? CircleShape(radius: s.hw)
          : (PolygonShape()..setAsBoxXY(s.hw, s.hh));
      body.createFixture(
        FixtureDef(
          shape,
          density: isLimb ? cfg.limbDensity : cfg.bodyDensity,
          friction: cfg.friction,
          restitution: cfg.restitution,
          userData: PartTag(i),
          // Negative group: ragdoll parts never collide with each other.
          filter: Filter()..groupIndex = -1,
        ),
      );
      parts.add(body);
    }
    // Arms were tilted at spawn; place their children to match so joints
    // start satisfied.
    _alignChild(Part.upperArmFront, Part.lowerArmFront, torsoPos);
    _alignChild(Part.upperArmBack, Part.lowerArmBack, torsoPos);

    for (final j in jointSpecs) {
      final def = RevoluteJointDef()
        ..initialize(parts[j.a], parts[j.b], _jointWorld(j, torsoPos));
      if (j.lower != null) {
        def
          ..enableLimit = true
          ..lowerAngle = j.lower!
          ..upperAngle = j.upper!;
      }
      final joint = RevoluteJoint(def);
      world.createJoint(joint);
      joints.add(joint);
    }
  }

  final List<Body> parts = [];
  final List<RevoluteJoint> joints = [];

  Body get torso => parts[Part.torso];
  Body get hand => parts[Part.ropeHand];

  /// Local offset of the hand tip on [hand].
  Vector2 get handLocal => Vector2(0, partSpecs[Part.ropeHand].hh);

  Vector2 get handWorld => hand.worldPoint(handLocal);

  double get totalMass => parts.fold(0.0, (m, b) => m + b.mass);

  /// Mass-weighted average velocity of the whole ragdoll.
  Vector2 get velocity {
    final v = Vector2.zero();
    var m = 0.0;
    for (final b in parts) {
      v.addScaled(b.linearVelocity, b.mass);
      m += b.mass;
    }
    return v..scale(1 / m);
  }

  void setVelocity(Vector2 v) {
    for (final b in parts) {
      b.linearVelocity = v.clone();
    }
  }

  void addVelocity(Vector2 dv) {
    for (final b in parts) {
      b.linearVelocity = b.linearVelocity + dv;
    }
  }

  Vector2 _jointWorld(JointSpec j, Vector2 torsoPos) {
    // Joints between the arm segments follow the tilted upper arm.
    if (j.a == Part.upperArmFront || j.a == Part.upperArmBack) {
      return parts[j.a].worldPoint(Vector2(0, partSpecs[j.a].hh));
    }
    return Vector2(torsoPos.x + j.x, torsoPos.y + j.y);
  }

  void _alignChild(int upper, int lower, Vector2 torsoPos) {
    final u = parts[upper];
    final shoulder = Vector2(torsoPos.x, torsoPos.y - 0.26);
    // Rotate the upper arm around the shoulder instead of its own centre.
    final a = u.angle;
    final upperCentre =
        shoulder + Vector2(-math.sin(a), math.cos(a)) * partSpecs[upper].hh;
    u.setTransform(upperCentre, a);
    final elbow = u.worldPoint(Vector2(0, partSpecs[upper].hh));
    final l = parts[lower];
    final lowerCentre =
        elbow + Vector2(-math.sin(a), math.cos(a)) * partSpecs[lower].hh;
    l.setTransform(lowerCentre, a);
  }
}
