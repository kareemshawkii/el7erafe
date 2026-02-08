import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/data/models/client_registration_model.dart';
import 'package:http/http.dart' as http;

class ClientRegRepository {
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";

  Future<Either<Failure, String>> registerClient({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final Uri registerUrl = Uri.parse('$_baseUrl/api/auth/register/client');

    final requestModel = RegistrationRequestModel(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );

    try {
      final response = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        authLocalStorage.saveEmail(email);
        final data = jsonDecode(response.body);
        return Right(data['message'] as String);
      } else if (response.statusCode == 409) {
        return Left(Failure(jsonDecode(response.body)['errorMessage'] +
            " يرجى استخدام بريد إلكتروني أو رقم هاتف مختلف او تسجيل الدخول."));
      } else if (response.statusCode == 400) {
        return Left(Failure(
            "فيه خطأ في البيانات المدخلة. يرجى التحقق والمحاولة مرة أخرى."));
      } else {
        return const Left(
            Failure('فيه خطأ حصل أثناء التسجيل الرجاء المحاوله مره اخرى'));
      }
    } catch (e) {
      return const Left(Failure(
          "فيه خطأ حصل أثناء التسجيل. يرجى التحقق من اتصالك بالإنترنت."));
    }
  }
}
