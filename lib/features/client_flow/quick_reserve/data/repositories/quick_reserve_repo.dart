import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class ServiceRequestRepository {
  final String baseUrl = "https://el7rafeapp.azurewebsites.net";

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

      multipartRequest.fields['ServiceId'] = request.serviceId.toString();
      multipartRequest.fields['Description'] = request.description ?? "";
      if (request.city != null) {
        multipartRequest.fields['CityName'] = request.city!;
      }
      if (request.street != null) {
        multipartRequest.fields['Street'] = request.street!;
      }
      if (request.specialSign != null) {
        multipartRequest.fields['SpecialSign'] = request.specialSign!;
      }
      if (request.day != null) {
        multipartRequest.fields['ServiceDate'] =
            request.day!.toIso8601String().split('T').first;
      }

      multipartRequest.fields['AllDayAvailability'] =
          request.allDayAvailability ? "true" : "false";

      if (!request.allDayAvailability) {
        if (request.availableFrom != null) {
          multipartRequest.fields['AvailableFrom'] = request.availableFrom!;
        }
        if (request.availableTo != null) {
          multipartRequest.fields['AvailableTo'] = request.availableTo!;
        }
      }

      if (request.images != null && request.images!.isNotEmpty) {
        for (var imageFile in request.images!) {
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();
          var multipartFile = http.MultipartFile(
            'Images',
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
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401 unauthorized");
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return Left("409 ${errorBody['errorMessage']}");
      } else {
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          return Left(errorBody['errorMessage'] ?? "فشل إرسال الطلب");
        } catch (_) {
          return const Left("فشل إرسال الطلب، حاول مرة أخرى");
        }
      }
    } catch (e) {
      return const Left("خطأ في الاتصال، تأكد من الإنترنت");
    }
  }
}
