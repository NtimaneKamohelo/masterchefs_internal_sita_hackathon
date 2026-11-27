import 'package:equatable/equatable.dart';

const List<String> southAfricanProvinces = [
  'Eastern Cape',
  'Free State',
  'Gauteng',
  'KwaZulu-Natal',
  'Limpopo',
  'Mpumalanga',
  'Northern Cape',
  'North West',
  'Western Cape',
];

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.idNumber,
    required this.streetAddress,
    required this.city,
    required this.province,
    required this.postalCode,
    this.phoneNumber = '',
    this.annualHouseholdIncome = 0,
    this.hasDisability = false,
    this.updatedAt,
  });

  final String userId;
  final String fullName;
  final String idNumber;
  final String streetAddress;
  final String city;
  final String province;
  final String postalCode;
  final String phoneNumber;
  final int annualHouseholdIncome;
  final bool hasDisability;
  final DateTime? updatedAt;

  /// NSFAS threshold: R350,000/year standard, R600,000/year for disability.
  int get nsfasIncomeThreshold => hasDisability ? 600000 : 350000;

  bool get meetsNsfasIncomeThreshold =>
      annualHouseholdIncome <= nsfasIncomeThreshold;

  /// POPIA-minimised ID reference for display in summaries.
  String get maskedIdNumber {
    if (idNumber.length != 13) return '•••••••••••••';
    return '${idNumber.substring(0, 6)}•••••${idNumber.substring(11)}';
  }

  String get formattedAddress =>
      '$streetAddress, $city, $province, $postalCode';

  @override
  List<Object?> get props => [
    userId,
    fullName,
    idNumber,
    streetAddress,
    city,
    province,
    postalCode,
    phoneNumber,
    annualHouseholdIncome,
    hasDisability,
    updatedAt,
  ];
}
