import 'package:floppy_swing/services/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminders go out at the reminder hour for the next few days', () {
    final plan = planReminders(DateTime(2026, 10, 1, 9), doneToday: false, streak: 0);
    expect(plan, hasLength(reminderDays));
    expect(plan.map((r) => r.at), [
      for (var d = 0; d < reminderDays; d++) DateTime(2026, 10, 1 + d, reminderHour),
    ]);
    expect(plan.map((r) => r.id).toSet(), hasLength(reminderDays));
  });

  test("today's reminder is skipped once the daily is done or the hour passed", () {
    expect(
      planReminders(DateTime(2026, 10, 1, 9), doneToday: true, streak: 3).first.at,
      DateTime(2026, 10, 2, reminderHour),
    );
    expect(
      planReminders(DateTime(2026, 10, 1, 20), doneToday: false, streak: 0).first.at,
      DateTime(2026, 10, 2, reminderHour),
    );
  });

  test('a streak is mentioned when it is at stake', () {
    final r = planReminders(DateTime(2026, 10, 1, 9), doneToday: false, streak: 4).first;
    expect(r.title, contains('4-day streak'));
  });
}
