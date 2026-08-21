import 'package:image_picker/image_picker.dart';

class PicturePickerService {
  PicturePickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<XFile?> pickFromGallery() {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 3000,
      maxHeight: 3000,
    );
  }

  Future<XFile?> takePhoto() {
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 3000,
      maxHeight: 3000,
    );
  }
}
