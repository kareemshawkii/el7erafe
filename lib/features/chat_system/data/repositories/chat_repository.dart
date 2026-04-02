import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatRepository {
  final String hubUrl = "https://el7rafeapp.azurewebsites.net/chatHub";
  HubConnection? _hubConnection;

  Future<void> initConnection({
    Function(ChatMessageModel)? onMessageReceived,
    Function(int messageId, String newStatus)? onMessageStatusUpdated,
    Function(int chatId, List<int> messageIds, String newStatus)?
        onMessagesRead,
    Function(String)? onUserOnline,
    Function(String)? onUserOffline,
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

      _hubConnection?.on("ReceiveMessage", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final message =
                ChatMessageModel.fromJson(arguments[0] as Map<String, dynamic>);
            if (onMessageReceived != null) onMessageReceived(message);
          } catch (_) {}
        }
      });

      _hubConnection?.on("MessageStatusUpdated", (arguments) {
        if (arguments != null && arguments.length >= 2) {
          try {
            final int messageId = arguments[0] as int;
            final String newStatus = arguments[1] as String;
            if (onMessageStatusUpdated != null) {
              onMessageStatusUpdated(messageId, newStatus);
            }
          } catch (_) {}
        }
      });

      _hubConnection?.on("MessagesRead", (arguments) {
        if (arguments != null && arguments.length >= 3) {
          try {
            final int chatId = arguments[0] as int;
            final List<int> updatedMessageIds =
                (arguments[1] as List<dynamic>).map((e) => e as int).toList();
            final String newStatus = arguments[2] as String;

            if (onMessagesRead != null) {
              onMessagesRead(chatId, updatedMessageIds, newStatus);
            }
          } catch (_) {}
        }
      });

      _hubConnection?.on("UserOnline", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          if (onUserOnline != null) onUserOnline(arguments[0].toString());
        }
      });

      _hubConnection?.on("UserOffline", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          if (onUserOffline != null) onUserOffline(arguments[0].toString());
        }
      });

      _hubConnection!.onclose(({error}) async {
        _reconnectLoop(
          onMessageReceived: onMessageReceived,
          onMessageStatusUpdated: onMessageStatusUpdated,
          onMessagesRead: onMessagesRead,
          onUserOnline: onUserOnline,
          onUserOffline: onUserOffline,
        );
      });

      await _startConnection(
        onMessageReceived: onMessageReceived,
        onMessageStatusUpdated: onMessageStatusUpdated,
        onMessagesRead: onMessagesRead,
        onUserOnline: onUserOnline,
        onUserOffline: onUserOffline,
      );
    } catch (_) {
      _reconnectLoop(
        onMessageReceived: onMessageReceived,
        onMessageStatusUpdated: onMessageStatusUpdated,
        onMessagesRead: onMessagesRead,
        onUserOnline: onUserOnline,
        onUserOffline: onUserOffline,
      );
    }
  }

  Future<void> _startConnection({
    Function(ChatMessageModel)? onMessageReceived,
    Function(int messageId, String newStatus)? onMessageStatusUpdated,
    Function(int chatId, List<int> messageIds, String newStatus)?
        onMessagesRead,
    Function(String)? onUserOnline,
    Function(String)? onUserOffline,
  }) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Disconnected) {
        await _hubConnection!.start();
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('401')) {
        return;
      }
      _reconnectLoop(
        onMessageReceived: onMessageReceived,
        onMessageStatusUpdated: onMessageStatusUpdated,
        onMessagesRead: onMessagesRead,
        onUserOnline: onUserOnline,
        onUserOffline: onUserOffline,
      );
    }
  }

  void _reconnectLoop({
    Function(ChatMessageModel)? onMessageReceived,
    Function(int messageId, String newStatus)? onMessageStatusUpdated,
    Function(int chatId, List<int> messageIds, String newStatus)?
        onMessagesRead,
    Function(String)? onUserOnline,
    Function(String)? onUserOffline,
  }) async {
    await Future.delayed(const Duration(seconds: 5));
    if (_hubConnection?.state == HubConnectionState.Disconnected) {
      await _startConnection(
        onMessageReceived: onMessageReceived,
        onMessageStatusUpdated: onMessageStatusUpdated,
        onMessagesRead: onMessagesRead,
        onUserOnline: onUserOnline,
        onUserOffline: onUserOffline,
      );
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(
      int chatId, int page, int pageSize) async {
    if (_hubConnection?.state != HubConnectionState.Connected) {
      await initConnection();
    }
    try {
      final result = await _hubConnection
          ?.invoke("GetChatHistory", args: [chatId, page, pageSize]);
      if (result != null) {
        final List<dynamic> data = result as List<dynamic>;
        return data
            .map((json) =>
                ChatMessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception("فشل في جلب سجل المحادثة");
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    if (_hubConnection?.state != HubConnectionState.Connected) {
      await initConnection();
    }
    try {
      await _hubConnection?.invoke("SendMessage", args: [
        {"receiverId": receiverId, "content": content, "messageType": "Text"}
      ]);
    } catch (e) {
      throw Exception("فشل في إرسال الرسالة");
    }
  }

  Future<void> markMessagesAsRead(int chatId, String otherUserId) async {
    if (_hubConnection?.state != HubConnectionState.Connected) {
      await initConnection();
    }
    try {
      await _hubConnection
          ?.invoke("MarkMessagesAsRead", args: [chatId, otherUserId]);
    } catch (e) {
      throw Exception("فشل في تحديد الرسائل كمقروءة");
    }
  }

  void disconnect() {
    _hubConnection?.stop();
  }
}
