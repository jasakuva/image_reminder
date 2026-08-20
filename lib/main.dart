import 'package:flutter/material.dart';

import 'app.dart';
import 'features/billing/data/premium_access_store.dart';
import 'features/reminders/data/reminder_store.dart';
import 'features/settings/data/locale_settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final reminderStore = ReminderStore();
  final premiumAccessStore = PremiumAccessStore();
  final localeSettingsStore = LocaleSettingsStore();
  await premiumAccessStore.load();
  await premiumAccessStore.initializeBilling();
  await localeSettingsStore.load();
  await reminderStore.load();

  runApp(
    PictureReminderApp(
      reminderStore: reminderStore,
      premiumAccessStore: premiumAccessStore,
      localeSettingsStore: localeSettingsStore,
    ),
  );
}
