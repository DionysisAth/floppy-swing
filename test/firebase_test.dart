import 'package:floppy_swing/services/firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analytics parameters become numbers and short strings for Firebase', () {
    expect(
      firebaseParams({'level': 3, 'time': '4.20', 'premium': true, 'gone': null, 'long': 'x' * 150}),
      {'level': 3, 'time': '4.20', 'premium': 1, 'long': 'x' * 100},
    );
  });
}
