import 'package:flutter/material.dart';

import 'core/theme/motorsport_theme.dart';
import 'features/notifications/data/local_notification_service.dart';
import 'features/reminders/data/reminder_store.dart';
import 'features/reminders/presentation/screens/reminder_detail_screen.dart';
import 'features/reminders/presentation/screens/reminder_list_screen.dart';

class PictureReminderApp extends StatefulWidget {
  PictureReminderApp({
    required this.reminderStore,
    LocalNotificationService? notificationService,
    super.key,
  }) : notificationService =
           notificationService ?? reminderStore.notificationService;

  final ReminderStore reminderStore;
  final LocalNotificationService notificationService;

  @override
  State<PictureReminderApp> createState() => _PictureReminderAppState();
}

class _PictureReminderAppState extends State<PictureReminderApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    widget.notificationService.selectedReminderId.addListener(
      _openSelectedReminder,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _openSelectedReminder(),
    );
  }

  @override
  void dispose() {
    widget.notificationService.selectedReminderId.removeListener(
      _openSelectedReminder,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Picture Reminder',
      debugShowCheckedModeBanner: false,
      theme: buildMotorsportTheme(),
      home: ReminderListScreen(reminderStore: widget.reminderStore),
    );
  }

  void _openSelectedReminder() {
    final reminderId = widget.notificationService.selectedReminderId.value;
    if (reminderId == null) {
      return;
    }

    widget.notificationService.clearSelectedReminder();

    if (widget.reminderStore.findById(reminderId) == null) {
      return;
    }

    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ReminderDetailScreen(
          reminderStore: widget.reminderStore,
          reminderId: reminderId,
        ),
      ),
    );
  }
}
