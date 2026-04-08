import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/notifications/notification_api_service.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/offers_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/pending_request_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;

class PendingRequestsRepo {
  HubConnection? _hubConnection;
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl = "https://el7rafeapp.azurewebsites.net";
  final String _hubUrl = "https://el7rafeapp.azurewebsites.net/clientHub";

  Future<List<PendingRequestModel>> getInitialPendingRequests() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
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
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        throw Exception("401 Unauthorized");
      } else {
        throw Exception("Failed to fetch pending requests");
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        throw Exception("401 Unauthorized");
      }
      throw Exception("Server connection failed");
    }
  }

  Future<void> connectAndListen({
    required Function(List<PendingRequestModel>) onListDataReceived,
    required Function(PendingRequestModel) onSingleDataReceived,
    required Function() onSignalRRefreshNeeded,
    required Function() onForceDisconnect,
  }) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        onForceDisconnect();
        return;
      }

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

      _hubConnection!.on("ReceivePendingRequests", (List<dynamic>? parameters) {
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

      _hubConnection!.on("ReceiveNewOffer", (_) => onSignalRRefreshNeeded());

      _hubConnection!.on("RequestRejected", (_) => onSignalRRefreshNeeded());

      _hubConnection!.on("ForceDisconnect", (_) => onForceDisconnect());

      _hubConnection!.onclose(({error}) async {
        onSignalRRefreshNeeded();
        _reconnectLoop(onSignalRRefreshNeeded, onForceDisconnect);
      });

      await _startConnection(onSignalRRefreshNeeded, onForceDisconnect);
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        onForceDisconnect();
      } else {
        onSignalRRefreshNeeded();
      }
    }
  }

  Future<void> _startConnection(
      Function() onFallback, Function() onForceDisconnect) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Disconnected) {
        await _hubConnection!.start();
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        onForceDisconnect();
        return;
      }
      onFallback();
      _reconnectLoop(onFallback, onForceDisconnect);
    }
  }

  void _reconnectLoop(
      Function() onFallback, Function() onForceDisconnect) async {
    await Future.delayed(const Duration(seconds: 5));
    if (_hubConnection?.state == HubConnectionState.Disconnected) {
      await _startConnection(onFallback, onForceDisconnect);
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
    }
  }

  Future<Either<String, List<OfferModel>>> getQuickOffers(int requestId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }

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
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      } else {
        return const Left("فشل في جلب العروض");
      }
    } catch (e) {
      return const Left(
          "فشل في الاتصال بالخادم برجاء التحقق من اتصالك بالانترنت");
    }
  }

  Future<Either<String, String>> cancelRequest(int requestId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
      final url = Uri.parse("$_baseUrl/api/cf/cancel-request");
      final response = await http.patch(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'requestId': requestId}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم الغاء الطلب بنجاح");
      }
      if (response.statusCode == 401) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
      return Left(jsonDecode(response.body)['errorMessage'] ?? "حدث خطأ");
    } catch (_) {
      return const Left("فشل الاتصال بالخادم");
    }
  }

  Future<Either<String, String>> acceptOffer(int offerId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
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
      if (response.statusCode == 401) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
      return Left(jsonDecode(response.body)['errorMessage'] ?? "حدث خطأ");
    } catch (_) {
      return const Left("فشل الاتصال بالخادم");
    }
  }

  Future<Either<String, String>> declineOffer(int offerId) async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
      final url = Uri.parse("$_baseUrl/api/cf/offers/decline");
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'offerId': offerId}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right("تم رفض العرض");
      }
      if (response.statusCode == 401) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await _authLocal.clearSession();
        return const Left("401");
      }
      return Left(jsonDecode(response.body)['errorMessage'] ?? "حدث خطأ");
    } catch (_) {
      return const Left("فشل الاتصال بالخادم");
    }
  }
}
