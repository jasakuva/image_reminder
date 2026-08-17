import 'package:flutter/material.dart';

import 'core/theme/motorsport_theme.dart';
import 'features/billing/data/premium_access_store.dart';
import 'features/notifications/data/local_notification_service.dart';
import 'features/reminders/data/reminder_store.dart';
import 'features/reminders/presentation/screens/create_reminder_screen.dart';
import 'features/reminders/presentation/screens/reminder_detail_screen.dart';
import 'features/reminders/presentation/screens/reminder_list_screen.dart';
import 'features/share/data/shared_image_receiver.dart';

class PictureReminderApp extends StatefulWidget {
  PictureReminderApp({
    required this.reminderStore,
    required this.premiumAccessStore,
    LocalNotificationService? notificationService,
    super.key,
  }) : notificationService =
           notificationService ?? reminderStore.notificationService;

  final ReminderStore reminderStore;
  final PremiumAccessStore premiumAccessStore;
  final LocalNotificationService notificationService;

  @override
  State<PictureReminderApp> createState() => _PictureReminderAppState();
}

class _PictureReminderAppState extends State<PictureReminderApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _sharedImageReceiver = SharedImageReceiver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.premiumAccessStore.addListener(_syncAccessState);
    widget.notificationService.selectedReminderId.addListener(
      _openSelectedReminder,
    );
    _sharedImageReceiver.sharedImagePath.addListener(_openSharedImageReminder);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openSelectedReminder();
      _sharedImageReceiver.loadInitialSharedImage();
      _syncAccessState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.premiumAccessStore.removeListener(_syncAccessState);
    widget.notificationService.selectedReminderId.removeListener(
      _openSelectedReminder,
    );
    _sharedImageReceiver.sharedImagePath.removeListener(
      _openSharedImageReminder,
    );
    _sharedImageReceiver.sharedImagePath.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.reminderStore.importPendingReminders();
      _syncAccessState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Picture Reminder',
      debugShowCheckedModeBanner: false,
      theme: buildMotorsportTheme(),
      home: ReminderListScreen(
        reminderStore: widget.reminderStore,
        premiumAccessStore: widget.premiumAccessStore,
      ),
    );
  }

  void _syncAccessState() {
    _sharedImageReceiver.syncPremiumAccessState(
      isPremium: widget.premiumAccessStore.isPremium,
      activeReminderCount: widget.reminderStore.activeReminderCount,
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

  void _openSharedImageReminder() {
    final imagePath = _sharedImageReceiver.sharedImagePath.value;
    if (imagePath == null) {
      return;
    }

    _sharedImageReceiver.clearSharedImage();

    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => CreateReminderScreen(
          reminderStore: widget.reminderStore,
          premiumAccessStore: widget.premiumAccessStore,
          initialImagePath: imagePath,
        ),
      ),
    );
  }
}
