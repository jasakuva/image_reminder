import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PendingReminderImport {
  PendingReminderImport({
    required this.fileName,
    required this.id,
    required this.imagePath,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.snoozeCount,
    required this.notificationId,
    required this.soundMode,
    required this.notificationScheduled,
    required this.source,
    this.title,
    this.note,
    this.completedAt,
    this.lastSnoozedAt,
  });

  final String fileName;
  final String id;
  final String? title;
  final String? note;
  final String imagePath;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String status;
  final int snoozeCount;
  final int notificationId;
  final String soundMode;
  final DateTime? lastSnoozedAt;
  final bool notificationScheduled;
  final String source;

  factory PendingReminderImport.fromMap(Map<Object?, Object?> map) {
    DateTime? parseOptionalDate(Object? value) {
      if (value is! String || value.isEmpty) {
        return null;
      }
      return DateTime.parse(value);
    }

    return PendingReminderImport(
      fileName: map['fileName'] as String,
      id: map['id'] as String,
      title: map['title'] as String?,
      note: map['note'] as String?,
      imagePath: map['imagePath'] as String,
      scheduledAt: DateTime.parse(map['scheduledAt'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      completedAt: parseOptionalDate(map['completedAt']),
      status: map['status'] as String? ?? 'active',
      snoozeCount: (map['snoozeCount'] as num?)?.toInt() ?? 0,
      notificationId: (map['notificationId'] as num?)?.toInt() ?? 0,
      soundMode: map['soundMode'] as String? ?? 'notification',
      lastSnoozedAt: parseOptionalDate(map['lastSnoozedAt']),
      notificationScheduled: map['notificationScheduled'] as bool? ?? false,
      source: map['source'] as String? ?? 'unknown',
    );
  }
}

class SharedImageReceiver {
  SharedImageReceiver() {
    _platformChannel.setMethodCallHandler(_handleMethodCall);
  }

  static const _androidChannel = MethodChannel(
    'com.example.pic_reminder/shared_images',
  );
  static const _iosChannel = MethodChannel(
    'com.jasapart.ireminder/shared_images',
  );

  final ValueNotifier<String?> sharedImagePath = ValueNotifier(null);
  final ValueNotifier<List<PendingReminderImport>> pendingReminderImports =
      ValueNotifier<List<PendingReminderImport>>(<PendingReminderImport>[]);

  Future<void> loadInitialSharedImage() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final String? imagePath;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final maps = await _platformChannel.invokeMethod<List<Object?>>(
          'fetchPendingReminderImports',
        );
        if (maps == null || maps.isEmpty) {
          return;
        }

        pendingReminderImports.value = maps
            .whereType<Map<Object?, Object?>>()
            .map(PendingReminderImport.fromMap)
            .toList(growable: false);
        return;
      }

      imagePath = await _platformChannel.invokeMethod<String?>(
        'getInitialSharedImage',
      );
    } on MissingPluginException {
      return;
    }

    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    sharedImagePath.value = imagePath;
  }

  void clearSharedImage() {
    sharedImagePath.value = null;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'sharedImageReceived') {
      final imagePath = call.arguments as String?;
      if (imagePath == null || imagePath.isEmpty) {
        return;
      }

      sharedImagePath.value = imagePath;
    }
  }

  Future<void> markPendingReminderImported(String fileName) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await _platformChannel.invokeMethod<void>('markPendingReminderImported', {
      'fileName': fileName,
    });
  }

  MethodChannel get _platformChannel {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosChannel
        : _androidChannel;
  }
}
