import 'dart:convert';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/current_reservation_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class CurrentReservationsRepo {
  final String _baseUrl = 'https://el7rafeapp.azurewebsites.net';
  HubConnection? _hubConnection;

  Future<List<CurrentReservationModel>> getCurrentReservations() async {
    final token = await _getTokenOrThrow();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/cf/getcurrentreservations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => CurrentReservationModel.fromJson(json))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTH');
    } else {
      throw Exception('حدث خطأ أثناء جلب البيانات');
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final token = await _getTokenOrThrow();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/tcf/cancelreservation/$reservationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) throw Exception('UNAUTH');
    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['errorMessage'] ?? 'لا يمكن إلغاء الحجز حالياً');
    }
    if (response.statusCode != 200) {
      throw Exception('فشل إلغاء الحجز، يرجى المحاولة لاحقاً');
    }
  }

  Future<void> payReservation(int reservationId) async {
    final token = await _getTokenOrThrow();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/cf/paynow/$reservationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) throw Exception('UNAUTH');
    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['errorMessage'] ??
          'الطلب ليس في حالة انتظار الدفع أو تم الدفع مسبقاً');
    }
    if (response.statusCode == 200) {
      return;
    }
    throw Exception('فشل في بدء عملية الدفع');
  }

  Future<void> rateJob({required int rate}) async {
    final token = await _getTokenOrThrow();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/reservations/rate?ratingValue=$rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('Rating response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 401) throw Exception('UNAUTH');
    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(
          data['errorMessage'] ?? 'الطلب لم يكتمل بعد أو تم التقييم مسبقاً');
    }
    if (response.statusCode != 200) throw Exception('فشل في إرسال التقييم');
  }

  Future<void> connectToHub({
    required Function(int) onJobStarted,
    required Function(int) onJobCompleted,
    required Function(int) onReservationCancelled,
    required Function(List<CurrentReservationModel>) onHttpFallback,
  }) async {
    try {
      final token = await _getTokenOrThrow();
      _hubConnection = HubConnectionBuilder()
          .withUrl('$_baseUrl/clientHub',
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
              ))
          .withAutomaticReconnect()
          .build();

      _hubConnection?.on("JobStarted", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final payload = arguments[0];
          if (payload is Map) {
            final int id = payload['requestId'] ?? payload['RequestId'] ?? 0;
            onJobStarted(id);
          } else if (payload is int) {
            onJobStarted(payload);
          }
        }
      });

      _hubConnection?.on("JobCompleted", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final payload = arguments[0];
          if (payload is Map) {
            final int id =
                payload['ReservationId'] ?? payload['reservationId'] ?? 0;
            onJobCompleted(id);
          } else if (payload is int) {
            onJobCompleted(payload);
          }
        }
      });

      _hubConnection?.on("ReservationCancelled", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final payload = arguments[0];
          if (payload is Map) {
            final int id =
                payload['reservationId'] ?? payload['ReservationId'] ?? 0;
            onReservationCancelled(id);
          } else if (payload is int) {
            onReservationCancelled(payload);
          }
        }
      });

      if (_hubConnection?.state == HubConnectionState.Disconnected) {
        await _hubConnection?.start();
      }
    } catch (e) {
      debugPrint("SignalR Connection Error: $e. Starting HTTP Fallback...");

      // Fallback: Poll the HTTP endpoint every 10 seconds
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 10));

        // If SignalR magically reconnects later, stop polling
        if (_hubConnection?.state == HubConnectionState.Connected) {
          return false;
        }

        try {
          // Call the endpoint
          final fallbackData = await getCurrentReservations();
          // Send the fresh list back to the UI
          onHttpFallback(fallbackData);
        } catch (httpError) {
          debugPrint("HTTP Fallback Error: $httpError");
        }

        return true; // Keep the loop running
      });
    }
  }

  Future<void> disconnectHub() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.stop();
    }
  }

  Future<String> _getTokenOrThrow() async {
    final String? token = await AuthLocalStorage().getToken();
    if (token == null || token.isEmpty) throw Exception('UNAUTH');
    return token;
  }
}
