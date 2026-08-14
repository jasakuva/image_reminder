import 'package:flutter/material.dart';

import 'app.dart';
import 'features/reminders/data/reminder_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final reminderStore = ReminderStore();
  await reminderStore.load();

  runApp(PictureReminderApp(reminderStore: reminderStore));
}
