enum DocumentType {
  southAfricanId('South African ID'),
  payslip('Payslip / Proof of Income'),
  academicTranscript('Academic Transcript'),
  proofOfResidence('Proof of Residence'),
  bankStatement('Bank Statement');

  const DocumentType(this.label);

  final String label;
}
