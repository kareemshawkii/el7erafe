import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/local_storage/rejected_local_storage.dart';
import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/core/utils/login_failure.dart';
import 'package:el7erafe/core/services/models/user.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/rejected_technician_model.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/technician_registration_model.dart';
import 'package:http/http.dart' as http;

class TechnicianRegRepository {
  final String _baseUrl =
      "https://el7rafeapp.azurewebsites.net";

  Future<Either<Failure, List<String>>> getServices() async {
    final Uri url = Uri.parse('$_baseUrl/api/public/services');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('services')) {
          if (responseBody['services'] is List) {
            return Right(List<String>.from(responseBody['services']));
          }
        }
      }
      return Left(Failure("خطأ في استرجاع قائمة الحرف"));
    } catch (e) {
      return Left(Failure("الرجاء التحقق من اتصالك بالانترنت"));
    }
  }

  Future<Either<Failure, String>> registerTechnician(
      TechnicianRegistrationRequestModel requestModel) async {
    final Uri registerUrl = Uri.parse('$_baseUrl/api/auth/register/technician');

    try {
      var request = http.MultipartRequest('POST', registerUrl);
      request.fields['Name'] = requestModel.name;
      request.fields['PhoneNumber'] = requestModel.phoneNumber;
      request.fields['Email'] = requestModel.email;
      request.fields['Password'] = requestModel.password;
      request.fields['Governorate'] = requestModel.governorate;
      request.fields['City'] = requestModel.city;
      request.fields['ServiceType'] = requestModel.serviceType;
      request.files.add(
        await http.MultipartFile.fromPath(
          'ProfilePicture',
          requestModel.profileImage.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'NationalIdFront',
          requestModel.frontIdImage.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'NationalIdBack',
          requestModel.backIdImage.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'CriminalRecord',
          requestModel.criminalRecordImage.path,
        ),
      );

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        authLocalStorage.saveTechnicianEmail(requestModel.email);
        return Right(
            'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني لإدخال رمز التحقق.');
      } else if (response.statusCode == 409) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 462) {
        return Left(Failure('BLOCKED'));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return Left(
          Failure("حصل خطأ أثناء التسجيل الرجاء التحقق من اتصالك بالانترنت."));
    }
  }

  Future<Either<Failure, UserModel>> checkTechnicianStatus(String token) async {
    final Uri statusUrl = Uri.parse('$_baseUrl/api/technician/check-approval');
    try {
      final response = await http.get(
        statusUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.saveUserSession(user);
        return Right(user);
      } else if (response.statusCode == 460) {
        return Left(Failure('PENDING'));
      } else if (response.statusCode == 461) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rejectedUser = RejectedUserModel.fromJson(data);
        RejectedLocalStorage rejectedLocalStorage = RejectedLocalStorage();
        await rejectedLocalStorage.saveRejectedTechnician(rejectedUser);
        return Left(Failure('REJECTED'));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      } else if (response.statusCode == 462) {
        await AuthLocalStorage().deleteTempToken();
        return Left(Failure('BLOCKED'));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return Left(Failure(
          "حصل خطأ أثناء جلب حالة الحساب. الرجاء التحقق من اتصالك بالانترنت."));
    }
  }

  Future<Either<Failure, bool>> resubmitTechnicianFiles(
    RejectedTechnicianModel requestModel,
    RejectedUser rejectedUser,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/api/technician/resubmit-documents');

    try {
      final req = http.MultipartRequest('PATCH', url);

      req.fields['PhoneNumber'] = rejectedUser.phone!;

      for (final file in rejectedUser.missingFiles) {
        if (file == "NationalIdFront") {
          req.files.add(await http.MultipartFile.fromPath(
            'NationalIdFront',
            requestModel.frontIdImage!.path,
          ));
        } else if (file == "NationalIdBack") {
          req.files.add(await http.MultipartFile.fromPath(
            'NationalIdBack',
            requestModel.backIdImage!.path,
          ));
        } else if (file == "CriminalRecord") {
          req.files.add(await http.MultipartFile.fromPath(
            'CriminalRecord',
            requestModel.criminalRecordImage!.path,
          ));
        }
      }

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final tempTechnician = TempTechnician(
          tempToken: data['tempToken'],
        );
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.deleteTempToken();
        await authLocalStorage.saveTempToken(tempTechnician);
        RejectedLocalStorage rejectedLocalStorage = RejectedLocalStorage();
        await rejectedLocalStorage.clearRejectedTechnician();
        return Right(true);
      } else if (response.statusCode == 462) {
        return Left(Failure('BLOCKED'));
      } else {
        return Left(Failure(jsonDecode(response.body)['errorMessage']));
      }
    } catch (e) {
      return Left(Failure(
          "حصل خطأ أثناء إعادة إرسال الملفات. الرجاء التحقق من اتصالك بالانترنت."));
    }
  }
}
