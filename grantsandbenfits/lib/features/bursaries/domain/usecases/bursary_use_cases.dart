import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/utils/id_generator.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';
import 'package:grantsandbenfits/features/bursaries/domain/repositories/bursary_repository.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/repositories/profile_repository.dart';

class BursariesDashboardData {
  const BursariesDashboardData({
    required this.bursaries,
    required this.applications,
    required this.approvedDocuments,
    this.profile,
  });

  final List<BursaryProgram> bursaries;
  final List<BursaryApplication> applications;
  final List<DocumentVerificationResult> approvedDocuments;
  final UserProfile? profile;
}

class LoadBursariesDashboard {
  const LoadBursariesDashboard({
    required BursaryRepository bursaryRepository,
    required ProfileRepository profileRepository,
    required DocumentVerificationRepository documentRepository,
  }) : _bursaries = bursaryRepository,
       _profiles = profileRepository,
       _documents = documentRepository;

  final BursaryRepository _bursaries;
  final ProfileRepository _profiles;
  final DocumentVerificationRepository _documents;

  Future<Result<BursariesDashboardData>> call(String userId) async {
    final bursariesResult = await _bursaries.loadBursaries();
    if (bursariesResult is Err<List<BursaryProgram>>) {
      return Err(bursariesResult.failure);
    }

    final appsResult = await _bursaries.loadApplications(userId);
    final profileResult = await _profiles.loadProfile(userId);
    final approvedDocs = await _documents.loadApprovedDocuments();

    return Ok(
      BursariesDashboardData(
        bursaries: (bursariesResult as Ok<List<BursaryProgram>>).value,
        applications: appsResult is Ok<List<BursaryApplication>>
            ? appsResult.value
            : const [],
        approvedDocuments: approvedDocs,
        profile: profileResult is Ok<UserProfile?> ? profileResult.value : null,
      ),
    );
  }
}

class SubmitBursaryApplication {
  const SubmitBursaryApplication(this._repository);

  final BursaryRepository _repository;

  Future<Result<BursaryApplication>> call({
    required BursaryProgram bursary,
    required UserProfile? profile,
    required List<DocumentVerificationResult> approvedDocuments,
  }) async {
    if (profile == null) {
      return const Err(
        ValidationFailure(
          'Complete and save your Applicant Profile first so it can be pre-filled.',
        ),
      );
    }

    final matchingDocs = approvedDocuments
        .where((doc) => bursary.requiredDocuments.contains(doc.documentType))
        .toList();

    if (matchingDocs.isEmpty) {
      return const Err(
        ValidationFailure(
          'Scan and verify at least one required SAPS/Post Office certified document first.',
        ),
      );
    }

    final application = BursaryApplication(
      id: createSecureId(),
      bursaryId: bursary.id,
      bursaryName: bursary.name,
      userId: profile.userId,
      applicantName: profile.fullName,
      maskedIdNumber: profile.maskedIdNumber,
      formattedAddress: profile.formattedAddress,
      attachedDocumentNames: [
        for (final doc in matchingDocs)
          '${doc.documentType.label} (${doc.fileName})',
      ],
      submittedAt: DateTime.now().toUtc(),
    );

    return _repository.submitApplication(application);
  }
}
