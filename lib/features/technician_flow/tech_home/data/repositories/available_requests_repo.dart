import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/in_progress_reservation_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class AvailableRequestsRepo {
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl = "https://el7rafeapp.azurewebsites.net";
  StreamSubscription? _fcmSubscription;

  Future<List<AvailableRequestModel>> getInitialAvailableRequests() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) throw Exception("401 Unauthorized");

      final url = Uri.parse("$_baseUrl/api/tech/getavailablerequests");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final listData =
            decodedData is List ? decodedData : decodedData['data'] as List;
        return listData
            .map((e) =>
                AvailableRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _authLocal.clearSession();
        throw Exception("401 Unauthorized");
      } else {
        try {
          final decodedData = jsonDecode(response.body);
          throw Exception(decodedData['errorMessage'] ?? "حدث خطأ غير متوقع");
        } catch (_) {
          throw Exception("حدث خطأ غير متوقع");
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<InProgressReservationModel?> getInProgressReservation() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse("$_baseUrl/api/tech/in-progress");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final listData =
            decodedData is List ? decodedData : decodedData['data'];
        if (listData is List && listData.isNotEmpty) {
          return InProgressReservationModel.fromJson(
              listData.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> connectAndListen({
    required Function(AvailableRequestModel) onNewRequestReceived,
    required Function() onSignalRRefreshNeeded,
    required Function() onPaymentReceived,
    required Function() onForceDisconnect,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) {
      if (action == 'PAYMENT_COMPLETED') {
        onPaymentReceived();
      } else if (action == 'NEW_REQUEST' ||
          action == 'REQUEST_CANCELLED' ||
          action == 'JOB_COMPLETED') {
        onSignalRRefreshNeeded();
      }
    });

    final hub = SignalRService.instance.techHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.techHub;
    if (activeHub == null) return;

    activeHub.off("ReceiveNewQuickRequest");
    activeHub.off("ReceiveNewDirectRequest");
    activeHub.off("RemoveCanceledRequest");
    activeHub.off("JobCompleted");
    activeHub.off("PaymentCompleted");
    activeHub.off("ForceDisconnect");

    void handleNewData(List<dynamic>? parameters) {
      if (parameters != null && parameters.isNotEmpty) {
        if (parameters.first is Map) {
          try {
            onNewRequestReceived(AvailableRequestModel.fromJson(
                Map<String, dynamic>.from(parameters.first)));
          } catch (_) {}
        }
      }
    }

    activeHub.on("ReceiveNewQuickRequest", handleNewData);
    activeHub.on("ReceiveNewDirectRequest", handleNewData);
    activeHub.on("RemoveCanceledRequest", (_) => onSignalRRefreshNeeded());
    activeHub.on("JobCompleted", (_) => onSignalRRefreshNeeded());

    activeHub.on("PaymentCompleted", (arguments) {
      onPaymentReceived();
    });

    activeHub.on("ForceDisconnect", (_) => onForceDisconnect());

    activeHub.onclose(({error}) {
      onSignalRRefreshNeeded();
    });

    activeHub.onreconnected(({connectionId}) {
      onSignalRRefreshNeeded();
    });
  }

  Future<void> disconnect() async {
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
    final hub = SignalRService.instance.techHub;
    if (hub == null) return;
    hub.off("ReceiveNewQuickRequest");
    hub.off("ReceiveNewDirectRequest");
    hub.off("RemoveCanceledRequest");
    hub.off("JobCompleted");
    hub.off("PaymentCompleted");
    hub.off("ForceDisconnect");
  }

  Future<Either<String, String>> submitOffer({
    required int requestId,
    required int fees,
    required String fromTime,
    required String toTime,
    int? numberOfDays,
  }) async {
    final token = await _authLocal.getToken();
    if (token == null || token.isEmpty) return const Left("401");
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tech/make-offer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "requestId": requestId,
          "fees": fees,
          "fromTime": fromTime,
          "toTime": toTime,
          "numberOfDays": numberOfDays
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم تقديم العرض بنجاح");
      }
      if (response.statusCode == 401) return const Left("401");
      try {
        final decodedData = jsonDecode(response.body);
        return Left(decodedData['errorMessage'] ?? "حدث خطأ غير متوقع");
      } catch (_) {
        return const Left("حدث خطأ غير متوقع");
      }
    } catch (_) {
      return const Left("حدث خطأ في الاتصال بالخادم");
    }
  }

  Future<Either<String, String>> declineRequest(int requestId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final response = await http.patch(
        Uri.parse("$_baseUrl/api/tech/decline-request"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'requestId': requestId}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم رفض الطلب بنجاح");
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      }
      try {
        final decodedData = jsonDecode(response.body);
        return Left(decodedData['errorMessage'] ?? "حدث خطأ غير متوقع");
      } catch (_) {
        return const Left("حدث خطأ غير متوقع");
      }
    } catch (e) {
      return const Left("حدث خطأ في الاتصال بالخادم");
    }
  }

  Future<Either<String, String>> completeJob(int reservationId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final response = await http.post(
        Uri.parse("$_baseUrl/api/tech/complete-job"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'reservationId': reservationId}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم إكمال الوظيفة بنجاح ,في انتظار الدفع");
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      }
      try {
        final decodedData = jsonDecode(response.body);
        return Left(decodedData['errorMessage'] ?? "حدث خطأ غير متوقع");
      } catch (_) {
        return const Left("حدث خطأ غير متوقع");
      }
    } catch (e) {
      return const Left("حدث خطأ في الاتصال بالخادم");
    }
  }
}
