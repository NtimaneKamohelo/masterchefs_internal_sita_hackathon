import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

/// Extracts readable text from uploaded images and PDFs.
abstract interface class DocumentOcrService {
  Future<String> extractText(UploadedDocument document);
}

/// On-device OCR using Google ML Kit on Android/iOS, with pure-Dart fallback
/// for web, desktop, and unit tests.
class MlKitDocumentOcrService implements DocumentOcrService {
  @override
  Future<String> extractText(UploadedDocument document) async {
    final fallbackText = _extractRawText(document.bytes);
    if (document.isSyntheticSample || kIsWeb) {
      return fallbackText;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return fallbackText;
    }

    final lower = document.fileName.toLowerCase();
    Uint8List? imageBytes;
    String extension = 'jpg';

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      imageBytes = document.bytes;
      extension = 'jpg';
    } else if (lower.endsWith('.png')) {
      imageBytes = document.bytes;
      extension = 'png';
    } else if (lower.endsWith('.pdf')) {
      // Scanned PDFs (like SAPS-certified ID scans) typically embed a JPEG
      // image stream between FF D8 FF and FF D9 markers.
      imageBytes = _extractLargestEmbeddedJpeg(document.bytes);
      extension = 'jpg';
    }

    if (imageBytes == null || imageBytes.isEmpty) {
      return fallbackText;
    }

    final ocrText = await _runMlKitOcr(imageBytes, extension);
    if (ocrText.isEmpty) {
      return fallbackText;
    }
    return '$ocrText\n$fallbackText';
  }

  Future<String> _runMlKitOcr(Uint8List imageBytes, String extension) async {
    File? tempFile;
    TextRecognizer? recognizer;
    try {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      tempFile = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}gb_ocr_$timestamp.$extension',
      );
      await tempFile.writeAsBytes(imageBytes, flush: true);

      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognized = await recognizer.processImage(inputImage);
      return recognized.text;
    } catch (_) {
      // Gracefully fall back if ML Kit is unavailable (e.g. unit tests).
      return '';
    } finally {
      await recognizer?.close();
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Extracts the largest embedded JPEG image from a scanned PDF byte stream.
  Uint8List? _extractLargestEmbeddedJpeg(Uint8List pdfBytes) {
    Uint8List? largest;
    var index = 0;
    while (index < pdfBytes.length - 3) {
      if (pdfBytes[index] == 0xFF &&
          pdfBytes[index + 1] == 0xD8 &&
          pdfBytes[index + 2] == 0xFF) {
        var end = index + 3;
        while (end < pdfBytes.length - 1) {
          if (pdfBytes[end] == 0xFF && pdfBytes[end + 1] == 0xD9) {
            final candidate = Uint8List.sublistView(pdfBytes, index, end + 2);
            if (largest == null || candidate.length > largest.length) {
              largest = candidate;
            }
            index = end + 2;
            break;
          }
          end++;
        }
        if (end >= pdfBytes.length - 1) break;
      } else {
        index++;
      }
    }
    return largest;
  }

  String _extractRawText(Uint8List bytes) {
    final slice = bytes.length > 16384
        ? Uint8List.sublistView(bytes, 0, 16384)
        : bytes;
    return latin1.decode(slice, allowInvalid: true);
  }
}
