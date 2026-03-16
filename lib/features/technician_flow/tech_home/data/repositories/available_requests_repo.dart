import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;

class AvailableRequestsRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";
  final String _hubUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/technicianHub";

  Future<List<AvailableRequestModel>> getInitialAvailableRequests() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 Unauthorized");
      }

      final url = Uri.parse("$_baseUrl/api/tech/getavailablerequests");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((e) =>
                  AvailableRequestModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('data')) {
          final listData = decodedData['data'] as List;
          return listData
              .map((e) =>
                  AvailableRequestModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("401 Unauthorized");
      } else {
        throw Exception("فشل في جلب الطلبات المتاحة");
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        throw Exception("401 Unauthorized");
      }
      throw Exception("فشل الاتصال بالخادم: ${e.toString()}");
    }
  }

  Future<void> connectAndListen({
    required Function(AvailableRequestModel) onNewRequestReceived,
    required Function() onForceDisconnect,
  }) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 Unauthorized");
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
              ))
          .withAutomaticReconnect()
          .build();

      void handleNewData(List<dynamic>? parameters) {
        if (parameters != null && parameters.isNotEmpty) {
          final rawData = parameters.first;
          if (rawData is Map) {
            try {
              final Map<String, dynamic> typedMap =
                  Map<String, dynamic>.from(rawData);
              final parsedSingle = AvailableRequestModel.fromJson(typedMap);
              onNewRequestReceived(parsedSingle);
            } catch (e) {
              throw Exception(
                  "فشل في معالجة البيانات الواردة: ${e.toString()}");
            }
          }
        }
      }

      _hubConnection!.on("ReceiveNewQuickRequest", handleNewData);
      _hubConnection!.on("ReceiveNewDirectRequest", handleNewData);

      _hubConnection!.on("ForceDisconnect", (List<dynamic>? parameters) {
        onForceDisconnect();
      });

      await _hubConnection!.start();
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        throw Exception("401 Unauthorized");
      }
      throw Exception("فشل الاتصال بالخادم: ${e.toString()}");
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
    }
  }

  Future<Either<String, String>> submitOffer({
    required int requestId,
    required double fees,
    required String fromTime,
    required String toTime,
    int? numberOfDays,
  }) async {
    final token = await _authLocal.getToken();
    if (token == null || token.isEmpty) {
      return const Left("401");
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tech/make-offer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
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
      } else if (response.statusCode == 401) {
        AuthLocalStorage authLocalStorage = AuthLocalStorage();
        await authLocalStorage.clearSession();
        return const Left("401");
      } else {
        final decoded = jsonDecode(response.body);
        return Left(
            decoded['errorMessage'] ?? "فشل تقديم العرض، حاول مرة أخرى.");
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت. الرجاء التحقق من اتصالك.");
    }
  }
}
