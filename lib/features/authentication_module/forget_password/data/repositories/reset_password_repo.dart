import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/models/reset_password_model.dart';
import 'package:http/http.dart' as http;

class ResetPasswordRepository {
  final String _baseUrl =
      "https://el7rafeapp.azurewebsites.net";

  Future<Either<Failure, String>> resetPassword({
    required String password,
  }) async {
    AuthLocalStorage authLocalStorage = AuthLocalStorage();
    String? tempToken = await authLocalStorage.getResetTempToken();
    final Uri registerUrl = Uri.parse('$_baseUrl/api/auth/reset-password');

    final requestModel = ResetPasswordModel(
      password: password,
    );

    try {
      final response = await http.post(
        registerUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tempToken',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await authLocalStorage.deleteResetTempToken();
        return Right('accepted');
      } else if (response.statusCode == 404) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 403) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 429) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return Left(Failure(
          " فيه خطأ حصل أثناء التسجيل. يرجى التحقق من اتصالك بالإنترنت."));
    }
  }
}
