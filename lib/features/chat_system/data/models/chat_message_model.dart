import 'package:intl/intl.dart';

class ChatMessageModel {
  final int id;
  final int chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final String messageStatus;
  final String messageType;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.messageStatus,
    this.messageType = 'Text',
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      chatId: json['chatId'] ?? 0,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      messageStatus: json['messageStatus'] ?? 'Sent',
      messageType: json['messageType'] ?? 'Text',
    );
  }

  ChatMessageModel copyWith({
    int? id,
    int? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    String? messageStatus,
    String? messageType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      messageStatus: messageStatus ?? this.messageStatus,
      messageType: messageType ?? this.messageType,
    );
  }

  String get formattedTime {
    String timeStr = DateFormat('hh:mm').format(createdAt);
    String amPm = createdAt.hour < 12 ? 'صباحاً' : 'مساءً';
    return '$timeStr $amPm';
  }
}
