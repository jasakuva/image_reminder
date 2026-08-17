import 'package:flutter/material.dart';

import 'app.dart';
import 'features/billing/data/premium_access_store.dart';
import 'features/reminders/data/reminder_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final reminderStore = ReminderStore();
  final premiumAccessStore = PremiumAccessStore();
  await premiumAccessStore.load();
  await reminderStore.load();

  runApp(
    PictureReminderApp(
      reminderStore: reminderStore,
      premiumAccessStore: premiumAccessStore,
    ),
  );
}
