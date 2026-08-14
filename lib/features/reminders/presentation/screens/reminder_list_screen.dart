import 'package:flutter/material.dart';

import '../../../../core/theme/motorsport_theme.dart';
import '../../data/reminder_store.dart';
import 'create_reminder_screen.dart';
import 'reminder_detail_screen.dart';
import '../widgets/reminder_card.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({required this.reminderStore, super.key});

  final ReminderStore reminderStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ImageReminder')),
      body: RaceScaffoldBackground(
        child: ListenableBuilder(
          listenable: reminderStore,
          builder: (context, _) {
            final reminders = reminderStore.reminders;

            if (reminders.isEmpty) {
              return const _EmptyReminderList();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: reminders.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return RaceHeader(
                    title: '${reminders.length} reminders',
                    subtitle: 'Your image reminders in one clear place',
                  );
                }

                final reminder = reminders[index - 1];
                return ReminderCard(
                  reminder: reminder,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReminderDetailScreen(
                          reminderStore: reminderStore,
                          reminderId: reminder.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CreateReminderScreen(reminderStore: reminderStore),
            ),
          );
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('New reminder'),
      ),
    );
  }
}

class _EmptyReminderList extends StatelessWidget {
  const _EmptyReminderList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 72,
              color: MotorsportColors.pitRed,
            ),
            const SizedBox(height: 16),
            Text(
              'No image reminders yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first reminder by choosing or taking a picture and selecting a time.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MotorsportColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
