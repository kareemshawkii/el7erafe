import 'dart:convert';

class NotificationPayload {
  final String action;
  final String? entityId;
  final Map<String, dynamic> extraPayload;

  NotificationPayload({
    required this.action,
    this.entityId,
    required this.extraPayload,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final String action = json['action'] ?? 'UNKNOWN';
    final String? entityId = json['entityId'];
    Map<String, dynamic> parsedExtra = {};
    if (json['extraPayload'] != null && json['extraPayload'].toString().isNotEmpty) {
      try {
        parsedExtra = jsonDecode(json['extraPayload']);
      } catch (e) {
        // If the backend sent invalid JSON, we catch it here so the app doesn't crash
      }
    }

    return NotificationPayload(
      action: action,
      entityId: entityId,
      extraPayload: parsedExtra,
    );
  }
}