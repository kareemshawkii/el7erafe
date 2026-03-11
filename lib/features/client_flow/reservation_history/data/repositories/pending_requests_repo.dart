import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/pending_request_model.dart';
import 'package:signalr_netcore/signalr_client.dart';

class PendingRequestsRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _hubUrl = "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/clientHub";

  Future<void> connectAndListen(Function(List<PendingRequestModel>) onDataReceived) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 Unauthorized");
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl, options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ))
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on("ReceivePendingRequests", (List<dynamic>? parameters) {
        if (parameters != null && parameters.isNotEmpty) {
          final rawData = parameters.first;
          if (rawData is List) {
            final parsedList = rawData.map((e) => PendingRequestModel.fromJson(e as Map<String, dynamic>)).toList();
            onDataReceived(parsedList);
          }
        }
      });

      await _hubConnection!.start();
      await _hubConnection!.invoke("RequestMyPendingData");
      
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        throw Exception("401 Unauthorized");
      }
      throw Exception("فشل الاتصال بالخادم: ${e.toString()}");
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
    }
  }
}