import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class NotificationApiService {
  static const String _baseUrl = 'https://el7rafeapp.azurewebsites.net';

  static Future<bool> saveFcmToken(String fcmToken) async {
    try {
      final authStorage = AuthLocalStorage();
      final String? userToken = await authStorage.getToken();

      if (userToken == null || userToken.isEmpty) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/notify/save-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({"fcmToken": fcmToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteFcmToken() async {
    try {
      final authStorage = AuthLocalStorage();
      final String? userToken = await authStorage.getToken();

      if (userToken == null || userToken.isEmpty) return false;

      final url = Uri.parse('$_baseUrl/api/notify/delete-fcm-token');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
