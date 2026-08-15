import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    if (call.method != 'sharedImageReceived') {
      return;
    }

    final imagePath = call.arguments as String?;
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    sharedImagePath.value = imagePath;
  }

  MethodChannel get _platformChannel {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosChannel
        : _androidChannel;
  }
}
