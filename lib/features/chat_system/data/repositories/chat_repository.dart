import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class ChatRepository {
  final String baseUrl = "https://el7rafeapp.azurewebsites.net";
  StreamSubscription? _fcmSubscription;

  Future<int> initChat(int reservationId) async {
    String? token = await AuthLocalStorage().getToken();
    if (token == null || token.isEmpty) throw Exception("Unauthorized");

    final response = await http.post(
      Uri.parse('$baseUrl/api/tcf/chat/init/$reservationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final int? rawId = int.tryParse(response.body.trim());
      if (rawId != null) return rawId;

      try {
        final decodedData = jsonDecode(response.body);
        return (decodedData['id'] ?? decodedData['chatId']) as int;
      } catch (_) {
        throw Exception("حدث خطأ غير متوقع");
      }
    } else {
      try {
        final decodedData = jsonDecode(response.body);
        throw Exception(decodedData['errorMessage'] ?? 'حدث خطأ غير متوقع');
      } catch (_) {
        throw Exception("حدث خطأ غير متوقع");
      }
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(
      int chatId, int page, int pageSize) async {
    try {
      String? token = await AuthLocalStorage().getToken();
      if (token == null || token.isEmpty) return [];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/tcf/chat/history/$chatId?page=$page&pageSize=$pageSize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final List<dynamic> data =
            decodedData is List ? decodedData : (decodedData['data'] ?? []);
        return data
            .map((json) =>
                ChatMessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        try {
          final decodedData = jsonDecode(response.body);
          throw Exception(decodedData['errorMessage'] ?? 'حدث خطأ غير متوقع');
        } catch (_) {
          throw Exception("حدث خطأ غير متوقع");
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> initConnection({
    Function(ChatMessageModel)? onMessageReceived,
    Function(ChatMessageModel)? onMessageSent,
    Function(int messageId, String newStatus)? onMessageStatusUpdated,
    Function(Map<String, dynamic>)? onMessageRejected,
    Function(List<int> messageIds, String newStatus)? onMessagesDelivered,
    Function(int chatId, List<int> messageIds, String newStatus)?
        onMessagesRead,
    Function(String)? onUserOnline,
    Function(String)? onUserOffline,
    Function()? onFcmRefresh,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) {
      if (action == 'CHAT_MESSAGE' && onFcmRefresh != null) {
        onFcmRefresh();
      }
    });

    final hub = SignalRService.instance.chatHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.chatHub;
    if (activeHub == null) return;

    activeHub.off("ReceiveMessage");
    activeHub.off("MessageSent");
    activeHub.off("MessageStatusUpdated");
    activeHub.off("MessagesDelivered");
    activeHub.off("MessagesRead");
    activeHub.off("UserOnline");
    activeHub.off("UserOffline");
    activeHub.off("MessageRejected");

    activeHub.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          if (onMessageReceived != null) {
            onMessageReceived(ChatMessageModel.fromJson(
                arguments[0] as Map<String, dynamic>));
          }
        } catch (_) {}
      }
    });

    activeHub.on("MessageSent", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          if (onMessageSent != null) {
            onMessageSent(ChatMessageModel.fromJson(
                arguments[0] as Map<String, dynamic>));
          }
        } catch (_) {}
      }
    });

    activeHub.on("MessageStatusUpdated", (arguments) {
      if (arguments != null && arguments.length >= 2) {
        try {
          if (onMessageStatusUpdated != null) {
            onMessageStatusUpdated(arguments[0] as int, arguments[1] as String);
          }
        } catch (_) {}
      }
    });

    activeHub.on("MessagesDelivered", (arguments) {
      if (arguments != null && arguments.length >= 2) {
        try {
          if (onMessagesDelivered != null) {
            onMessagesDelivered(
                (arguments[0] as List<dynamic>).map((e) => e as int).toList(),
                arguments[1] as String);
          }
        } catch (_) {}
      }
    });

    activeHub.on("MessageRejected", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          if (onMessageRejected != null) {
            onMessageRejected(arguments[0] as Map<String, dynamic>);
          }
        } catch (_) {}
      }
    });

    activeHub.on("MessagesRead", (arguments) {
      if (arguments != null && arguments.length >= 3) {
        try {
          if (onMessagesRead != null) {
            onMessagesRead(
                arguments[0] as int,
                (arguments[1] as List<dynamic>).map((e) => e as int).toList(),
                arguments[2] as String);
          }
        } catch (_) {}
      }
    });

    activeHub.on("UserOnline", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        if (onUserOnline != null) onUserOnline(arguments[0].toString());
      }
    });

    activeHub.on("UserOffline", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        if (onUserOffline != null) onUserOffline(arguments[0].toString());
      }
    });
  }

  Future<void> sendMessage(int chatId, String content) async {
    final hub = SignalRService.instance.chatHub;
    if (hub == null) throw Exception("حدث خطأ في الاتصال");
    try {
      await hub.invoke("SendMessage", args: [
        {"chatId": chatId, "content": content, "messageType": "Text"}
      ]);
    } catch (e) {
      throw Exception("حدث خطأ في الاتصال");
    }
  }

  Future<void> markMessagesAsRead(int chatId) async {
    final hub = SignalRService.instance.chatHub;
    if (hub == null) return;
    try {
      await hub.invoke("MarkMessagesAsRead", args: [chatId]);
    } catch (_) {}
  }

  void disconnect() {
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
    final hub = SignalRService.instance.chatHub;
    if (hub == null) return;
    hub.off("ReceiveMessage");
    hub.off("MessageSent");
    hub.off("MessageStatusUpdated");
    hub.off("MessagesDelivered");
    hub.off("MessagesRead");
    hub.off("UserOnline");
    hub.off("UserOffline");
    hub.off("MessageRejected");
  }
}
