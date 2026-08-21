import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifications/data/local_notification_service.dart';
import '../../share/data/shared_image_receiver.dart';
import '../domain/reminder_sound_mode.dart';
import '../domain/picture_reminder.dart';
import '../domain/reminder_status.dart';

class ReminderStore extends ChangeNotifier {
  ReminderStore({LocalNotificationService? notificationService})
    : _notificationService = notificationService ?? LocalNotificationService();

  static const _storageKey = 'picture_reminders';

  final LocalNotificationService _notificationService;
  final List<PictureReminder> _reminders = [];
  final SharedImageReceiver _sharedImageReceiver = SharedImageReceiver();

  LocalNotificationService get notificationService => _notificationService;

  List<PictureReminder> get reminders {
    final sorted = [..._reminders]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return List.unmodifiable(sorted);
  }

  int get activeReminderCount =>
      _reminders.where((reminder) => reminder.status == ReminderStatus.active).length;

  bool hasReachedFreeReminderLimit(bool isPremium) {
    if (isPremium) {
      return false;
    }

    return activeReminderCount >= 2;
  }

  Future<void> load() async {
    await _notificationService.initialize();

    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_storageKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      _reminders
        ..clear()
        ..addAll(
          decoded.cast<Map<String, Object?>>().map(PictureReminder.fromJson),
        );
    }

    await importPendingReminders();
  }

  Future<void> importPendingReminders() async {
    await _importPendingReminders();
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

  Future<void> updateReminder(
    String id, {
    required DateTime scheduledAt,
    required ReminderSoundMode soundMode,
  }) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final reminder = _reminders[index];
    await _notificationService.cancelReminder(reminder);

    final updatedReminder = reminder.copyWith(
      scheduledAt: scheduledAt,
      soundMode: soundMode,
      updatedAt: DateTime.now(),
      status: ReminderStatus.active,
    );
    _reminders[index] = updatedReminder;
    await _notificationService.scheduleReminder(updatedReminder);
    await _saveAndNotify();
  }

  Future<void> _importPendingReminders() async {
    if (kIsWeb || !Platform.isIOS) {
      return;
    }

    debugPrint('[ReminderStore] starting pending import');
    await _sharedImageReceiver.loadInitialSharedImage();
    final pendingImports = _sharedImageReceiver.pendingReminderImports.value;
    debugPrint('[ReminderStore] Pending iOS reminder imports: ${pendingImports.length}');
    if (pendingImports.isEmpty) {
      return;
    }

    var didChange = false;
    final filesToDelete = <String>[];
    for (final pendingImport in pendingImports) {
      debugPrint('[ReminderStore] Importing pending reminder id=${pendingImport.id} file=${pendingImport.fileName}');
      if (findById(pendingImport.id) != null) {
        debugPrint('[ReminderStore] Reminder already exists, marking imported: ${pendingImport.id}');
        filesToDelete.add(pendingImport.fileName);
        continue;
      }

      final reminder = PictureReminder(
        id: pendingImport.id,
        title: pendingImport.title,
        note: pendingImport.note,
        imagePath: pendingImport.imagePath,
        scheduledAt: pendingImport.scheduledAt,
        createdAt: pendingImport.createdAt,
        updatedAt: pendingImport.updatedAt,
        completedAt: pendingImport.completedAt,
        status: ReminderStatus.fromName(pendingImport.status),
        snoozeCount: pendingImport.snoozeCount,
        notificationId: pendingImport.notificationId,
        soundMode: ReminderSoundMode.fromName(pendingImport.soundMode),
        lastSnoozedAt: pendingImport.lastSnoozedAt,
      );

      _reminders.add(reminder);
      if (!pendingImport.notificationScheduled) {
        debugPrint('[ReminderStore] Scheduling imported reminder in Flutter: ${pendingImport.id}');
        await _notificationService.scheduleReminder(reminder);
      } else {
        debugPrint('[ReminderStore] Native notification already scheduled for: ${pendingImport.id}');
      }
      filesToDelete.add(pendingImport.fileName);
      didChange = true;
    }

    if (didChange) {
      await _saveAndNotify();
    }

    for (final fileName in filesToDelete) {
      await _sharedImageReceiver.markPendingReminderImported(fileName);
    }
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
