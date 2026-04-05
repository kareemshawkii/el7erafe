import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_payload.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class NotificationRouter {
  static void processAndRoute(RemoteMessage message) {
    if (message.data.isEmpty) return;
    final payload = NotificationPayload.fromJson(message.data);
    final context = globalNavigatorKey.currentContext;
    
    if (context == null) {
      debugPrint("Navigator context is null. Cannot route.");
      return;
    }

    debugPrint("Routing Notification Action: ${payload.action}");

    switch (payload.action) {
      case 'CHAT_MESSAGE':
        final int? chatId = int.tryParse(payload.extraPayload['chatId'].toString());
        final String? receiverId = payload.extraPayload['receiverId']?.toString();
        final String? receiverName = payload.extraPayload['receiverName']?.toString();
        final String? receiverImage = payload.extraPayload['receiverImage']?.toString();

        if (chatId != null && receiverId != null && receiverName != null && receiverImage != null) {
          debugPrint("Navigating to Chat Room: $chatId with $receiverName");
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomPage(
          //   chatId: chatId, 
          //   receiverId: receiverId, 
          //   receiverName: receiverName, 
          //   receiverImage: receiverImage,
          // )));
        } else {
          debugPrint("Chat payload missing data!");
        }
        break;

      case 'PROMOTION':
        debugPrint("Promotion received. Navigating to Home Page.");
        // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;


      // ==========================================
      // 🔵 CLIENT SPECIFIC ACTIONS
      // ==========================================
      
      case 'CLIENT_NEW_OFFER':
        debugPrint("New offer received. Navigating to Pending Reservations Page.");
        // Navigator.pushNamed(context, '/client_pending_reservations');
        break;

      case 'CLIENT_CANCELLED': // Tech cancelled or rejected
        debugPrint("Reservation cancelled by tech. Navigating to Previous Reservations Page.");
        // Navigator.pushNamed(context, '/client_previous_reservations');
        break;

      case 'CLIENT_STATUS_CHANGED':
        debugPrint("Status changed. Navigating to Current Reservations Page.");
        // Navigator.pushNamed(context, '/client_current_reservations');
        break;


      // ==========================================
      // 🟠 TECHNICIAN SPECIFIC ACTIONS
      // ==========================================
      
      case 'TECH_APPROVED':
        debugPrint("Tech approved by admin. Opening app normally.");
        // App is open, no specific navigation needed unless you want to refresh the state.
        break;

      case 'TECH_NEW_REQUEST':
        debugPrint("New request received. Navigating to Tech Home Page.");
        // Navigator.pushNamedAndRemoveUntil(context, '/tech_home', (route) => false);
        break;

      case 'TECH_OFFER_ACCEPTED':
        debugPrint("Offer accepted by client. Navigating to Schedule Page.");
        // Navigator.pushNamed(context, '/tech_schedule');
        break;

      case 'TECH_OFFER_DECLINED':
        debugPrint("Offer declined by client. Opening app normally.");
        // Do nothing, just let them see the app where they left off.
        break;

      case 'TECH_REMINDER': // 15 mins remaining
        debugPrint("Reminder: 15 mins remaining. Navigating to Schedule/Current Reservation.");
        // You could use payload.entityId here to open the specific reservation
        // Navigator.pushNamed(context, '/tech_schedule');
        break;

      case 'TECH_PAYMENT_DONE':
        debugPrint("Payment done. Opening app (or navigating to wallet).");
        // Optionally navigate to Wallet or Earnings page
        break;

      case 'TECH_CANCELLED': // Client cancelled
        debugPrint("Reservation cancelled by client. Navigating to Previous Reservations/Schedule.");
        // Navigator.pushNamed(context, '/tech_previous_reservations');
        break;

      // ==========================================
      // ⚪ FALLBACK
      // ==========================================
      default:
        debugPrint("Unknown Action: ${payload.action}. Opening app normally.");
        break;
    }
  }
}