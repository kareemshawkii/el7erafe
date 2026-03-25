import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/local_storage/rejected_local_storage.dart';
import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:el7erafe/core/services/models/user.dart';
import 'package:http/http.dart' as http;

class OtpRepository {
  final String _baseUrl =
      "https://el7rafeapp.azurewebsites.net";

  Future<Either<Failure, User>> verifyOtp(String email, String otpCode) async {
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/auth/confirm-email');

    try {
      final response = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.deleteEmail();
        await authLocalStorage.saveUserSession(user);
        return Right(user);
      } else if (response.statusCode == 400) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else {
        return const Left(
            Failure("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return const Left(
          Failure("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }

  Future<Either<Failure, String>> resendOtp(String email) async {
    final Uri resendUrl = Uri.parse('$_baseUrl/api/auth/resend-otp');

    try {
      final response = await http.post(
        resendUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return const Right('تم إعادة إرسال كود التحقق بنجاح.');
      } else if (response.statusCode == 400) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return const Left(
          Failure("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }

  Future<Either<Failure, User>> verifyTechnicianOtp(
      String email, String otpCode) async {
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/technician/confirm-email');

    try {
      final response = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.deleteTechnicianEmail();
        await authLocalStorage.saveUserSession(user);
        return Right(user);
      } else if (response.statusCode == 460) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final tempTechnician = TempTechnician(
          tempToken: data['tempToken'],
        );
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.deleteTempToken();
        await authLocalStorage.saveTempToken(tempTechnician);
        return Left(Failure('PENDING'));
      } else if (response.statusCode == 461) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rejectedUser = RejectedUserModel.fromJson(data);
        RejectedLocalStorage rejectedLocalStorage = RejectedLocalStorage();
        await rejectedLocalStorage.saveRejectedTechnician(rejectedUser);
        return Left(Failure('REJECTED'));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 462 || response.statusCode == 470) {
        await AuthLocalStorage().deleteTempToken();
        return Left(Failure('BLOCKED'));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return const Left(
          Failure("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }
}
