import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/local_ai_document_agent_data_source.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 27);
  final agent = LocalAiDocumentAgentDataSource(
    simulatedLatency: Duration.zero,
    clock: () => fixedNow,
  );

  Uint8List pdfBytes(String text) =>
      Uint8List.fromList(utf8.encode('%PDF-1.4\n$text'));

  test('marks SAPS-certified document within 90 days as authentic and masks ID', () async {
    final bytes = pdfBytes(
      'SOUTH AFRICAN POLICE SERVICE SAPS CERTIFIED 2026-11-10 ID 9901015009087',
    );
    final result = await agent.analyze(
      UploadedDocument(
        fileName: 'id_saps.pdf',
        sizeBytes: bytes.length,
        type: DocumentType.southAfricanId,
        bytes: bytes,
      ),
    );

    expect(result.verdict, VerificationVerdict.authentic);
    expect(result.authority, CertifyingAuthority.saps);
    expect(result.popiaRedacted, isTrue);
    expect(
      result.extractedSummary['ID reference (POPIA masked)'],
      '990101•••••87',
    );
  });

  test('marks Post Office-certified document as authentic', () async {
    final bytes = pdfBytes(
      'SOUTH AFRICAN POST OFFICE SAPO CERTIFIED 2026-11-20',
    );
    final result = await agent.analyze(
      UploadedDocument(
        fileName: 'payslip_post_office.pdf',
        sizeBytes: bytes.length,
        type: DocumentType.payslip,
        bytes: bytes,
      ),
    );

    expect(result.verdict, VerificationVerdict.authentic);
    expect(result.authority, CertifyingAuthority.postOffice);
  });

  test('flags uncertified document as not authentic', () async {
    final bytes = pdfBytes('ACADEMIC TRANSCRIPT NO STAMP');
    final result = await agent.analyze(
      UploadedDocument(
        fileName: 'transcript.pdf',
        sizeBytes: bytes.length,
        type: DocumentType.academicTranscript,
        bytes: bytes,
      ),
    );

    expect(result.verdict, VerificationVerdict.notAuthentic);
    expect(result.authority, CertifyingAuthority.none);
  });

  test('flags expired SAPS certification as needs review', () async {
    final bytes = pdfBytes('SAPS CERTIFIED 2026-01-01');
    final result = await agent.analyze(
      UploadedDocument(
        fileName: 'old_saps.pdf',
        sizeBytes: bytes.length,
        type: DocumentType.proofOfResidence,
        bytes: bytes,
      ),
    );

    expect(result.verdict, VerificationVerdict.needsReview);
    expect(result.authority, CertifyingAuthority.saps);
  });

  test('flags invalid file header bytes as not authentic', () async {
    final badBytes = Uint8List.fromList(utf8.encode('NOT_A_REAL_PDF SAPS'));
    final result = await agent.analyze(
      UploadedDocument(
        fileName: 'fake.pdf',
        sizeBytes: badBytes.length,
        type: DocumentType.southAfricanId,
        bytes: badBytes,
      ),
    );

    expect(result.verdict, VerificationVerdict.notAuthentic);
  });
}
