import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pic_reminder/app.dart';
import 'package:pic_reminder/features/reminders/data/reminder_store.dart';

void main() {
  testWidgets('shows empty reminder list', (tester) async {
    await tester.pumpWidget(PictureReminderApp(reminderStore: ReminderStore()));

    expect(find.text('ImageReminder'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text('No image reminders yet'), findsOneWidget);
    expect(find.text('New reminder'), findsOneWidget);
  });

  testWidgets('opens settings and info screen', (tester) async {
    await tester.pumpWidget(PictureReminderApp(reminderStore: ReminderStore()));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings & Info'), findsOneWidget);
    expect(find.text('JASAPRT image reminder software'), findsOneWidget);
    expect(find.text('Version information'), findsOneWidget);
  });
}
