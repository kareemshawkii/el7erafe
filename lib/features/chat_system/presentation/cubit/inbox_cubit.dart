import 'package:el7erafe/features/chat_system/data/repositories/inbox_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inbox_state.dart';
import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';

class InboxCubit extends Cubit<InboxState> {
  final InboxRepository repository;
  List<InboxConversationModel> _allConversations = [];

  InboxCubit(this.repository) : super(InboxInitial());

  Future<void> fetchInbox() async {
    emit(InboxLoading());

    try {
      await repository.initSignalR(
        onInboxUpdated: (updatedInbox) {
          _allConversations = updatedInbox;
          if (!isClosed) {
            emit(InboxLoaded(List.from(_allConversations)));
          }
        },
      );

      final result = await repository.getInbox();

      result.fold(
        (conversations) {
          _allConversations = conversations;
          if (!isClosed) {
            emit(InboxLoaded(List.from(_allConversations)));
          }
        },
        (error) {
          if (error == "401 unauthorized") {
            if (!isClosed) {
              emit(InboxUnauthorized(
                  "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً"));
            }
          } else {
            if (!isClosed) {
              emit(InboxError(error));
            }
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(InboxError(e.toString().replaceAll("Exception: ", "")));
      }
    }
  }

  void searchConversations(String query) {
    if (state is InboxLoaded || _allConversations.isNotEmpty) {
      if (query.isEmpty) {
        emit(InboxLoaded(List.from(_allConversations)));
      } else {
        final filteredList = _allConversations.where((chat) {
          return chat.receiverName.toLowerCase().contains(query.toLowerCase());
        }).toList();
        emit(InboxLoaded(filteredList));
      }
    }
  }

  void disconnectSignalR() {
    repository.disconnect();
  }

  void reconnectAndRefresh() {
    fetchInbox();
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
