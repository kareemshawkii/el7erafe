import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';
import 'package:equatable/equatable.dart';

abstract class InboxState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<InboxConversationModel> conversations;

  InboxLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class InboxError extends InboxState {
  final String message;

  InboxError(this.message);

  @override
  List<Object?> get props => [message];
}

class InboxUnauthorized extends InboxState {
  final String message;

  InboxUnauthorized(this.message);

  @override
  List<Object?> get props => [message];
}