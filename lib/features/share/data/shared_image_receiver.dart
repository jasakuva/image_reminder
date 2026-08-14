import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SharedImageReceiver {
  SharedImageReceiver() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const _channel = MethodChannel(
    'com.example.pic_reminder/shared_images',
  );

  final ValueNotifier<String?> sharedImagePath = ValueNotifier(null);

  Future<void> loadInitialSharedImage() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final imagePath = await _channel.invokeMethod<String?>(
      'getInitialSharedImage',
    );
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    sharedImagePath.value = imagePath;
  }

  void clearSharedImage() {
    sharedImagePath.value = null;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'sharedImageReceived') {
      return;
    }

    final imagePath = call.arguments as String?;
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    sharedImagePath.value = imagePath;
  }
}
