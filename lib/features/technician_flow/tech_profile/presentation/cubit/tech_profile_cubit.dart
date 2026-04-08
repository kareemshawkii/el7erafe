import 'dart:io';
import 'package:el7erafe/core/services/notifications/notification_api_service.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/repositories/tech_profile_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/technician_profile_model.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechProfileCubit extends Cubit<TechProfileState> {
  final TechProfileRepository _repo;

  TechProfileCubit(this._repo) : super(ProfileInitial());

  void _safeEmit(TechProfileState state) {
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

    final result = await _repo.getProfileData(token);

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          _safeEmit(ProfileUnauth(
              "انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          _safeEmit(ProfileError(error));
        }
      },
      (TechnicianProfileModel profileModel) {
        if (!isClosed) {
          _safeEmit(ProfileLoaded(
              imageUrl: profileModel.profileImage, profile: profileModel));
        }
      },
    );
  }

  void deleteAccount(String token) async {
    emit(ProfileLoading());
    final result = await _repo.deleteAccount(token);
    if (isClosed) return;

    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(ProfileActionSuccess("تم حذف الحساب بنجاح")),
    );
  }

  void logout(String token) async {
    emit(ProfileLoading());
    await NotificationApiService.deleteFcmToken();
    await FirebaseMessaging.instance.deleteToken();
    final result = await _repo.logout(token);
    if (isClosed) return;

    result.fold(
      (error) => _handleError(error),
      (success) => _safeEmit(ProfileActionSuccess("تم تسجيل الخروج بنجاح")),
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
      _safeEmit(ProfileError("النبذة الشخصية يجب ألا تتجاوز 200 حرف."));
      return;
    }

    int finalImageCount = currentPortfolioCount +
        (newPortfolioImages?.length ?? 0) -
        (deletedPortfolioImages?.length ?? 0);

    if (finalImageCount > 20) {
      _safeEmit(
          ProfileError("لا يمكن أن يتجاوز عدد صور معرض الأعمال 20 صورة."));
      return;
    }

    if (profileImage != null) {
      if (!profileImage.existsSync()) {
        _safeEmit(ProfileError("ملف الصورة الشخصية غير موجود."));
        return;
      }
      final int fileSize = profileImage.lengthSync();
      if (fileSize == 0 || fileSize > 1 * 1024 * 1024) {
        _safeEmit(ProfileError(
            "حجم الصورة الشخصية يجب أن يكون بين 1 بايت و 1 ميجابايت."));
        return;
      }
    }

    if (newPortfolioImages != null) {
      for (var img in newPortfolioImages) {
        if (!img.existsSync() || img.lengthSync() == 0) {
          _safeEmit(ProfileError("إحدى صور معرض الأعمال غير صالحة."));
          return;
        }
      }
    }

    _safeEmit(ProfileBasicUpdateLoading());

    final result = await _repo.updateBasicProfile(
      token: token,
      name: name,
      aboutMe: aboutMe,
      profileImage: profileImage,
      newPortfolioImages: newPortfolioImages,
      deletedPortfolioImages: deletedPortfolioImages,
    );

    if (isClosed) return;

    result.fold(
      (error) => _handleError(error),
      (data) {
        loadProfile(token, name ?? "مستخدم");
        _safeEmit(FieldUpdateSuccess("تم تحديث البيانات الأساسية بنجاح",
            newName: name));
      },
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

  void resetUpdateFlowState(String currentImageUrl,
      [TechnicianProfileModel? profile]) {
    _safeEmit(ProfileLoaded(imageUrl: currentImageUrl, profile: profile));
  }
}
