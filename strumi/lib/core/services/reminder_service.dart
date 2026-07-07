import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Daily practice-reminder notifications ("Notifikasi latihan" setting).
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const int _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Initializes the plugin and the local timezone database.
  /// Safe to call on platforms without notification support.
  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Fall back to the bundled default (UTC) rather than failing init.
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      _ready = await _plugin.initialize(settings: settings) ?? false;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    } catch (_) {
      _ready = false;
    }
  }

  /// (Re)schedules the daily reminder at [time]; cancels any previous one.
  Future<void> scheduleDaily(TimeOfDay time) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _notificationId);

      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, time.hour, time.minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        id: _notificationId,
        title: 'Waktunya latihan gitar 🎸',
        body:
            'Streak-mu menunggu — mainkan minimal satu sesi hari ini di Strumi.',
        scheduledDate: next,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'practice_reminder',
            'Pengingat latihan',
            channelDescription: 'Pengingat harian untuk berlatih gitar',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Never let a scheduling failure break the settings flow.
    }
  }

  Future<void> cancel() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _notificationId);
    } catch (_) {}
  }
}
