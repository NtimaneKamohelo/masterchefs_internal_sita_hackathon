import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/local_ai_document_agent_data_source.dart';
import 'package:grantsandbenfits/features/documents/data/document_audit_logger.dart';
import 'package:grantsandbenfits/features/documents/data/repositories/document_verification_repository_impl.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';
import 'package:grantsandbenfits/features/eligibility/domain/entities/eligibility_assessment.dart';
import 'package:grantsandbenfits/features/eligibility/domain/usecases/evaluate_eligibility.dart';
import 'package:grantsandbenfits/features/profile/data/datasources/local_profile_data_source.dart';
import 'package:grantsandbenfits/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

void main() {
  test('marks validated, review, and not-validated documents and lists POPIA rules', () async {
    final store = MemorySecureStore();
    final profileRepo = ProfileRepositoryImpl(LocalProfileDataSource(store));
    final docRepo = DocumentVerificationRepositoryImpl(
      remote: LocalAiDocumentAgentDataSource(
        simulatedLatency: Duration.zero,
        clock: () => DateTime.utc(2026, 11, 27),
      ),
      audit: DocumentAuditLogger(store),
      store: store,
    );

    await profileRepo.saveProfile(
      const UserProfile(
        userId: 'user-1',
        fullName: 'Thabo Mokoena',
        idNumber: '9901015009087',
        streetAddress: '459 Tsitsa Street',
        city: 'Pretoria',
        province: 'Gauteng',
        postalCode: '0048',
      ),
    );

    final sapsId = Uint8List.fromList(
      utf8.encode('%PDF-1.4\nSAPS CERTIFIED 2026-11-15'),
    );
    await docRepo.verifyDocument(
      UploadedDocument(
        fileName: 'id_saps.pdf',
        sizeBytes: sapsId.length,
        type: DocumentType.southAfricanId,
        bytes: sapsId,
      ),
    );

    final expiredPayslip = Uint8List.fromList(
      utf8.encode('%PDF-1.4\nSAPS CERTIFIED 2026-01-01'),
    );
    await docRepo.verifyDocument(
      UploadedDocument(
        fileName: 'old_payslip.pdf',
        sizeBytes: expiredPayslip.length,
        type: DocumentType.payslip,
        bytes: expiredPayslip,
      ),
    );

    final evaluate = EvaluateEligibility(
      profileRepository: profileRepo,
      documentRepository: docRepo,
    );
    final result = await evaluate('user-1');

    expect(result, isA<Ok<EligibilityAssessment>>());
    final assessment = (result as Ok<EligibilityAssessment>).value;

    final idItem = assessment.documents.firstWhere(
      (d) => d.type == DocumentType.southAfricanId,
    );
    final payslipItem = assessment.documents.firstWhere(
      (d) => d.type == DocumentType.payslip,
    );
    final transcriptItem = assessment.documents.firstWhere(
      (d) => d.type == DocumentType.academicTranscript,
    );

    expect(idItem.status, DocumentCheckStatus.validated);
    expect(payslipItem.status, DocumentCheckStatus.requiresReview);
    expect(transcriptItem.status, DocumentCheckStatus.notValidated);
    expect(assessment.requiresReview, isTrue);
    expect(assessment.popiaRules.length, 6);
  });
}
