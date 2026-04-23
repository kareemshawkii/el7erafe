import 'dart:async';
import 'dart:convert';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/current_reservation_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class CurrentReservationsRepo {
  final String _baseUrl = 'https://el7rafeapp.azurewebsites.net';
  StreamSubscription? _fcmSubscription;

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
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['errorMessage'] ?? 'حدث خطأ غير متوقع');
      } catch (_) {
        throw Exception('حدث خطأ غير متوقع');
      }
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
    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['errorMessage'] ?? 'حدث خطأ غير متوقع');
      } catch (_) {
        throw Exception('حدث خطأ غير متوقع');
      }
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
    if (response.statusCode == 200) return;
    try {
      final data = jsonDecode(response.body);
      throw Exception(data['errorMessage'] ?? 'حدث خطأ غير متوقع');
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  Future<void> rateJob({required int rate, required int reservationId}) async {
    final token = await _getTokenOrThrow();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/cf/rate/$reservationId?ratingValue=$rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) throw Exception('UNAUTH');
    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['errorMessage'] ?? 'حدث خطأ غير متوقع');
      } catch (_) {
        throw Exception('حدث خطأ غير متوقع');
      }
    }
  }

  Future<void> connectToHub({
    required Function(int) onJobStarted,
    required Function(int) onJobCompleted,
    required Function(int) onReservationCancelled,
    required Function(List<CurrentReservationModel>) onHttpFallback,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) async {
      if (action == 'JOB_STARTED' ||
          action == 'JOB_COMPLETED' ||
          action == 'RESERVATION_CANCELLED') {
        try {
          final fallbackData = await getCurrentReservations();
          onHttpFallback(fallbackData);
        } catch (_) {}
      }
    });

    final hub = SignalRService.instance.clientHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.clientHub;
    if (activeHub == null) return;

    activeHub.off("JobStarted");
    activeHub.off("JobCompleted");
    activeHub.off("ReservationCancelled");

    activeHub.on("JobStarted", (arguments) {
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

    activeHub.on("JobCompleted", (arguments) {
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

    activeHub.on("ReservationCancelled", (arguments) {
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

    activeHub.onclose(({error}) async {
      try {
        final fallbackData = await getCurrentReservations();
        onHttpFallback(fallbackData);
      } catch (_) {}
    });

    activeHub.onreconnected(({connectionId}) async {
      try {
        final fallbackData = await getCurrentReservations();
        onHttpFallback(fallbackData);
      } catch (_) {}
    });
  }

  Future<void> disconnectHub() async {
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
    final hub = SignalRService.instance.clientHub;
    if (hub == null) return;
    hub.off("JobStarted");
    hub.off("JobCompleted");
    hub.off("ReservationCancelled");
  }

  Future<String> _getTokenOrThrow() async {
    final String? token = await AuthLocalStorage().getToken();
    if (token == null || token.isEmpty) throw Exception('UNAUTH');
    return token;
  }
}
