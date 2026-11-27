import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';

class UploadedDocument extends Equatable {
  const UploadedDocument({
    required this.fileName,
    required this.sizeBytes,
    required this.type,
    required this.bytes,
    this.isSyntheticSample = false,
  });

  final String fileName;
  final int sizeBytes;
  final DocumentType type;
  final Uint8List bytes;
  final bool isSyntheticSample;

  @override
  List<Object?> get props => [
    fileName,
    sizeBytes,
    type,
    bytes.length,
    isSyntheticSample,
  ];
}
