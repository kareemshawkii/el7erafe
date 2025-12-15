import 'dart:io';

class TechnicianRegistrationRequestModel {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;
  final File frontIdImage;
  final File backIdImage;
  final File criminalRecordImage;
  final String governorate;
  final String city;
  final String serviceType;

  TechnicianRegistrationRequestModel({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.frontIdImage,
    required this.backIdImage,
    required this.criminalRecordImage,
    required this.governorate,
    required this.city,
    required this.serviceType,
  });
}