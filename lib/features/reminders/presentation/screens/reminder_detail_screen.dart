import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/time/date_formatters.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/reminder_store.dart';
import '../../domain/picture_reminder.dart';
import '../../domain/reminder_sound_mode.dart';
import '../../domain/reminder_status.dart';
import 'create_reminder_screen.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: reminderStore,
      builder: (context, _) {
        final reminder = reminderStore.findById(reminderId);

        if (reminder == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.reminderNotFound)),
            body: Center(child: Text(l10n.reminderNoLongerExists)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.reminderDetail),
            actions: [
              if (reminder.status == ReminderStatus.active)
                IconButton(
                  tooltip: l10n.editReminder,
                  onPressed: () => _editReminder(context, reminder),
                  icon: const Icon(Icons.edit_outlined),
                ),
              IconButton(
                tooltip: l10n.delete,
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
                      ? l10n.activeImageReminder
                      : l10n.reminderCompleted,
                  icon: reminder.status == ReminderStatus.active
                      ? Icons.notifications_active_outlined
                      : Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showFullScreenImage(context, reminder),
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
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.event_outlined,
                  title: l10n.scheduled,
                  value: formatReminderDate(reminder.scheduledAt),
                  subtitle: reminder.status == ReminderStatus.active
                      ? formatRelativeReminderTime(reminder.scheduledAt, l10n)
                      : l10n.completed,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.campaign_outlined,
                  title: l10n.notify,
                  value: reminder.notifyText,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: reminder.soundMode == ReminderSoundMode.alarm
                      ? Icons.alarm_outlined
                      : Icons.notifications_outlined,
                  title: l10n.sound,
                  value: _soundModeLabel(reminder.soundMode, l10n),
                ),
                const SizedBox(height: 16),
                if (reminder.status == ReminderStatus.active) ...[
                  FilledButton.icon(
                    onPressed: () => _markCompleted(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.markDone),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showSnoozeOptions(context),
                    icon: const Icon(Icons.snooze_outlined),
                    label: Text(l10n.snoozeRemindAgain),
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
    final l10n = AppLocalizations.of(context)!;
    await reminderStore.markCompleted(reminderId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reminderCompletedSnack)));
    }
  }

  Future<void> _showFullScreenImage(
    BuildContext context,
    PictureReminder reminder,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _FullScreenReminderImage(
          imagePath: reminder.imagePath,
          title: reminder.notifyText,
        ),
      ),
    );
  }

  Future<void> _editReminder(
    BuildContext context,
    PictureReminder reminder,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<_ReminderEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EditReminderSheet(reminder: reminder),
    );

    if (result == null) {
      return;
    }

    await reminderStore.updateReminder(
      reminderId,
      scheduledAt: result.scheduledAt,
      soundMode: result.soundMode,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reminderUpdatedSnack)));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteReminderQuestion),
          content: Text(l10n.deleteReminderDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;

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
                title: Text(l10n.snooze5Minutes),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(minutes: 5)),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.snooze10Minutes),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(minutes: 10)),
              ),
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l10n.snooze1Hour),
                onTap: () =>
                    Navigator.of(context).pop(const Duration(hours: 1)),
              ),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: Text(l10n.tomorrow),
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
      ).showSnackBar(SnackBar(content: Text(l10n.reminderSnoozed)));
    }
  }

  String _soundModeLabel(ReminderSoundMode soundMode, AppLocalizations l10n) {
    return switch (soundMode) {
      ReminderSoundMode.notification => l10n.soundLabelNotification,
      ReminderSoundMode.alarm => l10n.soundLabelAlarm,
    };
  }
}

class _ReminderEditResult {
  const _ReminderEditResult({
    required this.scheduledAt,
    required this.soundMode,
  });

  final DateTime scheduledAt;
  final ReminderSoundMode soundMode;
}

class _FullScreenReminderImage extends StatelessWidget {
  const _FullScreenReminderImage({
    required this.imagePath,
    required this.title,
  });

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditReminderSheet extends StatefulWidget {
  const _EditReminderSheet({required this.reminder});

  final PictureReminder reminder;

  @override
  State<_EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<_EditReminderSheet> {
  late DateTime _scheduledAt;
  late ReminderSoundMode _soundMode;

  @override
  void initState() {
    super.initState();
    _scheduledAt = widget.reminder.scheduledAt;
    _soundMode = widget.reminder.soundMode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l10n.editReminder, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            SoundModeSelector(
              soundMode: _soundMode,
              onChanged: (soundMode) => setState(() => _soundMode = soundMode),
            ),
            const SizedBox(height: 16),
            ReminderTimeSelector(
              scheduledAt: _scheduledAt,
              onChooseDateTime: _chooseDateTime,
              onQuickSelect: (duration) {
                setState(() => _scheduledAt = DateTime.now().add(duration));
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _scheduledAt.isBefore(DateTime.now())
                  ? null
                  : () => Navigator.of(context).pop(
                        _ReminderEditResult(
                          scheduledAt: _scheduledAt,
                          soundMode: _soundMode,
                        ),
                      ),
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseDateTime() async {
    final picked = await pickReminderDateTime(context, _scheduledAt);
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _scheduledAt = picked);
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
