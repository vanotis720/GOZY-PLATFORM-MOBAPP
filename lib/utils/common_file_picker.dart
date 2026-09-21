import 'package:file_picker/file_picker.dart';

class CommonFilePicker {
  static Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    int? compressionQuality,
    bool withReadStream = false,
    void Function(FilePickerStatus)? onFileLoading,
  }) {
    return FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      compressionQuality: compressionQuality??0,
      withReadStream: withReadStream,
      onFileLoading: onFileLoading,
    );
  }
}