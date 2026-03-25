import 'dart:convert';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/local_storage/rejected_local_storage.dart';
import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/core/services/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final String _baseUrl =
      "https://el7rafeapp.azurewebsites.net";

  Future<Either<Failure, UserModel>> login(
      String phoneNumber, String password) async {
    final Uri loginUrl = Uri.parse('$_baseUrl/api/auth/login');
    try {
      final response = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.saveUserSession(user);
        return Right(user);
      } else if (response.statusCode == 452) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String email = data['email'] ?? '';
        if (email.isNotEmpty) {
          AuthLocalStorage authLocalStorage = AuthLocalStorage();
          await authLocalStorage.saveEmail(email);
        }
        return Left(Failure("OTP"));
      } else if (response.statusCode == 453) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String email = data['email'] ?? '';
        if (email.isNotEmpty) {
          AuthLocalStorage authLocalStorage = AuthLocalStorage();
          await authLocalStorage.saveTechnicianEmail(email);
        }
        return Left(Failure("TECHNICIANOTP"));
      } else if (response.statusCode == 460) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final tempTechnician = TempTechnician(
          tempToken: data['tempToken'],
        );
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.saveTempToken(tempTechnician);
        return Left(Failure("PENDING"));
      } else if (response.statusCode == 461) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rejectedUser = RejectedUserModel.fromJson(data);
        RejectedLocalStorage rejectedLocalStorage = RejectedLocalStorage();
        await rejectedLocalStorage.saveRejectedTechnician(rejectedUser);
        return Left(Failure("REJECTED"));
      } else if (response.statusCode == 462 || response.statusCode == 470) {
        return Left(Failure("BLOCKED"));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return const Left(
          Failure("فيه مشكله في الاتصال ممكن تتأكد من اتصالك بالانترنت."));
    }
  }
}
