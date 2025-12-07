import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:http/http.dart' as http;

class OtpForgetRepository {
  final String _baseUrl = "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net"; 

  Future<Either<Failure, String>> verifyOtp(String email, String otpCode) async {
    final Uri verifyUrl = Uri.parse('$_baseUrl/api/auth/verify-reset-otp');
    
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
         AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.saveResetTempToken(jsonDecode(response.body)['tempToken']);
        return  Right('accepted');
      } else if (response.statusCode == 400) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else {
        return const Left(Failure("حصل خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا."));
      }
    } catch (e) {
      return const Left(Failure("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
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
        return const Right('تم إعادة إرسال رمز التحقق بنجاح');
      } 
      else if (response.statusCode == 400) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } 
      else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return const Left(Failure("حصل خطأ غير متوقع. يرجى التأكد من اتصالك بالإنترنت."));
    }
  }
}