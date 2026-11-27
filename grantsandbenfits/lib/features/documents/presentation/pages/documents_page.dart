import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_bloc.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_event.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_state.dart';
import 'package:grantsandbenfits/features/documents/presentation/widgets/verification_result_card.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  Future<void> _pickAndScan(BuildContext context, DocumentType type) async {
    final bloc = context.read<DocumentVerificationBloc>();
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final sizeBytes = file.lengthSync() ?? await file.length() ?? bytes.length;

    bloc.add(
      DocumentScanRequested(
        UploadedDocument(
          fileName: file.name,
          sizeBytes: sizeBytes,
          type: type,
          bytes: bytes,
        ),
      ),
    );
  }

  void _scanSyntheticSample(
      BuildContext context, {
        required String fileName,
        required DocumentType type,
        required String sampleContent,
      }) {
    final bytes = Uint8List.fromList(utf8.encode('%PDF-1.4\n$sampleContent'));
    context.read<DocumentVerificationBloc>().add(
      DocumentScanRequested(
        UploadedDocument(
          fileName: fileName,
          sizeBytes: bytes.length,
          type: type,
          bytes: bytes,
          isSyntheticSample: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('AI Document Validator'),
      ),
      body: BlocBuilder<DocumentVerificationBloc, DocumentVerificationState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Scan & Verify Certified Documents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Documents must be certified by either the South African Police Service (SAPS) '
                    'or the South African Post Office (SAPO) within the last 3 months. '
                    'PDF, JPG, or PNG up to 5 MB.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: AppColors.forestDark,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'POPIA safeguard: Use synthetic documents during the hackathon. '
                            'Sensitive ID numbers are masked automatically, and no application is declined without an official.',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<DocumentType>(
                initialValue: state.selectedType,
                decoration: const InputDecoration(
                  labelText: 'Document type',
                ),
                items: [
                  for (final type in DocumentType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: state.isScanning
                    ? null
                    : (value) {
                  if (value != null) {
                    context.read<DocumentVerificationBloc>().add(
                      DocumentTypeSelected(value),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null) ...[
                FormMessage(message: state.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                label: state.isScanning
                    ? 'AI Agent Scanning...'
                    : 'Upload & Scan Certified Document',
                isLoading: state.isScanning,
                onPressed: () => _pickAndScan(context, state.selectedType),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quick synthetic demo samples',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.verified_outlined, size: 16),
                    label: const Text('SAPS Certified ID'),
                    onPressed: state.isScanning
                        ? null
                        : () => _scanSyntheticSample(
                      context,
                      fileName: 'synthetic_id_saps_certified.pdf',
                      type: DocumentType.southAfricanId,
                      sampleContent:
                      'SOUTH AFRICAN POLICE SERVICE\nCLIENT SERVICE CENTRE\n2026 -11- 15\nEVATON\nSOUTH AFRICAN POLICE SERVICE\nI CERTIFY THAT THIS DOCUMENT IS A TRUE REPRODUCTION (COPY) OF THE ORIGINAL DOCUMENT\nFORCE NUMBER 70133581\nID 9901015009087',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.local_post_office_outlined, size: 16),
                    label: const Text('Post Office Payslip'),
                    onPressed: state.isScanning
                        ? null
                        : () => _scanSyntheticSample(
                      context,
                      fileName: 'synthetic_payslip_post_office.pdf',
                      type: DocumentType.payslip,
                      sampleContent:
                      'SOUTH AFRICAN POST OFFICE SAPO CERTIFIED TRUE COPY 2026-11-20',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.warning_amber_outlined, size: 16),
                    label: const Text('Uncertified Transcript'),
                    onPressed: state.isScanning
                        ? null
                        : () => _scanSyntheticSample(
                      context,
                      fileName: 'synthetic_transcript_uncertified.pdf',
                      type: DocumentType.academicTranscript,
                      sampleContent: 'ACADEMIC TRANSCRIPT NO STAMP',
                    ),
                  ),
                ],
              ),
              if (state.latestResult != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Latest AI Assessment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                VerificationResultCard(result: state.latestResult!),
                if (state.latestResult!.verdict ==
                    VerificationVerdict.authentic) ...[
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Proceed to Step 3: Apply for Bursaries',
                    onPressed: () => context.push(RoutePaths.bursaries),
                  ),
                ],
              ],
              if (state.history.length > 1) ...[
                const SizedBox(height: 24),
                Text(
                  'Session Scan History (${state.history.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in state.history.skip(1))
                  Card(
                    elevation: 0,
                    color: AppColors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: ListTile(
                      title: Text(
                        item.fileName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${item.documentType.label} • ${item.authority.label}',
                      ),
                      trailing: Text(
                        item.verdict.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
