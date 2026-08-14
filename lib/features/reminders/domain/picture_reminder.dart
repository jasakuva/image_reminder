import 'reminder_sound_mode.dart';
import 'reminder_status.dart';

class PictureReminder {
  const PictureReminder({
    required this.id,
    required this.imagePath,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.snoozeCount,
    required this.notificationId,
    required this.soundMode,
    this.title,
    this.note,
    this.completedAt,
    this.lastSnoozedAt,
  });

  final String id;
  final String? title;
  final String? note;
  final String imagePath;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final ReminderStatus status;
  final int snoozeCount;
  final int notificationId;
  final ReminderSoundMode soundMode;
  final DateTime? lastSnoozedAt;

  bool get isActive => status == ReminderStatus.active;

  String get notifyText {
    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      return trimmedTitle;
    }
    return 'Picture reminder';
  }

  PictureReminder copyWith({
    String? title,
    String? note,
    String? imagePath,
    DateTime? scheduledAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    ReminderStatus? status,
    int? snoozeCount,
    int? notificationId,
    ReminderSoundMode? soundMode,
    DateTime? lastSnoozedAt,
  }) {
    return PictureReminder(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      notificationId: notificationId ?? this.notificationId,
      soundMode: soundMode ?? this.soundMode,
      lastSnoozedAt: lastSnoozedAt ?? this.lastSnoozedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'imagePath': imagePath,
      'scheduledAt': scheduledAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'snoozeCount': snoozeCount,
      'notificationId': notificationId,
      'soundMode': soundMode.name,
      'lastSnoozedAt': lastSnoozedAt?.toIso8601String(),
    };
  }

  factory PictureReminder.fromJson(Map<String, Object?> json) {
    return PictureReminder(
      id: json['id'] as String,
      title: json['title'] as String?,
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: _parseOptionalDate(json['completedAt']),
      status: ReminderStatus.fromName(json['status'] as String? ?? 'active'),
      snoozeCount: json['snoozeCount'] as int? ?? 0,
      notificationId:
          json['notificationId'] as int? ??
          _legacyNotificationId(json['id'] as String),
      soundMode: ReminderSoundMode.fromName(json['soundMode'] as String?),
      lastSnoozedAt: _parseOptionalDate(json['lastSnoozedAt']),
    );
  }

  static int _legacyNotificationId(String id) {
    return id.hashCode.abs() % 2147483647;
  }

  static DateTime? _parseOptionalDate(Object? value) {
    if (value == null || value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
