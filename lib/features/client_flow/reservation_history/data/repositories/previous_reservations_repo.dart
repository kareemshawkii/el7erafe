import 'dart:convert';
import 'package:el7erafe/core/services/notifications/notification_api_service.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/previous_reservation_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class PreviousReservationsRepo {
  final String _baseUrl = 'https://el7rafeapp.azurewebsites.net';

  Future<List<PreviousReservationModel>> getPreviousReservations() async {
    final authStorage = AuthLocalStorage();
    final String? token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('UNAUTH');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/cf/getprevreservations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => PreviousReservationModel.fromJson(json))
          .toList();
    } else if (response.statusCode == 401) {
      await FirebaseMessaging.instance.deleteToken();
      await NotificationApiService.deleteFcmToken();
      await authStorage.clearSession();
      throw Exception('UNAUTH');
    } else {
      throw Exception('حدث خطأ أثناء جلب البيانات');
    }
  }
}
