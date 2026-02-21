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

// Used when updating basic info (Name/Image) takes place on the main screen
class ProfileBasicUpdateLoading extends ProfileState {}

// --- States for Multi-Step Bottom Sheet Flows ---

// Step 1 Finished: OTP sent to current email. Show OTP input field.
class SensitiveChangeOtpSent extends ProfileState {
  final String hashedEmail;
  final bool isForPhone; // To know which flow we are in
  SensitiveChangeOtpSent({required this.hashedEmail, required this.isForPhone});
}

// Step 2 Finished: Current Email OTP Verified. Show New Input Fields (New Email OR New Phone).
class SensitiveChangeCurrentVerified extends ProfileState {
   final bool isForPhone;
   SensitiveChangeCurrentVerified({required this.isForPhone});
}

// Step 3 Finished (Email Flow Only): OTP sent to NEW email. Show OTP input again.
class NewEmailOtpSent extends ProfileState {}

// Final Success State indicating a specific field updated successfully, closes bottom sheet.
class FieldUpdateSuccess extends ProfileState {
  final String message;
  final String? newEmail; // Optional: pass back if changed
  final String? newPhone; // Optional: pass back if changed
  final String? newName; // Optional: pass back if changed
  final String? newImageUrl; // Optional: pass back if changed

  FieldUpdateSuccess(this.message, {this.newEmail, this.newPhone, this.newName, this.newImageUrl});
}
