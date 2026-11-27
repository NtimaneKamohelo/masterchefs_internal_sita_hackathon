import 'dart:convert';

import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';

class LocalBursaryDataSource {
  LocalBursaryDataSource(this._store);

  final SecureStore _store;

  static const List<BursaryProgram> catalog = [
    BursaryProgram(
      id: 'sita-internal-2026',
      name: 'SITA Internal Bursary',
      provider: 'State Information Technology Agency (SITA)',
      summary:
          'Supports South African citizens pursuing ICT, Computer Science, Cybersecurity, and Data Science qualifications.',
      coverage: 'Tuition, prescribed textbooks, and registration fees',
      closingDate: '31 January 2027',
      requiredDocuments: [
        DocumentType.southAfricanId,
        DocumentType.academicTranscript,
        DocumentType.proofOfResidence,
      ],
      eligibilityRules: [
        'South African citizen with a valid 13-digit SA ID.',
        'All supporting documents certified by SAPS or Post Office within 90 days.',
        'Minimum 65% average on latest academic transcript.',
      ],
    ),
    BursaryProgram(
      id: 'nsfas-2026',
      name: 'NSFAS Bursary Scheme',
      provider: 'National Student Financial Aid Scheme (NSFAS)',
      summary:
          'Nationwide public higher-education funding for eligible South African students at public universities and TVET colleges.',
      coverage: 'Full tuition, accommodation, transport, and learning materials',
      closingDate: '15 February 2027',
      requiredDocuments: [
        DocumentType.southAfricanId,
        DocumentType.payslip,
        DocumentType.proofOfResidence,
      ],
      eligibilityRules: [
        'South African citizen with combined annual household income <= R350,000 (or <= R600,000 for applicants living with a disability).',
        'Certified SA ID and household proof of income (SAPS or Post Office).',
        'No application is declined automatically; an official verifies all cases.',
      ],
    ),
  ];

  Future<List<BursaryProgram>> readBursaries() async => catalog;

  Future<List<BursaryApplication>> readApplications(String userId) async {
    final raw = await _store.read(StorageKeys.bursaryApplications(userId));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final items = <BursaryApplication>[];
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final docs = entry['attachedDocumentNames'];
      items.add(
        BursaryApplication(
          id: entry['id'] as String? ?? '',
          bursaryId: entry['bursaryId'] as String? ?? '',
          bursaryName: entry['bursaryName'] as String? ?? '',
          userId: userId,
          applicantName: entry['applicantName'] as String? ?? '',
          maskedIdNumber: entry['maskedIdNumber'] as String? ?? '',
          formattedAddress: entry['formattedAddress'] as String? ?? '',
          attachedDocumentNames: docs is List
              ? [for (final d in docs) '$d']
              : const [],
          submittedAt:
              DateTime.tryParse(entry['submittedAt'] as String? ?? '') ??
              DateTime.now().toUtc(),
          status:
              entry['status'] as String? ??
              'Submitted — Pending Official Review',
        ),
      );
    }
    return items;
  }

  Future<BursaryApplication> writeApplication(
    BursaryApplication application,
  ) async {
    final existing = await readApplications(application.userId);
    final updated = [
      application,
      ...existing.where((item) => item.bursaryId != application.bursaryId),
    ];
    await _store.write(
      StorageKeys.bursaryApplications(application.userId),
      jsonEncode([
        for (final item in updated)
          {
            'id': item.id,
            'bursaryId': item.bursaryId,
            'bursaryName': item.bursaryName,
            'applicantName': item.applicantName,
            'maskedIdNumber': item.maskedIdNumber,
            'formattedAddress': item.formattedAddress,
            'attachedDocumentNames': item.attachedDocumentNames,
            'submittedAt': item.submittedAt.toUtc().toIso8601String(),
            'status': item.status,
          },
      ]),
    );
    return application;
  }
}
