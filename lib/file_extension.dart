import 'dart:io';

enum FileType {
  video,
  image,
  unknown;
}

extension FileTypeChecker on File {
  FileType _getFileType() {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'm4v':
      case '3gp':
        return FileType.video;

      case 'jpg':
      case 'jpeg':
      case 'png':
        return FileType.image;

      default:
        return FileType.unknown;
    }
  }

  FileType get fileType => _getFileType();
}
