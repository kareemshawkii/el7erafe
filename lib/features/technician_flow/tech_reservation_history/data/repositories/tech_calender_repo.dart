import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/technician_calender_model.dart';
import 'package:http/http.dart' as http;

class TechCalendarRepo {
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl = "https://el7rafeapp.azurewebsites.net";

  Future<Either<String, List<TechReservationModel>>> getCalendarReservations(
      String date) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      }

      final url = Uri.parse("$_baseUrl/api/tech/calendar?date=$date");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return Right(decodedData
              .map((e) =>
                  TechReservationModel.fromJson(e as Map<String, dynamic>))
              .toList());
        }
        return const Right([]);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      } else {
        return const Left("فشل في جلب الحجوزات");
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      }
      return const Left("فشل الاتصال بالخادم");
    }
  }

  Future<Either<String, String>> startJob(int reservationId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      }

      final url = Uri.parse("$_baseUrl/api/tech/start-job");
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reservationId': reservationId}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم بدء العمل بنجاح");
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      } else {
        return Left(jsonDecode(response.body)['errorMessage'] ??
            "حدث خطأ أثناء بدء العمل");
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      }
      return const Left("فشل الاتصال بالخادم");
    }
  }
}
