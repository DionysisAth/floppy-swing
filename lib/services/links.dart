/// Endless challenge links: `floppyswing://challenge/<code>` opens the game
/// straight into a friend's course.
const linkScheme = 'floppyswing';

String challengeLink(int seed) => '$linkScheme://challenge/$seed';

/// The course code in a challenge link, or null if [uri] isn't one.
int? challengeSeedFromUri(Uri uri) {
  if (uri.scheme != linkScheme) return null;
  final parts = [if (uri.host.isNotEmpty) uri.host, ...uri.pathSegments];
  if (parts.length != 2 || parts.first != 'challenge') return null;
  return int.tryParse(parts[1]);
}

/// The course code in whatever a player pastes: a bare code, a link, or a
/// whole shared message.
int? challengeSeedFromText(String text) {
  final t = text.trim();
  final bare = int.tryParse(t);
  if (bare != null) return bare;
  final link = RegExp('$linkScheme://challenge/(\\d+)').firstMatch(t);
  if (link != null) return int.tryParse(link.group(1)!);
  final numbers = RegExp(r'\d{4,}').allMatches(t).toList();
  return numbers.isEmpty ? null : int.tryParse(numbers.last.group(0)!);
}
