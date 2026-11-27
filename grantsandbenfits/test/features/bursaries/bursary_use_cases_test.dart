import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';
import 'package:grantsandbenfits/features/bursaries/data/datasources/local_bursary_data_source.dart';
import 'package:grantsandbenfits/features/bursaries/data/repositories/bursary_repository_impl.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/usecases/bursary_use_cases.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

void main() {
  test('submits bursary application with pre-filled profile and approved docs', () async {
    final store = MemorySecureStore();
    final repo = BursaryRepositoryImpl(LocalBursaryDataSource(store));
    final submit = SubmitBursaryApplication(repo);

    final bursary = LocalBursaryDataSource.catalog.first;
    const profile = UserProfile(
      userId: 'user-1',
      fullName: 'Thabo Mokoena',
      idNumber: '9901015009087',
      streetAddress: '459 Tsitsa Street',
      city: 'Pretoria',
      province: 'Gauteng',
      postalCode: '0048',
    );
    final approvedDocs = [
      DocumentVerificationResult(
        id: 'doc-1',
        fileName: 'id_saps.pdf',
        documentType: DocumentType.southAfricanId,
        verdict: VerificationVerdict.authentic,
        authority: CertifyingAuthority.saps,
        confidence: 0.95,
        scannedAt: DateTime.utc(2026, 11, 27),
        checks: const [],
        extractedSummary: const {},
        explanation: 'Valid SAPS stamp.',
        popiaRedacted: true,
      ),
    ];

    final result = await submit(
      bursary: bursary,
      profile: profile,
      approvedDocuments: approvedDocs,
    );

    expect(result, isA<Ok<BursaryApplication>>());
    final app = (result as Ok<BursaryApplication>).value;
    expect(app.applicantName, 'Thabo Mokoena');
    expect(app.maskedIdNumber, '990101•••••87');
    expect(app.attachedDocumentNames.length, 1);
  });

  test('blocks submission when profile is missing', () async {
    final repo = BursaryRepositoryImpl(
      LocalBursaryDataSource(MemorySecureStore()),
    );
    final submit = SubmitBursaryApplication(repo);

    final result = await submit(
      bursary: LocalBursaryDataSource.catalog.first,
      profile: null,
      approvedDocuments: const [],
    );

    expect(result, isA<Err<BursaryApplication>>());
  });
}
