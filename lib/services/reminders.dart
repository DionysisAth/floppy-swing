import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l10n.dart';
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
/// Written in [strings]' language (English by default).
List<Reminder> planReminders(
  DateTime now, {
  required bool doneToday,
  required int streak,
  AppLocalizations? strings,
}) {
  final l = strings ?? lookupAppLocalizations(const Locale('en'));
  final later = [
    (l.reminderFreshTitle, l.reminderFreshBody),
    (l.reminderRestlessTitle, l.reminderRestlessBody),
    (l.reminderTimeTitle, l.reminderTimeBody),
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
          streak > 0 ? l.reminderStreakTitle(streak) : l.reminderTodayTitle,
          streak > 0 ? l.reminderStreakBody : l.reminderTodayBody,
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
  ReminderService(this.progress, {AppLocalizations? strings})
    : _strings = strings ?? lookupAppLocalizations(const Locale('en'));

  final ProgressStore progress;
  AppLocalizations _strings;

  /// Writes future reminders in [strings]' language (the app calls this with
  /// its current language).
  void useStrings(AppLocalizations strings) {
    if (strings.localeName == _strings.localeName) return;
    _strings = strings;
    unawaited(reschedule());
  }

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
        strings: _strings,
      );
      for (final r in plan) {
        await _plugin.zonedSchedule(
          id: r.id,
          // UTC instant of the local time, so no time zone database is needed.
          scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_challenge',
              _strings.dailyReminders,
              channelDescription: _strings.reminderChannelDescription,
              importance: Importance.defaultImportance,
            ),
            iOS: const DarwinNotificationDetails(),
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
