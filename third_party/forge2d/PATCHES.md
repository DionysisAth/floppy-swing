# Vendored forge2d 0.14.2+1

Pure-Dart Box2D port from https://github.com/flame-engine/forge2d (BSD-3-Clause,
see LICENSE), vendored because the published package has a bug we depend on
being fixed. Newer forge2d (0.15+) replaced the Dart engine with native Box2D v3.

## Patches

- `lib/src/dynamics/joints/revolute_joint.dart`: `initVelocityConstraints`
  filled the symmetric entries of the 3x3 effective-mass matrix (`ex.y`, `ex.z`,
  `ey.z`) from the previous step's matrix instead of the freshly computed
  `ey.x`, `ez.x`, `ez.y`. On the first step they were zero, which made any
  revolute joint whose anchor is off a body's centre (i.e. every ragdoll joint)
  inject huge sideways velocities; afterwards they lagged a step behind.
- `pubspec.yaml`: dropped workspace resolution and dev dependencies.
- `lib/src/common/solve22.dart` (new) and the revolute, weld and prismatic
  joints: replaced `Matrix3.solve2` from vector_math with Box2D's `Solve22`.
  vector_math's version subtracts the matrix's third column from the right-hand
  side (affine-transform semantics), so any joint whose anchors are not
  symmetric about both body centres received bogus impulses.
