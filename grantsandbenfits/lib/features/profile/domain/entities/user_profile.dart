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
  final DateTime? updatedAt;

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
    updatedAt,
  ];
}
