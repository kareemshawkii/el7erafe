import 'dart:io';
import 'package:el7erafe/features/technician_flow/tech_profile/data/repositories/tech_profile_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/technician_profile_model.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class TechProfileCubit extends Cubit<TechProfileState> {
  final TechProfileRepository _repo;

  TechProfileCubit(this._repo) : super(ProfileInitial());

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
      (TechnicianProfileModel profileModel) async {
        String freshImageUrl = profileModel.profileImage;
        if (freshImageUrl.isNotEmpty && freshImageUrl != localImage) {
          await AuthLocalStorage().saveUserProfileImage(freshImageUrl);
        }
        emit(ProfileLoaded(imageUrl: freshImageUrl, profile: profileModel));
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

  void updateBasicInfo({
    required String token,
    String? name,
    String? aboutMe,
    File? profileImage,
    List<File>? newPortfolioImages,
    List<String>? deletedPortfolioImages,
    int currentPortfolioCount = 0, 
  }) async {
    
    if (aboutMe != null && aboutMe.length > 200) {
      emit(ProfileError("النبذة الشخصية يجب ألا تتجاوز 200 حرف."));
      return;
    }

    int finalImageCount = currentPortfolioCount + 
        (newPortfolioImages?.length ?? 0) - 
        (deletedPortfolioImages?.length ?? 0);

    if (finalImageCount > 20) {
      emit(ProfileError("لا يمكن أن يتجاوز عدد صور معرض الأعمال 20 صورة."));
      return;
    }

    if (profileImage != null) {
      if (!profileImage.existsSync()) {
        emit(ProfileError("ملف الصورة الشخصية غير موجود."));
        return;
      }
      final int fileSize = profileImage.lengthSync();
      if (fileSize == 0 || fileSize > 1 * 1024 * 1024) { 
        emit(ProfileError("حجم الصورة الشخصية يجب أن يكون بين 1 بايت و 1 ميجابايت."));
        return;
      }
    }

    if (newPortfolioImages != null) {
      for (var img in newPortfolioImages) {
        if (!img.existsSync() || img.lengthSync() == 0) {
          emit(ProfileError("إحدى صور معرض الأعمال غير صالحة."));
          return;
        }
      }
    }

    emit(ProfileBasicUpdateLoading());
    
    final result = await _repo.updateBasicProfile(
      token: token,
      name: name,
      aboutMe: aboutMe,
      profileImage: profileImage,
      newPortfolioImages: newPortfolioImages,
      deletedPortfolioImages: deletedPortfolioImages,
    );
    
    result.fold(
      (error) => _handleError(error),
      (data) => emit(FieldUpdateSuccess("تم تحديث البيانات الأساسية بنجاح", newName: name)),
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
      (success) => emit(FieldUpdateSuccess("تم تحديث البريد الإلكتروني بنجاح إلى $email", newEmail: email)),
    );
  }

  void finalizePhoneChange(String token, String newPhone) async {
    emit(ProfileLoading());
    final result = await _repo.finalizePhoneChange(token, newPhone);
    result.fold(
      (error) => _handleError(error),
      (successMessage) => emit(FieldUpdateSuccess("تم تحديث رقم الهاتف بنجاح إلى $newPhone", newPhone: newPhone)),
    );
  }

  void resetUpdateFlowState(String currentImageUrl, [TechnicianProfileModel? profile]) {
    emit(ProfileLoaded(imageUrl: currentImageUrl, profile: profile));
  }
}