import 'package:equatable/equatable.dart';

class BursaryApplication extends Equatable {
  const BursaryApplication({
    required this.id,
    required this.bursaryId,
    required this.bursaryName,
    required this.userId,
    required this.applicantName,
    required this.maskedIdNumber,
    required this.formattedAddress,
    required this.attachedDocumentNames,
    required this.submittedAt,
    this.status = 'Submitted — Pending Official Review',
  });

  final String id;
  final String bursaryId;
  final String bursaryName;
  final String userId;
  final String applicantName;
  final String maskedIdNumber;
  final String formattedAddress;
  final List<String> attachedDocumentNames;
  final DateTime submittedAt;
  final String status;

  @override
  List<Object?> get props => [
    id,
    bursaryId,
    bursaryName,
    userId,
    applicantName,
    maskedIdNumber,
    formattedAddress,
    attachedDocumentNames,
    submittedAt,
    status,
  ];
}
