import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/offers_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/pending_request_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class PendingRequestsRepo {
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl = "https://el7rafeapp.azurewebsites.net";
  StreamSubscription? _fcmSubscription;

  Future<List<PendingRequestModel>> getInitialPendingRequests() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await _authLocal.clearSession();
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
        await _authLocal.clearSession();
        throw Exception("401 Unauthorized");
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      throw Exception("Error");
    }
  }

  Future<void> connectAndListen({
    required Function(List<PendingRequestModel>) onListDataReceived,
    required Function(PendingRequestModel) onSingleDataReceived,
    required Function() onSignalRRefreshNeeded,
    required Function() onForceDisconnect,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) {
      if (action == 'NEW_OFFER' || action == 'REQUEST_REJECTED') {
        onSignalRRefreshNeeded();
      }
    });

    final hub = SignalRService.instance.clientHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.clientHub;
    if (activeHub == null) return;

    activeHub.off("ReceivePendingRequests");
    activeHub.off("ReceiveNewOffer");
    activeHub.off("RequestRejected");
    activeHub.off("ForceDisconnect");

    activeHub.on("ReceivePendingRequests", (List<dynamic>? parameters) {
      if (parameters != null && parameters.isNotEmpty) {
        try {
          final rawData = parameters.first;
          dynamic parsedData =
              rawData is String ? jsonDecode(rawData) : rawData;

          if (parsedData is List) {
            onListDataReceived(parsedData
                .map((e) =>
                    PendingRequestModel.fromJson(e as Map<String, dynamic>))
                .toList());
          } else if (parsedData is Map) {
            onSingleDataReceived(PendingRequestModel.fromJson(
                Map<String, dynamic>.from(parsedData)));
          }
        } catch (_) {}
      }
    });

    activeHub.on("ReceiveNewOffer", (_) => onSignalRRefreshNeeded());
    activeHub.on("RequestRejected", (_) => onSignalRRefreshNeeded());
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
    final hub = SignalRService.instance.clientHub;
    if (hub == null) return;
    hub.off("ReceivePendingRequests");
    hub.off("ReceiveNewOffer");
    hub.off("RequestRejected");
    hub.off("ForceDisconnect");
  }

  Future<Either<String, List<OfferModel>>> getQuickOffers(int requestId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final url =
          Uri.parse("$_baseUrl/api/cf/offers/quick?requestId=$requestId");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final listData =
            decodedData is List ? decodedData : decodedData['data'] as List;
        return Right(listData
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList());
      }
      return const Left("Error");
    } catch (_) {
      return const Left("Error");
    }
  }

  Future<Either<String, String>> cancelRequest(int requestId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final url = Uri.parse("$_baseUrl/api/cf/cancel-request");
      final response = await http.patch(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'requestId': requestId}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم إلغاء الطلب بنجاح");
      }
      return const Left("Error");
    } catch (_) {
      return const Left("Error");
    }
  }

  Future<Either<String, String>> acceptOffer(int offerId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final url = Uri.parse("$_baseUrl/api/cf/offers/accept");
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'offerId': offerId}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم قبول العرض بنجاح");
      }
      return const Left("Error");
    } catch (_) {
      return const Left("Error");
    }
  }

  Future<Either<String, String>> declineOffer(int offerId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");
      final url = Uri.parse("$_baseUrl/api/cf/offers/decline");
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'offerId': offerId}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم رفض العرض بنجاح");
      }
      return const Left("Error");
    } catch (_) {
      return const Left("Error");
    }
  }
}
