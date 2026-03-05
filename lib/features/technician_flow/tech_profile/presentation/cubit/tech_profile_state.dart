import 'package:el7erafe/features/technician_flow/tech_profile/data/models/technician_profile_model.dart';

abstract class TechProfileState {}

class ProfileInitial extends TechProfileState {}

class ProfileLoading extends TechProfileState {}

class ProfileLoaded extends TechProfileState {
  final String imageUrl;
  final TechnicianProfileModel? profile; 
  
  ProfileLoaded({
    required this.imageUrl,
    this.profile,
  });
}

class ProfileError extends TechProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUnauth extends TechProfileState {
  final String message;
  ProfileUnauth(this.message);
}

class ProfileActionSuccess extends TechProfileState {
  final String message;
  ProfileActionSuccess(this.message);
}

class ProfileBasicUpdateLoading extends TechProfileState {}

class FirstOtpSent extends TechProfileState {
  final bool isForPhone; 
  FirstOtpSent({required this.isForPhone});
}

class FirstOtpVerified extends TechProfileState {
   final bool isForPhone;
   FirstOtpVerified({required this.isForPhone});
}

class NewEmailOtpSent extends TechProfileState {}

class FieldUpdateSuccess extends TechProfileState {
  final String message;
  final String? newEmail; 
  final String? newPhone;
  final String? newName; 
  final String? newImageUrl;

  FieldUpdateSuccess(this.message, {this.newEmail, this.newPhone, this.newName, this.newImageUrl});
}