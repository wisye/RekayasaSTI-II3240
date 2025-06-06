import 'package:flutter/material.dart';

class NotificationItem {
  final int id;
  final String shipmentCode;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String appName;
  final IconData icon;

  NotificationItem({
    required this.id,
    required this.shipmentCode,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.appName = "SIMILIKITI",
    this.icon = Icons.notifications_active_outlined,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    IconData displayIcon = Icons.info_outline;
    if (json['message'] != null) {
      String lcMessage = (json['message'] as String).toLowerCase();
      if (lcMessage.contains("diterima")) {
        displayIcon = Icons.check_circle_outline;
      } else if (lcMessage.contains("dikirim")) {
        displayIcon = Icons.local_shipping_outlined;
      } else if (lcMessage.contains("gagal")) {
        displayIcon = Icons.error_outline;
      }
    }

    return NotificationItem(
      id: json['id'] as int? ?? 0,
      shipmentCode: json['shipment_code'] as String? ?? 'N/A',
      message: json['message'] as String? ?? 'Tidak ada pesan.',
      isRead: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as DateTime?,
      icon: displayIcon,
    );
  }
}
