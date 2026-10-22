/// Comic words the renderer draws into the game world ("GO!", "OUCH!",
/// style tricks). English by default; the game screen swaps in the
/// player's language.
class GameWords {
  const GameWords({
    this.best = 'BEST',
    this.checkpoint = 'CHECKPOINT!',
    this.go = 'GO!',
    this.smash = 'SMASH!',
    this.kaboom = 'KABOOM!',
    this.bonk = 'BONK!',
    this.saw = 'ZZZING!',
    this.spikes = 'OUCH!',
    this.pit = 'YEOWCH!',
    this.stuck = 'ZZZ...',
    this.confetti = 'WHEEE!',
    this.jackpot = 'JACKPOT!',
    this.squeak = 'SQUEAK!',
    this.styles = const {},
  });

  final String best;
  final String checkpoint;
  final String go;
  final String smash;
  final String kaboom;
  final String bonk;
  final String saw;
  final String spikes;
  final String pit;
  final String stuck;
  final String confetti;
  final String jackpot;
  final String squeak;

  /// Style trick names, keyed by the simulation's English label.
  final Map<String, String> styles;

  static final _combo = RegExp(r'^(.*?)( x\d+)?$');

  /// [label] from a style event ("FLIP" or "FLIP x3") in the player's
  /// language.
  String style(String label) {
    final m = _combo.firstMatch(label)!;
    return '${styles[m[1]] ?? m[1]}${m[2] ?? ''}';
  }
}
