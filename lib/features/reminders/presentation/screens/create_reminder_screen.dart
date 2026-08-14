import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/time/date_formatters.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../images/data/local_image_storage_service.dart';
import '../../../images/data/picture_picker_service.dart';
import '../../data/reminder_store.dart';
import '../../domain/picture_reminder.dart';
import '../../domain/reminder_sound_mode.dart';
import '../../domain/reminder_status.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({
    required this.reminderStore,
    this.initialImagePath,
    super.key,
  });

  final ReminderStore reminderStore;
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
    return Scaffold(
      appBar: AppBar(title: const Text('New reminder')),
      body: RaceScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const RaceHeader(
              title: 'Create image reminder',
              subtitle: 'Choose an image, message, sound, and time',
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
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.campaign_outlined),
                labelText: 'Notify',
                hintText: 'What should the reminder say?',
              ),
            ),
            const SizedBox(height: 16),
            _SoundModeSelector(
              soundMode: _soundMode,
              onChanged: (soundMode) => setState(() => _soundMode = soundMode),
            ),
            const SizedBox(height: 16),
            _ReminderTimeSelector(
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
              label: const Text('Save reminder'),
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
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt.isBefore(now) ? now : _scheduledAt,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveReminder() async {
    final selectedImagePath = _selectedImagePath;
    if (selectedImagePath == null) {
      _showSnackBar('Choose or take a picture first.');
      return;
    }

    if (!_scheduledAt.isAfter(DateTime.now())) {
      _showSnackBar('Choose a reminder time in the future.');
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
        _showSnackBar('Could not save reminder: $error');
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

class _SoundModeSelector extends StatelessWidget {
  const _SoundModeSelector({required this.soundMode, required this.onChanged});

  final ReminderSoundMode soundMode;
  final ValueChanged<ReminderSoundMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Text('Sound', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ReminderSoundMode>(
              segments: const [
                ButtonSegment(
                  value: ReminderSoundMode.notification,
                  icon: Icon(Icons.notifications_outlined),
                  label: Text('Notification'),
                ),
                ButtonSegment(
                  value: ReminderSoundMode.alarm,
                  icon: Icon(Icons.alarm_outlined),
                  label: Text('Alarm'),
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
                  label: const Text('Choose picture'),
                ),
                OutlinedButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTimeSelector extends StatelessWidget {
  const _ReminderTimeSelector({
    required this.scheduledAt,
    required this.onChooseDateTime,
    required this.onQuickSelect,
  });

  final DateTime scheduledAt;
  final VoidCallback onChooseDateTime;
  final ValueChanged<Duration> onQuickSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Text('Reminder time', style: theme.textTheme.titleMedium),
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
                  label: const Text('10 min'),
                  onPressed: () => onQuickSelect(const Duration(minutes: 10)),
                ),
                ActionChip(
                  label: const Text('1 hour'),
                  onPressed: () => onQuickSelect(const Duration(hours: 1)),
                ),
                ActionChip(
                  label: const Text('Tomorrow'),
                  onPressed: () => onQuickSelect(const Duration(days: 1)),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Custom'),
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
