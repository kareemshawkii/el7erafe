import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/models/email_input_model.dart';
import 'package:http/http.dart' as http;

class EmailInputRepository {
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";

  Future<Either<Failure, String>> sendEmail({
    required String email,
  }) async {
    final Uri registerUrl = Uri.parse('$_baseUrl/api/auth/forgot-password');

    final requestModel = EmailInputModel(
      email: email,
    );

    try {
      final response = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right('تم إرسال رمز التحقق إلى بريدك الإلكتروني بنجاح');
      } else if (response.statusCode == 404) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 403) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 429) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else {
        return const Left(
            Failure('فيه خطأ حصل أثناء الرجاء المحاوله مره اخرى'));
      }
    } catch (e) {
      return const Left(Failure(
          "فيه خطأ حصل أثناء التسجيل. يرجى التحقق من اتصالك بالإنترنت."));
    }
  }
}
