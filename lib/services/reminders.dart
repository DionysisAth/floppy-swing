import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'progress.dart';

/// One scheduled Daily Challenge reminder.
class Reminder {
  const Reminder(this.id, this.at, this.title, this.body);
  final int id;
  final DateTime at;
  final String title;
  final String body;
}

/// Local hour reminders go out at.
const reminderHour = 18;

/// Days ahead reminders are planned for. After that they stop, so someone
/// who stopped playing isn't pestered; opening the app plans them again.
const reminderDays = 3;

/// The reminders to schedule from [now]: one a day at [reminderHour], today's
/// only if today's challenge isn't done yet and the hour hasn't passed.
List<Reminder> planReminders(DateTime now, {required bool doneToday, required int streak}) {
  const later = [
    ('A fresh Daily Challenge is here', 'New level, new ghost to beat. Can you get all 3 stars?'),
    ('Floppy is getting restless', "Today's Daily Challenge won't swing itself."),
    ('Daily Challenge time!', 'One quick swing? Clear it to keep your streak going.'),
  ];
  final out = <Reminder>[];
  for (var d = 0; d < reminderDays; d++) {
    final at = DateTime(now.year, now.month, now.day + d, reminderHour);
    if (!at.isAfter(now)) continue;
    if (d == 0) {
      if (doneToday) continue;
      out.add(
        Reminder(
          d,
          at,
          streak > 0 ? 'Keep your $streak-day streak!' : "Today's Daily Challenge is waiting",
          streak > 0 ? "Clear today's Daily Challenge before midnight." : 'A new level every day. Go get those stars!',
        ),
      );
    } else {
      final (title, body) = later[(at.day + d) % later.length];
      out.add(Reminder(d, at, title, body));
    }
  }
  return out;
}

/// Daily Challenge reminders as local notifications (no server, no push).
///
/// Permission is only asked for once a player has cleared a Daily Challenge
/// (or turns reminders on in Settings), never at first launch.
class ReminderService {
  ReminderService(this.progress);

  final ProgressStore progress;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (!supported) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_swing'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
    await reschedule();
  }

  /// Asks the system for permission to show notifications. Returns whether
  /// it was granted.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    progress.setRemindersAsked();
    final granted = Platform.isIOS
        ? await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, sound: true)
        : await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// After a Daily Challenge clear: ask once, then plan the next reminders.
  Future<void> dailyCleared() async {
    if (!_ready) return;
    if (progress.reminders && !progress.remindersAsked) await requestPermission();
    await reschedule();
  }

  /// Turns reminders on or off (Settings).
  Future<void> setEnabled(bool on) async {
    progress.setReminders(on);
    if (on) await requestPermission();
    await reschedule();
  }

  /// Replaces the scheduled reminders with a fresh plan.
  Future<void> reschedule() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!progress.reminders || !progress.remindersAsked) return;
      final now = progress.clock();
      final plan = planReminders(
        now,
        doneToday: progress.dailyRecord(progress.today).completed,
        streak: progress.currentDailyStreak,
      );
      for (final r in plan) {
        await _plugin.zonedSchedule(
          id: r.id,
          // UTC instant of the local time, so no time zone database is needed.
          scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_challenge',
              'Daily Challenge reminders',
              channelDescription: 'A nudge when a new Daily Challenge is out.',
              importance: Importance.defaultImportance,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: r.title,
          body: r.body,
        );
      }
    } catch (e) {
      debugPrint('Reminders: $e');
    }
  }
}
