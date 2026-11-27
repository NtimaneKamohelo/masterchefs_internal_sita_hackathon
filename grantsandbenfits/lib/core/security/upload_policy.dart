/// File rules for the document step. Storage rules enforce the same limits
/// again on the server.
abstract final class UploadPolicy {
  static const maxBytes = 5 * 1024 * 1024;
  static const allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};

  static String? validate({required String fileName, required int sizeBytes}) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return 'Choose a file.';
    if (trimmed.contains('..') ||
        trimmed.contains('/') ||
        trimmed.contains(r'\')) {
      return 'That file name is not allowed.';
    }
    if (sizeBytes <= 0) return 'The file is empty.';
    if (sizeBytes > maxBytes) return 'Files must be 5 MB or smaller.';
    final dot = trimmed.lastIndexOf('.');
    if (dot <= 0 || dot == trimmed.length - 1) {
      return 'Use a PDF, JPG, or PNG file.';
    }
    final extension = trimmed.substring(dot + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Use a PDF, JPG, or PNG file.';
    }
    return null;
  }
}
