import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class InboxRepository {
  final String baseUrl = "https://el7rafeapp.azurewebsites.net";
  StreamSubscription? _fcmSubscription;

  Future<Either<List<InboxConversationModel>, String>> getInbox() async {
    AuthLocalStorage authLocalStorage = AuthLocalStorage();
    String? token = await authLocalStorage.getToken();
    String endpoint = '/api/tcf/chat/inbox';

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
        try {
          final decoded = json.decode(response.body);
          return Right(decoded['errorMessage'] ?? "حدث خطأ غير متوقع");
        } catch (_) {
          return const Right("حدث خطأ غير متوقع");
        }
      }
    } catch (e) {
      return const Right("حدث خطأ غير متوقع");
    }
  }

  Future<void> initSignalR({
    Function(List<InboxConversationModel>)? onInboxUpdated,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) {
      if (action == 'CHAT_MESSAGE') {
        _fallbackToApi(onInboxUpdated);
      }
    });

    final hub = SignalRService.instance.chatHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.chatHub;
    if (activeHub == null) return;

    activeHub.off("InboxUpdated");

    activeHub.on("InboxUpdated", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final List<dynamic> data = arguments[0] as List<dynamic>;
          final updatedInbox = data
              .map((json) =>
                  InboxConversationModel.fromJson(json as Map<String, dynamic>))
              .toList();
          if (onInboxUpdated != null) {
            onInboxUpdated(updatedInbox);
          }
        } catch (_) {}
      }
    });

    activeHub.onclose(({error}) {
      _fallbackToApi(onInboxUpdated);
    });

    activeHub.onreconnected(({connectionId}) {
      _fallbackToApi(onInboxUpdated);
    });
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
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
    final hub = SignalRService.instance.chatHub;
    if (hub == null) return;
    hub.off("InboxUpdated");
  }
}
