import 'dart:convert';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/pending_request_model.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;

class PendingRequestsRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";
  final String _hubUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/clientHub";

  Future<List<PendingRequestModel>> getInitialPendingRequests() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 Unauthorized");
      }

      final url = Uri.parse("$_baseUrl/api/cf/getpendingservicerequests");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((e) =>
                  PendingRequestModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('data')) {
          final listData = decodedData['data'] as List;
          return listData
              .map((e) =>
                  PendingRequestModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("401 Unauthorized");
      } else {
        throw Exception("فشل في جلب الطلبات قيد الانتظار");
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
    required Function(List<PendingRequestModel>) onListDataReceived,
    required Function(PendingRequestModel) onSingleDataReceived,
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

      _hubConnection!.on("ReceivePendingRequests", (List<dynamic>? parameters) {
        if (parameters != null && parameters.isNotEmpty) {
          final rawData = parameters.first;
          if (rawData is List) {
            final parsedList = rawData
                .map((e) =>
                    PendingRequestModel.fromJson(e as Map<String, dynamic>))
                .toList();
            onListDataReceived(parsedList);
          } else if (rawData is Map<String, dynamic>) {
            final parsedSingle = PendingRequestModel.fromJson(rawData);
            onSingleDataReceived(parsedSingle);
          }
        }
      });

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
}
