import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';
import 'package:el7erafe/features/chat_system/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final int chatId;

  List<ChatMessageModel> _messages = [];
  int currentPage = 1;
  final int _pageSize = 50;
  bool _isReceiverOnline = false;

  ChatCubit(this.repository, {required this.chatId}) : super(ChatInitial());

  Future<void> connectAndLoadHistory() async {
    emit(ChatLoading());
    try {
      final rawMessages =
          await repository.getChatHistory(chatId, currentPage, _pageSize);
      _messages = rawMessages.reversed.toList();

      if (!isClosed) {
        emit(ChatLoaded(
          List.from(_messages),
          hasReachedMax: _messages.length < _pageSize,
          isOnline: _isReceiverOnline,
        ));
      }

      await repository.initConnection(
        onFcmRefresh: reconnectAndRefresh,
        onMessageReceived: (newMessage) {
          if (newMessage.chatId != chatId) return;

          final exists = _messages.any((m) => m.id == newMessage.id);
          if (!exists) {
            _messages.insert(0, newMessage);
            if (!isClosed) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
            repository.markMessagesAsRead(chatId);
          }
        },
        onMessageSent: (savedMessage) {
          if (savedMessage.chatId != chatId) return;

          int index = _messages.indexWhere((m) =>
              m.senderId == "ME" &&
              m.content == savedMessage.content &&
              m.id > 1000000000);

          if (index != -1) {
            _messages[index] = savedMessage;
          } else {
            _messages.insert(0, savedMessage);
          }
          if (!isClosed) {
            emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
          }
        },
        onMessageRejected: (payload) {
          int index = _messages
              .indexWhere((m) => m.senderId == "ME" && m.id > 1000000000);
          if (index != -1) {
            _messages.removeAt(index);
          }
          if (!isClosed) {
            emit(ChatModerationRejected(List.from(_messages),
                isOnline: _isReceiverOnline));
            emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
          }
        },
        onMessageStatusUpdated: (messageId, newStatus) {
          bool hasChanges = false;
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].id == messageId) {
              _messages[i] = _messages[i].copyWith(messageStatus: newStatus);
              hasChanges = true;
              break;
            }
          }
          if (hasChanges && !isClosed) {
            emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
          }
        },
        onMessagesDelivered: (messageIds, newStatus) {
          bool hasChanges = false;
          for (int i = 0; i < _messages.length; i++) {
            if (messageIds.contains(_messages[i].id)) {
              _messages[i] = _messages[i].copyWith(messageStatus: newStatus);
              hasChanges = true;
            }
          }
          if (hasChanges && !isClosed) {
            emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
          }
        },
        onMessagesRead: (incomingChatId, messageIds, newStatus) {
          if (incomingChatId != chatId) return;

          bool hasChanges = false;
          for (int i = 0; i < _messages.length; i++) {
            if (messageIds.contains(_messages[i].id)) {
              _messages[i] = _messages[i].copyWith(messageStatus: newStatus);
              hasChanges = true;
            }
          }
          if (hasChanges && !isClosed) {
            emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
          }
        },
        onUserOnline: (userId) {
          if (_messages
              .any((m) => m.senderId == userId && m.senderId != "ME")) {
            _isReceiverOnline = true;
            if (!isClosed && state is ChatLoaded) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
          }
        },
        onUserOffline: (userId) {
          if (_messages
              .any((m) => m.senderId == userId && m.senderId != "ME")) {
            _isReceiverOnline = false;
            if (!isClosed && state is ChatLoaded) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
          }
        },
      );

      await repository.markMessagesAsRead(chatId);
    } catch (_) {
      if (!isClosed) emit(ChatError("حدث خطأ في الاتصال أو جلب الرسائل"));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final optimisticMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: chatId,
      senderId: "ME",
      receiverId: "",
      content: content,
      createdAt: DateTime.now(),
      messageStatus: 'Sent',
    );

    try {
      _messages.insert(0, optimisticMessage);
      emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
      await repository.sendMessage(chatId, content);
    } catch (_) {
      _messages.remove(optimisticMessage);
      if (!isClosed) {
        emit(ChatError("فشل في إرسال الرسالة"));
        emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
      }
    }
  }

  void disconnectSignalR() {
    repository.disconnect();
  }

  void reconnectAndRefresh() {
    connectAndLoadHistory();
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
