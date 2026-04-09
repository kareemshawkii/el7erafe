import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/previous_jobs_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class PreviousJobsRepo {
  final String _baseUrl = 'https://el7rafeapp.azurewebsites.net';

  Future<Either<String, List<PreviousJobsModel>>> getPreviousJobs() async {
    try {
      final token = await AuthLocalStorage().getToken();
      if (token == null) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/tech/previous-jobs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final jobs = data.map((e) => PreviousJobsModel.fromJson(e)).toList();
        return Right(jobs);
      } else if (response.statusCode == 401) {
        await AuthLocalStorage().clearSession();
        return const Left("401");
      } else {
        final data = jsonDecode(response.body);
        return Left(data['errorMessage'] ?? "فشل في جلب الطلبات السابقة");
      }
    } catch (e) {
      return  Left(e.toString());
    }
  }
}
