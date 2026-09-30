import 'package:floppy_swing/services/links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('challenge links round-trip', () {
    expect(challengeSeedFromUri(Uri.parse(challengeLink(482913))), 482913);
    expect(challengeSeedFromUri(Uri.parse('floppyswing://other/1')), isNull);
    expect(challengeSeedFromUri(Uri.parse('https://example.com/challenge/5')), isNull);
  });

  test('the code box accepts a code, a link or a whole shared message', () {
    expect(challengeSeedFromText(' 123456 '), 123456);
    expect(challengeSeedFromText(challengeLink(77)), 77);
    expect(
      challengeSeedFromText(
        'I swung 350 m in Floppy Swing Endless. Can you beat me? floppyswing://challenge/9182\n'
        '(Or tap "Challenge code" in the menu and enter 9182.)',
      ),
      9182,
    );
    expect(challengeSeedFromText('hello'), isNull);
  });
}
