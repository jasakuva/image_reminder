import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/time/date_formatters.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../billing/data/premium_access_store.dart';
import '../../../billing/presentation/widgets/upgrade_prompt.dart';
import '../../../images/data/local_image_storage_service.dart';
import '../../../images/data/picture_picker_service.dart';
import '../../data/reminder_store.dart';
import '../../domain/picture_reminder.dart';
import '../../domain/reminder_sound_mode.dart';
import '../../domain/reminder_status.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({
    required this.reminderStore,
    required this.premiumAccessStore,
    this.initialImagePath,
    super.key,
  });

  final ReminderStore reminderStore;
  final PremiumAccessStore premiumAccessStore;
  final String? initialImagePath;

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _notifyController = TextEditingController();
  final _pickerService = PicturePickerService();
  final _imageStorageService = LocalImageStorageService();
  final _uuid = const Uuid();

  String? _selectedImagePath;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  ReminderSoundMode _soundMode = ReminderSoundMode.notification;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _notifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReminderTitle)),
      body: RaceScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            RaceHeader(
              title: l10n.createImageReminder,
              subtitle: l10n.createImageReminderSubtitle,
              icon: Icons.add_photo_alternate_outlined,
            ),
            const SizedBox(height: 16),
            _ImageSelector(
              imagePath: _selectedImagePath,
              onPickGallery: _pickFromGallery,
              onTakePhoto: _takePhoto,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notifyController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.campaign_outlined),
                labelText: l10n.notify,
                hintText: l10n.notifyHint,
              ),
            ),
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
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveReminder,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_active_outlined),
              label: Text(l10n.saveReminder),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final image = await _pickerService.pickFromGallery();
    if (image == null || !mounted) {
      return;
    }
    setState(() => _selectedImagePath = image.path);
  }

  Future<void> _takePhoto() async {
    final image = await _pickerService.takePhoto();
    if (image == null || !mounted) {
      return;
    }
    setState(() => _selectedImagePath = image.path);
  }

  Future<void> _chooseDateTime() async {
    final picked = await pickReminderDateTime(context, _scheduledAt);
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _scheduledAt = picked);
  }

  Future<void> _saveReminder() async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.reminderStore.hasReachedFreeReminderLimit(widget.premiumAccessStore.isPremium)) {
      await showUpgradePrompt(
        context,
        premiumAccessStore: widget.premiumAccessStore,
      );
      return;
    }

    final selectedImagePath = _selectedImagePath;
    if (selectedImagePath == null) {
      _showSnackBar(l10n.choosePictureFirst);
      return;
    }

    if (_scheduledAt.isBefore(DateTime.now())) {
      _showSnackBar(l10n.futureReminderTime);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final id = _uuid.v4();
      final notificationId = DateTime.now().microsecondsSinceEpoch.remainder(
        2147483647,
      );
      final storedImagePath = await _imageStorageService.saveReminderImage(
        sourcePath: selectedImagePath,
        reminderId: id,
      );
      final now = DateTime.now();
      final reminder = PictureReminder(
        id: id,
        title: _notifyController.text.trim().isEmpty
            ? null
            : _notifyController.text.trim(),
        imagePath: storedImagePath,
        scheduledAt: _scheduledAt,
        createdAt: now,
        updatedAt: now,
        status: ReminderStatus.active,
        snoozeCount: 0,
        notificationId: notificationId,
        soundMode: _soundMode,
      );

      await widget.reminderStore.add(reminder);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar(l10n.couldNotSaveReminder(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<DateTime?> pickReminderDateTime(
  BuildContext context,
  DateTime initialDateTime,
) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initialDateTime.isBefore(now) ? now : initialDateTime,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365 * 5)),
  );
  if (date == null || !context.mounted) {
    return null;
  }

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDateTime),
  );
  if (time == null || !context.mounted) {
    return null;
  }

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

class SoundModeSelector extends StatelessWidget {
  const SoundModeSelector({
    required this.soundMode,
    required this.onChanged,
    super.key,
  });

  final ReminderSoundMode soundMode;
  final ValueChanged<ReminderSoundMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.volume_up_outlined,
                  color: MotorsportColors.pitRed,
                ),
                const SizedBox(width: 8),
                Text(l10n.sound, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ReminderSoundMode>(
              segments: [
                ButtonSegment(
                  value: ReminderSoundMode.notification,
                  icon: const Icon(Icons.notifications_outlined),
                  label: Text(l10n.notification),
                ),
                ButtonSegment(
                  value: ReminderSoundMode.alarm,
                  icon: const Icon(Icons.alarm_outlined),
                  label: Text(l10n.alarm),
                ),
              ],
              selected: {soundMode},
              onSelectionChanged: (selected) => onChanged(selected.single),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSelector extends StatelessWidget {
  const _ImageSelector({
    required this.imagePath,
    required this.onPickGallery,
    required this.onTakePhoto,
  });

  final String? imagePath;
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imagePath == null
                ? const ColoredBox(
                    color: MotorsportColors.carbon,
                    child: Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60,
                        color: MotorsportColors.muted,
                      ),
                    ),
                  )
                : Image.file(File(imagePath!), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onPickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.choosePicture),
                ),
                OutlinedButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.takePhoto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderTimeSelector extends StatelessWidget {
  const ReminderTimeSelector({
    required this.scheduledAt,
    required this.onChooseDateTime,
    required this.onQuickSelect,
    super.key,
  });

  final DateTime scheduledAt;
  final VoidCallback onChooseDateTime;
  final ValueChanged<Duration> onQuickSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: MotorsportColors.pitRed,
                ),
                const SizedBox(width: 8),
                Text(l10n.reminderTime, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatReminderDate(scheduledAt),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: MotorsportColors.racingYellow,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: Text(l10n.tenMinutes),
                  onPressed: () => onQuickSelect(const Duration(minutes: 10)),
                ),
                ActionChip(
                  label: Text(l10n.snooze1Hour),
                  onPressed: () => onQuickSelect(const Duration(hours: 1)),
                ),
                ActionChip(
                  label: Text(l10n.tomorrow),
                  onPressed: () => onQuickSelect(const Duration(days: 1)),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(l10n.custom),
                  onPressed: onChooseDateTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
