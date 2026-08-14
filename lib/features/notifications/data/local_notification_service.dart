import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../reminders/domain/picture_reminder.dart';
import '../../reminders/domain/reminder_sound_mode.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Background notification taps are intentionally kept minimal for now.
  // Foreground/startup routing can be added when app-level navigation is expanded.
}

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final ValueNotifier<String?> selectedReminderId = ValueNotifier<String?>(
    null,
  );

  static const String _notificationChannelId = 'picture_reminders_default_v1';
  static const String _alarmChannelId = 'picture_reminders_alarm_v1';
  static const String _channelName = 'Picture reminders';
  static const String _channelDescription =
      'Notifications for scheduled picture reminders.';
  static const String _androidSoundResource = 'reminder_alarm';
  static const String _iosSoundFile = 'reminder_alarm.wav';

  Future<void> initialize() async {
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchResponse != null) {
      _handleNotificationResponse(launchResponse);
    }

    await requestPermissions();
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return false;
    }

    if (Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.requestNotificationsPermission() ??
          true;
    }

    if (Platform.isIOS) {
      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  Future<void> scheduleReminder(PictureReminder reminder) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    if (!reminder.scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id: reminder.notificationId,
      title: reminder.notifyText,
      body: 'Tap to view your saved picture.',
      scheduledDate: tz.TZDateTime.from(reminder.scheduledAt, tz.local),
      notificationDetails: _notificationDetailsFor(reminder.soundMode),
      payload: jsonEncode({'type': 'reminder', 'reminderId': reminder.id}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  NotificationDetails _notificationDetailsFor(ReminderSoundMode soundMode) {
    return switch (soundMode) {
      ReminderSoundMode.notification => const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      ReminderSoundMode.alarm => const NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(_androidSoundResource),
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: _iosSoundFile,
        ),
      ),
    };
  }

  Future<void> cancelReminder(PictureReminder reminder) async {
    await _plugin.cancel(id: reminder.notificationId);
  }

  void clearSelectedReminder() {
    selectedReminderId.value = null;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      return;
    }

    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, Object?>) {
      return;
    }

    if (decoded['type'] != 'reminder') {
      return;
    }

    final reminderId = decoded['reminderId'];
    if (reminderId is String && reminderId.isNotEmpty) {
      selectedReminderId.value = reminderId;
    }
  }
}
