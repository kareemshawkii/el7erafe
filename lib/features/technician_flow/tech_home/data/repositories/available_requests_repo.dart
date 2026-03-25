import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/in_progress_reservation_model.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;

class AvailableRequestsRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl =
      "https://el7rafeapp.azurewebsites.net";
  final String _hubUrl =
      "https://el7rafeapp.azurewebsites.net/technicianHub";

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
        throw Exception("401 Unauthorized");
      } else {
        throw Exception("فشل في جلب الطلبات المتاحة");
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        throw Exception("401 Unauthorized");
      }
      throw Exception("فشل الاتصال بالخادم");
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
    required Function() onForceDisconnect,
  }) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) throw Exception("401 Unauthorized");

      if (_hubConnection != null &&
          _hubConnection!.state != HubConnectionState.Disconnected) {
        await _hubConnection!.stop();
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl,
              options:
                  HttpConnectionOptions(accessTokenFactory: () async => token))
          .withAutomaticReconnect()
          .build();

      _hubConnection!.serverTimeoutInMilliseconds = 60000;
      _hubConnection!.keepAliveIntervalInMilliseconds = 30000;

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

      _hubConnection!.on("ReceiveNewQuickRequest", handleNewData);
      _hubConnection!.on("ReceiveNewDirectRequest", handleNewData);

      _hubConnection!
          .on("RemoveCanceledRequest", (_) => onSignalRRefreshNeeded());

      _hubConnection!.on("JobCompleted", (_) => onSignalRRefreshNeeded());

      _hubConnection!.on("ForceDisconnect", (_) => onForceDisconnect());

      _hubConnection!.onclose(({error}) async {
        await Future.delayed(const Duration(seconds: 3));
        if (_hubConnection?.state == HubConnectionState.Disconnected) {
          onSignalRRefreshNeeded();
        }
      });

      await _hubConnection!.start();
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        throw Exception("401 Unauthorized");
      }
      throw Exception("فشل الاتصال بالخادم");
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
    }
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
          "numberOfDays": numberOfDays,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم تقديم العرض بنجاح");
      }
      if (response.statusCode == 401) {
        await _authLocal.clearSession();
        return const Left("401");
      }
      return Left(jsonDecode(response.body)['errorMessage'] ??
          "فشل تقديم العرض، حاول مرة أخرى.");
    } catch (_) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت. الرجاء التحقق من اتصالك.");
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
      return Left(jsonDecode(response.body)['errorMessage'] ??
          "حدث خطأ أثناء رفض الطلب");
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) return const Left("401");
      return const Left(
          "فشل في الاتصال بالخادم برجاء التحقق من اتصالك بالانترنت");
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
        return const Right("تم انهاء العمل بنجاح وفي انتظار الدفع");
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      }
      return Left(jsonDecode(response.body)['errorMessage'] ??
          "حدث خطأ أثناء إنهاء العمل");
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) return const Left("401");
      return const Left(
          "فشل في الاتصال بالخادم برجاء التحقق من اتصالك بالانترنت");
    }
  }
}
