import 'package:intl/intl.dart';

class InboxConversationModel {
  final int chatId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String lastMessageContent;
  final DateTime lastMessageTime;
  final bool isLastMessageFromMe;
  final int unreadCount;
  final String messageStatus;

  InboxConversationModel({
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.lastMessageContent,
    required this.lastMessageTime,
    required this.isLastMessageFromMe,
    required this.unreadCount,
     required this.messageStatus,
  });

  factory InboxConversationModel.fromJson(Map<String, dynamic> json) {
    return InboxConversationModel(
      chatId: json['chatId'] ?? 0,
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? 'مستخدم',
      receiverImage: json['receiverImage'] ?? '',
      lastMessageContent: json['lastMessageContent'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      isLastMessageFromMe: json['isLastMessageFromMe'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      messageStatus: json['messageStatus'] ?? '',
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final isToday = lastMessageTime.year == now.year &&
        lastMessageTime.month == now.month &&
        lastMessageTime.day == now.day;
    if (isToday) {
      String timeStr = DateFormat('hh:mm').format(lastMessageTime);
      String amPm = lastMessageTime.hour < 12 ? 'صباحاً' : 'مساءً';
      return '$timeStr $amPm';
    } else {
      return DateFormat('dd/MM/yyyy').format(lastMessageTime);
    }
  }
}