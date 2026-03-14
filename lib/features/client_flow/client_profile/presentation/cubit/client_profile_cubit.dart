import 'dart:io';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileCubit(this._repo) : super(ProfileInitial());

  void _safeEmit(ProfileState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  void _handleError(String error) {
    if (error == "401") {
      _safeEmit(
          ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
    } else {
      _safeEmit(ProfileError(error));
    }
  }

  void loadProfile(String token, String defaultName) async {
    _safeEmit(ProfileLoading());

    String localImage = await AuthLocalStorage().getUserProfileImage() ?? "";
    if (localImage.isNotEmpty) {
      _safeEmit(ProfileLoaded(imageUrl: localImage));
    }

    final result = await _repo.getProfileData(token);

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          _safeEmit(ProfileUnauth(
              "انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          if (localImage.isEmpty) _safeEmit(ProfileError(error));
        }
      },
      (data) async {
        String freshImageUrl = data['imageURL'] ?? "";
        if (freshImageUrl.isNotEmpty && freshImageUrl != localImage) {
          await AuthLocalStorage().saveUserProfileImage(freshImageUrl);
        }
        if (!isClosed) {
          _safeEmit(ProfileLoaded(imageUrl: freshImageUrl));
        }
      },
    );
  }

  void deleteAccount(String token) async {
    final result = await _repo.deleteAccount(token);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(ProfileActionSuccess("تم حذف الحساب بنجاح")),
    );
  }

  void logout(String token) async {
    final result = await _repo.logout(token);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(ProfileActionSuccess("تم تسجيل الخروج بنجاح")),
    );
  }

  void updateBasicInfo(String token, String name, File? imageFile) async {
    if (imageFile != null) {
      if (!imageFile.existsSync()) {
        _safeEmit(ProfileError("ملف الصورة غير موجود."));
        return;
      }
      final int fileSize = imageFile.lengthSync();
      if (fileSize == 0 || fileSize > 1 * 1024 * 1024) {
        _safeEmit(
            ProfileError("حجم الصورة يجب أن يكون بين 1 بايت و 1 ميجابايت."));
        return;
      }
    }

    _safeEmit(ProfileBasicUpdateLoading());
    final result = await _repo.updateBasicProfile(token, name, imageFile);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (data) =>
          _safeEmit(FieldUpdateSuccess("تم تحديث البيانات الأساسية بنجاح")),
    );
  }

  void sendFirstOtp(String token, String email,
      {required bool isForPhone}) async {
    _safeEmit(ProfileLoading());
    final result = await _repo.sendFirstOtp(token, email);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(FirstOtpSent(isForPhone: isForPhone)),
    );
  }

  void verifyFirstOtp(String token, String email, String otp,
      {required bool isForPhone}) async {
    _safeEmit(ProfileLoading());
    final result = await _repo.verifyFirstOtp(token, email, otp);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(FirstOtpVerified(isForPhone: isForPhone)),
    );
  }

  void sendOtpToNewEmail(String token, String newEmail) async {
    _safeEmit(ProfileLoading());
    final result = await _repo.sendOtpToNewEmail(token, newEmail);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(NewEmailOtpSent()),
    );
  }

  void verifyNewEmail(String token, String email, String newOtpCode) async {
    _safeEmit(ProfileLoading());
    final result = await _repo.verifyNewEmail(token, email, newOtpCode);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(FieldUpdateSuccess(
          "تم تحديث البريد الإلكتروني بنجاح إلى $email",
          newEmail: email)),
    );
  }

  void finalizePhoneChange(String token, String newPhone) async {
    _safeEmit(ProfileLoading());
    final result = await _repo.finalizePhoneChange(token, newPhone);
    if (isClosed) return;
    result.fold(
      (error) => _handleError(error),
      (successMessage) => _safeEmit(FieldUpdateSuccess(
          "تم تحديث رقم الهاتف بنجاح إلى $newPhone",
          newPhone: newPhone)),
    );
  }

  void resetUpdateFlowState(String currentImageUrl) {
    _safeEmit(ProfileLoaded(imageUrl: currentImageUrl));
  }
}
