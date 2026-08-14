import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/time/date_formatters.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../data/reminder_store.dart';
import '../../domain/reminder_sound_mode.dart';
import '../../domain/reminder_status.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({
    required this.reminderStore,
    required this.reminderId,
    super.key,
  });

  final ReminderStore reminderStore;
  final String reminderId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: reminderStore,
      builder: (context, _) {
        final reminder = reminderStore.findById(reminderId);

        if (reminder == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reminder not found')),
            body: const Center(child: Text('This reminder no longer exists.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reminder detail'),
            actions: [
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: RaceScaffoldBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                RaceHeader(
                  title: reminder.notifyText,
                  subtitle: reminder.status == ReminderStatus.active
                      ? 'Active image reminder'
                      : 'Reminder completed',
                  icon: reminder.status == ReminderStatus.active
                      ? Icons.notifications_active_outlined
                      : Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(reminder.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ColoredBox(
                          color: MotorsportColors.carbon,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined, size: 56),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.event_outlined,
                  title: 'Scheduled',
                  value: formatReminderDate(reminder.scheduledAt),
                  subtitle: reminder.status == ReminderStatus.active
                      ? formatRelativeReminderTime(reminder.scheduledAt)
                      : 'Completed',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.campaign_outlined,
                  title: 'Notify',
                  value: reminder.notifyText,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: reminder.soundMode == ReminderSoundMode.alarm
                      ? Icons.alarm_outlined
                      : Icons.notifications_outlined,
                  title: 'Sound',
                  value: _soundModeLabel(reminder.soundMode),
                ),
                const SizedBox(height: 16),
                if (reminder.status == ReminderStatus.active) ...[
                  FilledButton.icon(
                    onPressed: () => _markCompleted(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark done'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showSnoozeOptions(context),
                    icon: const Icon(Icons.snooze_outlined),
                    label: const Text('Snooze / remind again'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markCompleted(BuildContext context) async {
    await reminderStore.markCompleted(reminderId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder completed.')));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete reminder?'),
          content: const Text(
            'This deletes the reminder and its locally stored picture.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await reminderStore.delete(reminderId);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSnoozeOptions(BuildContext context) async {
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('5 minutes'),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(minutes: 5)),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('10 minutes'),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(minutes: 10)),
              ),
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('1 hour'),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(hours: 1)),
              ),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: const Text('Tomorrow'),
                onTap: () => Navigator.of(context).pop(const Duration(days: 1)),
              ),
            ],
          ),
        );
      },
    );

    if (duration == null) {
      return;
    }

    await reminderStore.snooze(reminderId, duration);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder snoozed.')));
    }
  }

  String _soundModeLabel(ReminderSoundMode soundMode) {
    return switch (soundMode) {
      ReminderSoundMode.notification => 'Notification sound',
      ReminderSoundMode.alarm => 'Alarm sound',
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: MotorsportColors.pitRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MotorsportColors.racingYellow,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
