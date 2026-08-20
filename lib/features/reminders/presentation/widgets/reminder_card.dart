import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/time/date_formatters.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/picture_reminder.dart';
import '../../domain/reminder_sound_mode.dart';
import '../../domain/reminder_status.dart';

class ReminderCard extends StatefulWidget {
  const ReminderCard({required this.reminder, required this.onTap, super.key});

  final PictureReminder reminder;
  final VoidCallback onTap;

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant ReminderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.id != widget.reminder.id ||
        oldWidget.reminder.status != widget.reminder.status ||
        oldWidget.reminder.scheduledAt != widget.reminder.scheduledAt) {
      _startRefreshTimer();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    if (widget.reminder.status != ReminderStatus.active) {
      return;
    }

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = widget.reminder;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: MotorsportColors.pitRed),
              SizedBox(
                width: 104,
                height: 112,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                      Image.file(
                      File(reminder.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: MotorsportColors.carbon,
                          child: Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reminder.notifyText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatReminderDate(reminder.scheduledAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MotorsportColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniBadge(
                            icon: reminder.status == ReminderStatus.active
                                ? Icons.speed_outlined
                                : Icons.flag_outlined,
                            text: reminder.status == ReminderStatus.active
                                 ? formatRelativeReminderTime(reminder.scheduledAt, l10n)
                                : l10n.completed,
                            color: reminder.status == ReminderStatus.active
                                ? MotorsportColors.pitRed
                                : MotorsportColors.muted,
                          ),
                          _MiniBadge(
                            icon: reminder.soundMode == ReminderSoundMode.alarm
                                ? Icons.alarm_outlined
                                : Icons.notifications_outlined,
                            text: reminder.soundMode == ReminderSoundMode.alarm
                                ? l10n.alarm
                                : l10n.notification,
                            color: reminder.soundMode == ReminderSoundMode.alarm
                                ? MotorsportColors.racingYellow
                                : MotorsportColors.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right, color: MotorsportColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
