import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/tech_schedule_model.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TechScheduleRepository {
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";
  final String _cacheKey = "tech_schedule_cache";

  Future<Either<String, List<TechScheduleModel>>> getSchedule(
      String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final List<dynamic> data = json.decode(cachedData);
        final schedule =
            data.map((json) => TechScheduleModel.fromJson(json)).toList();
        return Right(schedule);
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/tech/availability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.setString(_cacheKey, response.body);
        final List<dynamic> data = json.decode(response.body);
        final schedule =
            data.map((json) => TechScheduleModel.fromJson(json)).toList();
        return Right(schedule);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      } else {
        return const Left("فشل في جلب المواعيد، يرجى المحاولة مرة أخرى");
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('401') || err.contains('unauthorized')) {
        return const Left("401");
      }
      return const Left("فشل الاتصال بالخادم، يرجى التحقق من الإنترنت");
    }
  }

  Future<Either<String, String>> updateSchedule(
      String token, List<TechScheduleModel> schedule) async {
    try {
      final body = json.encode(schedule.map((e) => e.toJson()).toList());
      debugPrint("Request Body: $body"); // Debug print for request body
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tech/availability/set'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
        return const Right("تم حفظ المواعيد بنجاح");
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      } else {
        final decoded = json.decode(response.body);
        return Left(decoded['errorMessage'] ?? "فشل حفظ المواعيد");
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('401') || err.contains('unauthorized')) {
        return const Left("401");
      }
      return const Left("فشل الاتصال بالخادم، يرجى التحقق من الإنترنت");
    }
  }
}
