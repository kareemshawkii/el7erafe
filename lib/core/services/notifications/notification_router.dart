import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/chat_system/presentation/pages/chat_room_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/presentation/reservation_history_page.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/pages/tech_reservation_history_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_payload.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class NotificationRouter {
  static void processAndRoute(RemoteMessage message) {
    if (message.data.isEmpty) return;
    final payload = NotificationPayload.fromJson(message.data);
    final context = globalNavigatorKey.currentContext;
    if (context == null) {
      return;
    }
    switch (payload.action) {
      case 'CHAT_MESSAGE':
        final int? chatId =
            int.tryParse(payload.extraPayload['chatId'].toString());
        final String? receiverId =
            payload.extraPayload['receiverId']?.toString();
        final String? receiverName =
            payload.extraPayload['receiverName']?.toString();
        final String? receiverImage =
            payload.extraPayload['receiverImage']?.toString();

        if (chatId != null &&
            receiverId != null &&
            receiverName != null &&
            receiverImage != null) {
          Navigator.push(
            context,
            SlideRightRouteWithBuild(
              builder: (context) => ChatRoomPage(
                chatId: chatId,
                receiverId: receiverId,
                receiverName: receiverName,
                receiverImage: receiverImage,
              ),
            ),
          );
        }
        break;

      case 'CLIENT_NEW_OFFER':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => ReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'CLIENT_CANCELLED':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => ReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'CLIENT_STATUS_CHANGED':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => ReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'TECH_OFFER_ACCEPTED':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => TechReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'TECH_OFFER_DECLINED':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => TechReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'TECH_REMINDER': // 15 mins remaining
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => TechReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'TECH_PAYMENT_DONE':
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => TechReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      case 'TECH_CANCELLED': // Client cancelled
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => TechReservationHistoryPage(),
          ),
          (route) => false,
        );
        break;

      default:
        break;
    }
  }
}
