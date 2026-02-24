import 'dart:io';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileCubit(this._repo) : super(ProfileInitial());

  void _handleError(String error) {
    if (error == "401") {
      emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
    } else {
      emit(ProfileError(error));
    }
  }

  void loadProfile(String token, String defaultName) async {
    emit(ProfileLoading());

    String localImage = await AuthLocalStorage().getUserProfileImage() ?? "";
    if (localImage.isNotEmpty) {
      emit(ProfileLoaded(imageUrl: localImage));
    }

    final result = await _repo.getProfileData(token);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          if (localImage.isEmpty) emit(ProfileError(error));
        }
      },
      (data) async {
        String freshImageUrl = data['imageURL'] ?? "";
        if (freshImageUrl.isNotEmpty && freshImageUrl != localImage) {
          await AuthLocalStorage().saveUserProfileImage(freshImageUrl);
        }
        emit(ProfileLoaded(imageUrl: freshImageUrl));
      },
    );
  }

  void deleteAccount(String token) async {
    final result = await _repo.deleteAccount(token);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(ProfileActionSuccess("تم حذف الحساب بنجاح")),
    );
  }

  void logout(String token) async {
    final result = await _repo.logout(token);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(ProfileActionSuccess("تم تسجيل الخروج بنجاح")),
    );
  }

  void updateBasicInfo(String token, String name, File? imageFile) async {
    emit(ProfileBasicUpdateLoading());
    final result = await _repo.updateBasicProfile(token, name, imageFile);
    result.fold(
      (error) => _handleError(error),
      (data) => emit(FieldUpdateSuccess("تم تحديث البيانات الأساسية بنجاح")),
    );
  }

  void sendFirstOtp(String token, String email, {required bool isForPhone}) async {
    emit(ProfileLoading());
    final result = await _repo.sendFirstOtp(token, email);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(FirstOtpSent(isForPhone: isForPhone)),
    );
  }

  void verifyFirstOtp(String token, String email, String otp, {required bool isForPhone}) async {
    emit(ProfileLoading());
    final result = await _repo.verifyFirstOtp(token, email, otp);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(FirstOtpVerified(isForPhone: isForPhone)),
    );
  }

  void sendOtpToNewEmail(String token, String newEmail) async {
    emit(ProfileLoading());
    final result = await _repo.sendOtpToNewEmail(token, newEmail);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(NewEmailOtpSent()),
    );
  }

  void verifyNewEmail(String token, String email, String newOtpCode) async {
    emit(ProfileLoading());
    final result = await _repo.verifyNewEmail(token, email, newOtpCode);
    result.fold(
      (error) => _handleError(error),
      (success) => emit(FieldUpdateSuccess("تم تحديث البريد الإلكتروني بنجاح", newEmail: email)),
    );
  }

  void finalizePhoneChange(String token, String newPhone) async {
    emit(ProfileLoading());
    final result = await _repo.finalizePhoneChange(token, newPhone);
    result.fold(
      (error) => _handleError(error),
      (successMessage) => emit(FieldUpdateSuccess("تم تحديث رقم الهاتف بنجاح", newPhone: newPhone)),
    );
  }

  void resetUpdateFlowState(String currentImageUrl) {
    emit(ProfileLoaded(imageUrl: currentImageUrl));
  }
}