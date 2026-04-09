import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/technician_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class TechProfileRepository {
  final String _baseUrl = 'https://el7rafeapp.azurewebsites.net';

  Future<Either<String, TechnicianProfileModel>> getProfileData(String token,
      {bool forceRefresh = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tech/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await AuthLocalStorage().saveEmail(data['email'] ?? "");
        await AuthLocalStorage().savePhoneNumber(data['phone'] ?? "");

        final profileModel = TechnicianProfileModel.fromJson(data);

        return Right(profileModel);
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left(
            "فشل تحميل بيانات الملف الشخصي الرجاء المحاولة مرة اخرى.");
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/tech/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await AuthLocalStorage().clearSession();
        return const Right("تم حذف الحساب بنجاح");
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left("فشل حذف الحساب الرجاء المحاولة مرة اخرى.");
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await AuthLocalStorage().clearSession();
        return const Right("تم تسجيل الخروج بنجاح");
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left("فشل تسجيل الخروج الرجاء المحاولة مرة اخرى.");
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> updateBasicProfile({
    required String token,
    String? name,
    String? aboutMe,
    File? profileImage,
    List<File>? newPortfolioImages,
    List<String>? deletedPortfolioImages,
  }) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/api/tech/profile_update');

      bool hasMedia = profileImage != null ||
          (newPortfolioImages != null && newPortfolioImages.isNotEmpty) ||
          (deletedPortfolioImages != null && deletedPortfolioImages.isNotEmpty);

      if (hasMedia) {
        var mediaRequest = http.MultipartRequest('PATCH', url);
        mediaRequest.headers['Authorization'] = 'Bearer $token';

        if (profileImage != null) {
          mediaRequest.files.add(
            await http.MultipartFile.fromPath(
                'ProfileImage', profileImage.path),
          );
        }

        if (newPortfolioImages != null && newPortfolioImages.isNotEmpty) {
          for (var imageFile in newPortfolioImages) {
            mediaRequest.files.add(
              await http.MultipartFile.fromPath(
                  'NewPortifolioImages', imageFile.path),
            );
          }
        }

        if (deletedPortfolioImages != null &&
            deletedPortfolioImages.isNotEmpty) {
          for (var deletedImage in deletedPortfolioImages) {
            mediaRequest.files.add(
              http.MultipartFile.fromString(
                  'DeletedPortifolioImages', deletedImage),
            );
          }
        }

        var mediaResponse = await mediaRequest.send();
        var response1 = await http.Response.fromStream(mediaResponse);

        if (response1.statusCode == 401) {
          AuthLocalStorage authLocalStorage = AuthLocalStorage();
          await authLocalStorage.clearSession();
          return const Left("401");
        } else if (response1.statusCode != 200 && response1.statusCode != 204) {
          return Left(
            (jsonDecode(response1.body)
                    as Map<String, dynamic>)['errorMessage'] ??
                "فشل تحديث البيانات الرجاء المحاولة مرة اخرى.",
          );
        }
      }

      if (aboutMe != null) {
        var aboutMeRequest = http.MultipartRequest('PATCH', url);
        aboutMeRequest.headers['Authorization'] = 'Bearer $token';
        aboutMeRequest.fields['AboutMe'] = aboutMe;

        var aboutMeResponse = await aboutMeRequest.send();
        var response2 = await http.Response.fromStream(aboutMeResponse);

        if (response2.statusCode == 401) {
          AuthLocalStorage authLocalStorage = AuthLocalStorage();
          await authLocalStorage.clearSession();
          return const Left("401");
        } else if (response2.statusCode != 200 && response2.statusCode != 204) {
          return Left(
            (jsonDecode(response2.body)
                    as Map<String, dynamic>)['errorMessage'] ??
                "فشل تحديث النبذة الشخصية.",
          );
        }
      }

      if (name != null && name.isNotEmpty) {
        var nameRequest = http.MultipartRequest('PATCH', url);
        nameRequest.headers['Authorization'] = 'Bearer $token';
        nameRequest.fields['Name'] = name;

        var nameResponse = await nameRequest.send();
        var response3 = await http.Response.fromStream(nameResponse);

        if (response3.statusCode == 401) {
          AuthLocalStorage authLocalStorage = AuthLocalStorage();
          await authLocalStorage.clearSession();
          return const Left("401");
        } else if (response3.statusCode != 200 && response3.statusCode != 204) {
          return Left(
            (jsonDecode(response3.body)
                    as Map<String, dynamic>)['errorMessage'] ??
                "فشل تحديث الاسم.",
          );
        }

        await AuthLocalStorage().saveUserName(name);
      }

      return const Right("تم تحديث البيانات بنجاح");
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> sendFirstOtp(
      String token, String email) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/auth/resend-otp');
    try {
      final response = await http.post(
        resendUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return const Right('تم إرسال كود التحقق بنجاح.');
      } else if (response.statusCode == 400) {
        return Left(jsonDecode(response.body)['errorMessage']);
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return Left(jsonDecode(response.body)['errorMessage']);
      }
    } catch (e) {
      return const Left("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت.");
    }
  }

  Future<Either<String, String>> verifyFirstOtp(
      String token, String email, String otpCode) async {
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/auth/verify-otp');
    try {
      final response = await http.post(
        verifyUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right('تم التحقق من الكود بنجاح');
      } else if (response.statusCode == 400) {
        return Left((jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left(
            ("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return const Left(
          ("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }

  Future<Either<String, String>> sendOtpToNewEmail(
      String token, String newEmail) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/tech/update-pending-email');
    try {
      final response = await http.post(
        resendUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'newEmail': newEmail,
        }),
      );
      if (response.statusCode == 200) {
        return const Right('تم تحديث البريد الإلكتروني بنجاح.');
      } else if (response.statusCode == 400) {
        return Left(jsonDecode(response.body)['errorMessage']);
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return Left(jsonDecode(response.body)['errorMessage']);
      }
    } catch (e) {
      return const Left("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت.");
    }
  }

  Future<Either<String, String>> verifyNewEmail(
      String token, String email, String newOtpCode) async {
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/tech/update-email');
    try {
      final response = await http.post(
        verifyUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otpCode': newOtpCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right('تم التحقق من الكود بنجاح');
      } else if (response.statusCode == 400) {
        return Left((jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left(
            ("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return const Left(
          ("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }

  Future<Either<String, String>> finalizePhoneChange(
      String token, String newPhone) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/tech/phone_update');
    try {
      final response = await http.patch(
        resendUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': newPhone,
        }),
      );
      if (response.statusCode == 200) {
        return const Right('تم تحديث رقم الهاتف بنجاح.');
      } else if (response.statusCode == 400) {
        return Left(jsonDecode(response.body)['errorMessage']);
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return Left(jsonDecode(response.body)['errorMessage']);
      }
    } catch (e) {
      return const Left("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت.");
    }
  }
}
