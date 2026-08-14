import 'package:flutter_test/flutter_test.dart';
import 'package:pic_reminder/app.dart';
import 'package:pic_reminder/features/reminders/data/reminder_store.dart';

void main() {
  testWidgets('shows empty reminder list', (tester) async {
    await tester.pumpWidget(PictureReminderApp(reminderStore: ReminderStore()));

    expect(find.text('PIT REMINDER'), findsOneWidget);
    expect(find.text('No reminders on the grid'), findsOneWidget);
    expect(find.text('New reminder'), findsOneWidget);
  });
}
