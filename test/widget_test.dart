import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pic_reminder/app.dart';
import 'package:pic_reminder/features/billing/data/premium_access_store.dart';
import 'package:pic_reminder/features/reminders/data/reminder_store.dart';

void main() {
  testWidgets('shows empty reminder list', (tester) async {
    await tester.pumpWidget(
      PictureReminderApp(
        reminderStore: ReminderStore(),
        premiumAccessStore: PremiumAccessStore(),
      ),
    );

    expect(find.text('ImageReminder'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text('No image reminders yet'), findsOneWidget);
    expect(find.text('New reminder'), findsOneWidget);
  });

  testWidgets('opens settings and info screen', (tester) async {
    await tester.pumpWidget(
      PictureReminderApp(
        reminderStore: ReminderStore(),
        premiumAccessStore: PremiumAccessStore(),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings & Info'), findsOneWidget);
    expect(find.text('JASAPART image reminder software'), findsOneWidget);
    expect(find.text('Version information'), findsOneWidget);
  });
}
