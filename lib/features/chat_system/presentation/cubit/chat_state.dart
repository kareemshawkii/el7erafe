import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool hasReachedMax;

  ChatLoaded(this.messages, {this.hasReachedMax = false});
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
