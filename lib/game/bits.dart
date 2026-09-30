import 'dart:typed_data';

/// An immutable, growable set of small non-negative integers (collected
/// coins, reached checkpoints, smashed glass...). Setting a bit returns a new
/// set, so snapshots can share one safely.
class Bits {
  Bits._(this._words);

  static final empty = Bits._(Uint32List(0));

  final Uint32List _words;

  bool operator [](int i) {
    final k = i >> 5;
    return k < _words.length && (_words[k] >> (i & 31)) & 1 == 1;
  }

  /// This set plus [i].
  Bits add(int i) {
    if (this[i]) return this;
    final k = i >> 5;
    final w = Uint32List(k + 1 > _words.length ? k + 1 : _words.length)..setAll(0, _words);
    w[k] |= 1 << (i & 31);
    return Bits._(w);
  }

  int get count {
    var n = 0;
    for (var v in _words) {
      while (v != 0) {
        v &= v - 1;
        n++;
      }
    }
    return n;
  }

  bool get isEmpty => count == 0;
}
