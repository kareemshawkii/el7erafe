import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';
import 'package:el7erafe/features/chat_system/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final int chatId;
  final String receiverId;

  List<ChatMessageModel> _messages = [];
  int currentPage = 1;
  final int _pageSize = 50;

  bool _isReceiverOnline = false;

  ChatCubit(this.repository, {required this.chatId, required this.receiverId})
      : super(ChatInitial());

  Future<void> connectAndLoadHistory() async {
    emit(ChatLoading());
    try {
      await repository.initConnection(
        onMessageReceived: (newMessage) {
          final exists = _messages.any((m) => m.id == newMessage.id);
          if (!exists) {
            _messages.insert(0, newMessage);
            if (!isClosed) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
            if (newMessage.senderId == receiverId) {
              repository.markMessagesAsRead(chatId, receiverId);
            }
          }
        },
        onMessageStatusUpdated: (messageId, newStatus) {
          bool hasChanges = false;
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].senderId != receiverId) {
              if (newStatus == 'Read' && _messages[i].messageStatus != 'Read') {
                _messages[i] = _messages[i].copyWith(messageStatus: 'Read');
                hasChanges = true;
              } else if (newStatus == 'Delivered' &&
                  _messages[i].messageStatus == 'Sent') {
                _messages[i] = _messages[i]
                    .copyWith(messageStatus: 'Delivered', id: messageId);
                hasChanges = true;
              } else if (_messages[i].id == messageId) {
                _messages[i] = _messages[i].copyWith(messageStatus: newStatus);
                hasChanges = true;
              }
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
          if (userId == receiverId) {
            _isReceiverOnline = true;
            if (!isClosed && state is ChatLoaded) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
          }
        },
        onUserOffline: (userId) {
          if (userId == receiverId) {
            _isReceiverOnline = false;
            if (!isClosed && state is ChatLoaded) {
              emit(ChatLoaded(List.from(_messages),
                  isOnline: _isReceiverOnline));
            }
          }
        },
      );

      _messages =
          await repository.getChatHistory(chatId, currentPage, _pageSize);

      if (!isClosed) {
        emit(ChatLoaded(
          List.from(_messages),
          hasReachedMax: _messages.length < _pageSize,
          isOnline: _isReceiverOnline,
        ));
      }

      await repository.markMessagesAsRead(chatId, receiverId);
    } catch (e) {
      if (!isClosed) emit(ChatError("حدث خطأ في الاتصال"));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final optimisticMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: chatId,
      senderId: "ME",
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
      messageStatus: 'Sent',
    );

    try {
      _messages.insert(0, optimisticMessage);
      emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
      await repository.sendMessage(receiverId, content);
    } catch (e) {
      _messages.remove(optimisticMessage);
      if (!isClosed) {
        emit(ChatLoaded(List.from(_messages), isOnline: _isReceiverOnline));
        emit(ChatError("فشل في إرسال الرسالة"));
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
