abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String imageUrl;
  ProfileLoaded({
    required this.imageUrl,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUnauth extends ProfileState {
  final String message;
  ProfileUnauth(this.message);
}

class ProfileActionSuccess extends ProfileState {
  final String message;
  ProfileActionSuccess(this.message);
}

class ProfileBasicUpdateLoading extends ProfileState {}

class FirstOtpSent extends ProfileState {
  final bool isForPhone; 
  FirstOtpSent({required this.isForPhone});
}

class FirstOtpVerified extends ProfileState {
   final bool isForPhone;
   FirstOtpVerified({required this.isForPhone});
}

class NewEmailOtpSent extends ProfileState {}

class FieldUpdateSuccess extends ProfileState {
  final String message;
  final String? newEmail; 
  final String? newPhone;
  final String? newName; 
  final String? newImageUrl;

  FieldUpdateSuccess(this.message, {this.newEmail, this.newPhone, this.newName, this.newImageUrl});
}