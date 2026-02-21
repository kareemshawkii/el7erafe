import 'dart:io';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileCubit(this._repo) : super(ProfileInitial());

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
      (data) {
        emit(ProfileLoaded(imageUrl: data['imageURL'] ?? ""));
      },
    );
  }

  void deleteAccount(String token) async {
    final result = await _repo.deleteAccount(token);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (success) => emit(ProfileActionSuccess("تم حذف الحساب بنجاح")),
    );
  }

  void logout(String token) async {
    final result = await _repo.logout(token);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (success) => emit(ProfileActionSuccess("تم تسجيل الخروج بنجاح")),
    );
  }

  void updateBasicInfo(String token, String name, File? imageFile) async {
    emit(ProfileBasicUpdateLoading()); 
    final result = await _repo.updateBasicProfile(token, name, imageFile);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (data) {
        emit(FieldUpdateSuccess("تم تحديث البيانات الأساسية بنجاح"));
      },
    );
  }

  void initiateSensitiveChange(String token, {required bool isForPhone, String? email}) async {
    emit(ProfileLoading()); 
    final result = await _repo.sendSensitiveChangeOtp(token, email!);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (hashedEmail) => emit(SensitiveChangeOtpSent(hashedEmail: hashedEmail, isForPhone: isForPhone)),
    );
  }

  void verifyCurrentEmailOtp(String token, String otp, String email, {required bool isForPhone}) async {
    emit(ProfileLoading());
    final result = await _repo.verifySensitiveChangeOtp(token, email, otp);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (success) => emit(SensitiveChangeCurrentVerified(isForPhone: isForPhone)),
    );
  }

  void sendOtpToNewEmail(String token, String newEmail) async {
    emit(ProfileLoading()); 
    final result = await _repo.sendSensitiveChangeOtp(token, newEmail);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (hashedEmail) => emit(SensitiveChangeOtpSent(hashedEmail: hashedEmail, isForPhone: false)),
    );
  }

   void confirmNewEmail(String token, String newotp, String email, {required bool isForPhone}) async {
    emit(ProfileLoading());
    final result = await _repo.confirmNewEmail(token, email, newotp);
    result.fold(
      (error) {
        if (error == "401") {
          emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(ProfileError(error));
        }
      },
      (success) => finalizeEmailChange(token, email),
    );
  }

  void finalizeEmailChange(String token, String newEmail) async {
    emit(ProfileLoading());
    final result = await _repo.finalizeEmailChange(token, newEmail);
    result.fold(
          (error) {
              if (error == "401") {
                emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
              } else {
                emit(ProfileError(error));
              }
          },
          (finalEmail) {
            emit(FieldUpdateSuccess("تم تحديث البريد الإلكتروني بنجاح", newEmail: finalEmail)); 
          },
    );
  }

  void finalizePhoneChange(String token, String newPhone) async {
    emit(ProfileLoading());
    final result = await _repo.finalizePhoneChange(token, newPhone);
    result.fold(
          (error) {
              if (error == "401") {
                emit(ProfileUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
              } else {
                emit(ProfileError(error));
              }
          },
          (finalPhone) {
            emit(FieldUpdateSuccess("تم تحديث رقم الهاتف بنجاح", newPhone: finalPhone)); 
          },
    );
  }

  void resetUpdateFlowState(String currentImageUrl) {
     emit(ProfileLoaded(imageUrl: currentImageUrl));
  }
}