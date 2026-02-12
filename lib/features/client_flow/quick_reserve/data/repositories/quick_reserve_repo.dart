import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ServiceRequestRepository {
  final String baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";

  Future<Either<String, String>> submitQuickReservation(
      ReservationRequest request) async {
    try {
      final Uri url = Uri.parse('$baseUrl/api/cf/reservations/quick');

      AuthLocalStorage authLocalStorage = AuthLocalStorage();
      String? token = await authLocalStorage.getToken();

      var multipartRequest = http.MultipartRequest('POST', url);

      multipartRequest.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      multipartRequest.fields['service_id'] = request.serviceId.toString();
      multipartRequest.fields['description'] = request.description ?? "";
      if (request.governorate != null) {
        multipartRequest.fields['governorate'] = request.governorate!;
      }
      if (request.city != null) multipartRequest.fields['city'] = request.city!;
      if (request.street != null) {
        multipartRequest.fields['street'] = request.street!;
      }
      if (request.specialSign != null) {
        multipartRequest.fields['special_sign'] = request.specialSign!;
      }
      if (request.day != null) {
        multipartRequest.fields['day'] = request.day!
            .toIso8601String()
            .split('T')
            .first; // Format YYYY-MM-DD
      }

      multipartRequest.fields['allDayAvialabilty'] =
          request.allDayAvailability ? "1" : "0";

      if (!request.allDayAvailability) {
        if (request.availableFrom != null) {
          multipartRequest.fields['avialable_from'] = request.availableFrom!;
        }
        if (request.availableTo != null) {
          multipartRequest.fields['avialable_to'] = request.availableTo!;
        }
      }

      if (request.images != null && request.images!.isNotEmpty) {
        for (var imageFile in request.images!) {
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();
          var multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: imageFile.path.split('/').last,
          );
          multipartRequest.files.add(multipartFile);
        }
      }
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right("تم إرسال الطلب بنجاح");
      } else if (response.statusCode == 401) {
        return const Left("غير مصرح لك، برجاء تسجيل الدخول");
      } else {
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          return Left(errorBody['message'] ?? "فشل إرسال الطلب");
        } catch (_) {
          return const Left("فشل إرسال الطلب، حاول مرة أخرى");
        }
      }
    } catch (e) {
      return const Left("خطأ في الاتصال، تأكد من الإنترنت");
    }
  }
}
