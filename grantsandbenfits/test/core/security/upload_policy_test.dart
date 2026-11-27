import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/upload_policy.dart';

void main() {
  test('accepts a small pdf and rejects unsafe files', () {
    expect(
      UploadPolicy.validate(fileName: 'transcript.pdf', sizeBytes: 1200),
      isNull,
    );
    expect(
      UploadPolicy.validate(fileName: 'notes.exe', sizeBytes: 1200),
      isNotNull,
    );
    expect(
      UploadPolicy.validate(fileName: '../secret.pdf', sizeBytes: 1200),
      isNotNull,
    );
    expect(
      UploadPolicy.validate(fileName: 'large.pdf', sizeBytes: UploadPolicy.maxBytes + 1),
      isNotNull,
    );
  });
}
