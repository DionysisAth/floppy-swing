import 'package:forge2d/forge2d.dart';

/// Solves the top-left 2x2 block of [a] for `a * x = b` (Box2D's `Solve22`).
///
/// Floppy Swing patch: vector_math's `Matrix3.solve2` treats the matrix as a
/// 2D affine transform and subtracts the third column from [b] first, which
/// is wrong for Box2D's effective-mass matrices.
void solve22(Matrix3 a, Vector2 x, Vector2 b) {
  final a11 = a.entry(0, 0);
  final a12 = a.entry(0, 1);
  final a21 = a.entry(1, 0);
  final a22 = a.entry(1, 1);
  var det = a11 * a22 - a12 * a21;
  if (det != 0.0) {
    det = 1.0 / det;
  }
  final bx = b.x, by = b.y;
  x
    ..x = det * (a22 * bx - a12 * by)
    ..y = det * (a11 * by - a21 * bx);
}
