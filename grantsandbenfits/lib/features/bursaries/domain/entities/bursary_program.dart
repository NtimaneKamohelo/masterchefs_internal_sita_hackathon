import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';

class BursaryProgram extends Equatable {
  const BursaryProgram({
    required this.id,
    required this.name,
    required this.provider,
    required this.summary,
    required this.coverage,
    required this.closingDate,
    required this.requiredDocuments,
    required this.eligibilityRules,
  });

  final String id;
  final String name;
  final String provider;
  final String summary;
  final String coverage;
  final String closingDate;
  final List<DocumentType> requiredDocuments;
  final List<String> eligibilityRules;

  @override
  List<Object?> get props => [
    id,
    name,
    provider,
    summary,
    coverage,
    closingDate,
    requiredDocuments,
    eligibilityRules,
  ];
}
