import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class InboxRepository {
  final String baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";
  final String hubUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/chatHub";
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

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token ?? "",
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
          } catch (e) {
            throw Exception("فشل في معالجة تحديثات المحادثات");
          }
        }
      });

      await _hubConnection?.start();
    } catch (e) {
      throw Exception("فشل الاتصال بالخادم يرجي التحقق من الإنترنت");
    }
  }

  void disconnect() {
    _hubConnection?.stop();
  }
}
