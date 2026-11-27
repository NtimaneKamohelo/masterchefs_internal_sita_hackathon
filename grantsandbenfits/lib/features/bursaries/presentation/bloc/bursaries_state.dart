import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

class BursariesState extends Equatable {
  const BursariesState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.bursaries = const [],
    this.applications = const [],
    this.approvedDocuments = const [],
    this.profile,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final List<BursaryProgram> bursaries;
  final List<BursaryApplication> applications;
  final List<DocumentVerificationResult> approvedDocuments;
  final UserProfile? profile;
  final String? errorMessage;
  final String? infoMessage;

  bool hasApplied(String bursaryId) =>
      applications.any((app) => app.bursaryId == bursaryId);

  BursariesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<BursaryProgram>? bursaries,
    List<BursaryApplication>? applications,
    List<DocumentVerificationResult>? approvedDocuments,
    UserProfile? profile,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return BursariesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      bursaries: bursaries ?? this.bursaries,
      applications: applications ?? this.applications,
      approvedDocuments: approvedDocuments ?? this.approvedDocuments,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    bursaries,
    applications,
    approvedDocuments,
    profile,
    errorMessage,
    infoMessage,
  ];
}
