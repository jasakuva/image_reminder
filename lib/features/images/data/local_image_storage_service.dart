import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalImageStorageService {
  Future<String> saveReminderImage({
    required String sourcePath,
    required String reminderId,
  }) async {
    final sourceFile = File(sourcePath);
    final imagesDirectory = await _imagesDirectory();
    final extension = _extensionFromPath(sourcePath);
    final targetPath =
        '${imagesDirectory.path}${Platform.pathSeparator}'
        'reminder_$reminderId$extension';

    final targetFile = await sourceFile.copy(targetPath);
    return targetFile.path;
  }

  Future<String> resolveImagePath(String storedPath) async {
    final imageName = _imageName(storedPath);
    final imagesDirectory = await _imagesDirectory();
    return '${imagesDirectory.path}${Platform.pathSeparator}$imageName';
  }

  String storedImageReference(String imagePath) {
    return _imageName(imagePath);
  }

  Future<Directory> _imagesDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final imagesDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}images',
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    return imagesDirectory;
  }

  String _extensionFromPath(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex).toLowerCase();
  }

  String _imageName(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }
}
