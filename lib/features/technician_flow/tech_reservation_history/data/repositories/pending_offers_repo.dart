import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/pending_offer_model.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;

class PendingOffersRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";
  final String _hubUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/technicianHub";

  Future<Either<String, List<PendingOfferModel>>> getPendingOffers() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");

      final url = Uri.parse("$_baseUrl/api/tech/pending-offers");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final listData =
            decodedData is List ? decodedData : decodedData['data'] as List;
        return Right(listData
            .map((e) => PendingOfferModel.fromJson(e as Map<String, dynamic>))
            .toList());
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      } else {
        return const Left("Failed to fetch pending offers");
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        return const Left("401");
      }
      return const Left("Server connection failed");
    }
  }

  Future<void> connectAndListen({
    required Function() onSignalRRefreshNeeded,
    required Function() onForceDisconnect,
  }) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return;

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
              ))
          .withAutomaticReconnect()
          .build();

      _hubConnection!.serverTimeoutInMilliseconds = 60000;
      _hubConnection!.keepAliveIntervalInMilliseconds = 30000;

      _hubConnection!.on("OfferRejected", (_) => onSignalRRefreshNeeded());
      _hubConnection!.on("OfferAccepted", (_) => onSignalRRefreshNeeded());

      _hubConnection!.on("ForceDisconnect", (_) => onForceDisconnect());

      await _hubConnection!.start();
    } catch (_) {}
  }

  Future<void> disconnect() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
    }
  }
}
