import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SharedImport {
  SharedImport({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    required this.source,
  });

  final String id;
  final String imagePath;
  final DateTime createdAt;
  final String source;

  factory SharedImport.fromMap(Map<Object?, Object?> map) {
    return SharedImport(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (((map['createdAt'] as num?) ?? 0) * 1000).round(),
      ),
      source: (map['source'] as String?) ?? 'unknown',
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

  Future<void> loadInitialSharedImage() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final String? imagePath;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _platformChannel.invokeMethod<void>('markFlutterReadyForSharedImport');
        final map = await _platformChannel.invokeMethod<Map<Object?, Object?>>(
          'getInitialSharedImport',
        );
        if (map == null) {
          return;
        }

        final sharedImport = SharedImport.fromMap(map);
        sharedImagePath.value = sharedImport.imagePath;
        await _markImportConsumed(sharedImport.id);
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
    if (call.method == 'sharedImportReceived') {
      final map = call.arguments as Map<Object?, Object?>?;
      if (map == null) {
        return;
      }

      final sharedImport = SharedImport.fromMap(map);
      sharedImagePath.value = sharedImport.imagePath;
      await _markImportConsumed(sharedImport.id);
      return;
    }

    if (call.method == 'sharedImageReceived') {
      final imagePath = call.arguments as String?;
      if (imagePath == null || imagePath.isEmpty) {
        return;
      }

      sharedImagePath.value = imagePath;
    }
  }

  Future<void> _markImportConsumed(String id) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await _platformChannel.invokeMethod<void>('markSharedImportConsumed', {
      'id': id,
    });
  }

  MethodChannel get _platformChannel {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosChannel
        : _androidChannel;
  }
}
