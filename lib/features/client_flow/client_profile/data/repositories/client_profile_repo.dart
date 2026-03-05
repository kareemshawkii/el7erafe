import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ProfileRepository {
  final String _baseUrl =
      'https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net';

  Future<Either<String, Map<String, dynamic>>> getProfileData(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/cf/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await AuthLocalStorage().saveEmail(data['email']);
        await AuthLocalStorage().savePhoneNumber(data['phoneNumber']);
        await AuthLocalStorage().saveUserProfileImage(data['imageURL'] ?? "");
        return Right(data);
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left(
          "فشل تحميل بيانات الملف الشخصي الرجاء المحاولة مرة اخرى.",
        );
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/client/account'),
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
        return const Left(
          "فشل تسجيل الخروج الرجاء المحاولة مرة اخرى.",
        );
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }

  Future<Either<String, String>> updateBasicProfile(
      String token, String name, File? imageFile) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/api/cf/profile_update');
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer $token';

      if (name.isNotEmpty) {
        request.fields['Name'] = name;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Image', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (name.isNotEmpty) {
          await AuthLocalStorage().saveUserName(name);
        }
        if (imageFile != null) {
          await AuthLocalStorage().deleteUserProfileImage();
        }
        return Right("تم تحديث البيانات بنجاح");
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return const Left("فشل تحديث البيانات، الرجاء المحاولة مرة أخرى.");
      }
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
        return Right('تم التحقق من الكود بنجاح');
      } else if (response.statusCode == 400) {
        return Left((jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return Left(("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return Left(("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }

  Future<Either<String, String>> sendOtpToNewEmail(
      String token, String newEmail) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/cf/update-pending-email');
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
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/cf/update-email');
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
        return Right('تم التحقق من الكود بنجاح');
      } else if (response.statusCode == 400) {
        return Left((jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        return Left(("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return Left(("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }
  

  Future<Either<String, String>> finalizePhoneChange(
      String token, String newPhone) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/cf/phone_update');
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
