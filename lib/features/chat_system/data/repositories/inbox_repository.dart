import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/services/notifications/notification_api_service.dart';
import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class InboxRepository {
  final String baseUrl = "https://el7rafeapp.azurewebsites.net";
  final String hubUrl = "https://el7rafeapp.azurewebsites.net/chatHub";
  HubConnection? _hubConnection;

  Future<Either<List<InboxConversationModel>, String>> getInbox() async {
    AuthLocalStorage authLocalStorage = AuthLocalStorage();
    String? token = await authLocalStorage.getToken();
    String? userType = await authLocalStorage.getUserType();

    String endpoint = (userType == 'T') ? '/api/tech/inbox' : '/api/cf/inbox';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return Left(
            data.map((json) => InboxConversationModel.fromJson(json)).toList());
      } else if (response.statusCode == 401) {
        await FirebaseMessaging.instance.deleteToken();
        await NotificationApiService.deleteFcmToken();
        await authLocalStorage.clearSession();
        return const Right("401 unauthorized");
      } else {
        return const Right("فشل في تحميل المحادثات");
      }
    } catch (e) {
      return const Right("خطأ في الاتصال، تأكد من الإنترنت");
    }
  }

  Future<void> initSignalR({
    Function(List<InboxConversationModel>)? onInboxUpdated,
  }) async {
    try {
      String? token = await AuthLocalStorage().getToken();
      if (token == null || token.isEmpty) return;

      if (_hubConnection != null &&
          _hubConnection!.state != HubConnectionState.Disconnected) {
        await _hubConnection!.stop();
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
              ))
          .withAutomaticReconnect()
          .build();

      _hubConnection?.serverTimeoutInMilliseconds = 60000;
      _hubConnection?.keepAliveIntervalInMilliseconds = 30000;

      _hubConnection?.on("InboxUpdated", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final List<dynamic> data = arguments[0] as List<dynamic>;

            final updatedInbox = data
                .map((json) => InboxConversationModel.fromJson(
                    json as Map<String, dynamic>))
                .toList();

            if (onInboxUpdated != null) {
              onInboxUpdated(updatedInbox);
            }
          } catch (_) {}
        }
      });

      _hubConnection!.onclose(({error}) async {
        await _fallbackToApi(onInboxUpdated);
        _reconnectLoop(onInboxUpdated);
      });

      await _startConnection(onInboxUpdated);
    } catch (_) {
      await _fallbackToApi(onInboxUpdated);
      _reconnectLoop(onInboxUpdated);
    }
  }

  Future<void> _startConnection(
      Function(List<InboxConversationModel>)? onInboxUpdated) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Disconnected) {
        await _hubConnection!.start();
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        return;
      }
      await _fallbackToApi(onInboxUpdated);
      _reconnectLoop(onInboxUpdated);
    }
  }

  void _reconnectLoop(
      Function(List<InboxConversationModel>)? onInboxUpdated) async {
    await Future.delayed(const Duration(seconds: 5));
    if (_hubConnection?.state == HubConnectionState.Disconnected) {
      await _startConnection(onInboxUpdated);
    }
  }

  Future<void> _fallbackToApi(
      Function(List<InboxConversationModel>)? onInboxUpdated) async {
    if (onInboxUpdated != null) {
      final result = await getInbox();
      result.fold(
        (data) => onInboxUpdated(data),
        (_) => null,
      );
    }
  }

  void disconnect() {
    _hubConnection?.stop();
  }
}
