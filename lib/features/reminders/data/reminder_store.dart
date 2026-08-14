import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifications/data/local_notification_service.dart';
import '../domain/picture_reminder.dart';
import '../domain/reminder_status.dart';

class ReminderStore extends ChangeNotifier {
  ReminderStore({LocalNotificationService? notificationService})
    : _notificationService = notificationService ?? LocalNotificationService();

  static const _storageKey = 'picture_reminders';

  final LocalNotificationService _notificationService;
  final List<PictureReminder> _reminders = [];

  LocalNotificationService get notificationService => _notificationService;

  List<PictureReminder> get reminders {
    final sorted = [..._reminders]
      ..sort((a, b) {
        if (a.status != b.status) {
          return a.status == ReminderStatus.active ? -1 : 1;
        }
        return a.scheduledAt.compareTo(b.scheduledAt);
      });
    return List.unmodifiable(sorted);
  }

  Future<void> load() async {
    await _notificationService.initialize();

    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return;
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    _reminders
      ..clear()
      ..addAll(
        decoded.cast<Map<String, Object?>>().map(PictureReminder.fromJson),
      );
  }

  PictureReminder? findById(String id) {
    for (final reminder in _reminders) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    return null;
  }

  Future<void> add(PictureReminder reminder) async {
    _reminders.add(reminder);
    await _notificationService.scheduleReminder(reminder);
    await _saveAndNotify();
  }

  Future<void> markCompleted(String id) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final now = DateTime.now();
    final reminder = _reminders[index];
    await _notificationService.cancelReminder(reminder);

    _reminders[index] = reminder.copyWith(
      status: ReminderStatus.completed,
      completedAt: now,
      updatedAt: now,
    );
    await _saveAndNotify();
  }

  Future<void> snooze(String id, Duration duration) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final now = DateTime.now();
    final reminder = _reminders[index];
    await _notificationService.cancelReminder(reminder);

    final snoozedReminder = reminder.copyWith(
      scheduledAt: now.add(duration),
      updatedAt: now,
      status: ReminderStatus.active,
      snoozeCount: reminder.snoozeCount + 1,
      lastSnoozedAt: now,
    );
    _reminders[index] = snoozedReminder;
    await _notificationService.scheduleReminder(snoozedReminder);
    await _saveAndNotify();
  }

  Future<void> delete(String id) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final reminder = _reminders.removeAt(index);
    await _notificationService.cancelReminder(reminder);
    final imageFile = File(reminder.imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    await _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _reminders.map((reminder) => reminder.toJson()).toList(),
    );
    await preferences.setString(_storageKey, encoded);
    notifyListeners();
  }
}
