import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reksti_app/model/Notification.dart';
import 'package:reksti_app/services/logic_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 1,
      shipmentCode: "SHIP-63A0F3D9",
      message:
          "Pesanan Anda SHIP-63A0F3D9 telah berhasil dikonfirmasi dan sedang disiapkan.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      appName: "SIMILIKITI",
      icon: Icons.check_circle_outline_rounded,
    ),
    NotificationItem(
      id: 2,
      shipmentCode: "SHIP-640A0F4D9",
      message: "Pesanan Anda SHIP-640A0F4D9 sedang dalam perjalanan.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      appName: "SIMILIKITI",
      icon: Icons.check_circle_outline_rounded,
    ),
  ];
  bool _isLoading = true;
  String _errorMessage = '';
  final LogicService logicService = LogicService();

  @override
  void initState() {
    super.initState();
    _handleLoadNotifications();
  }

  Future<void> _handleLoadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<dynamic> rawNotification =
          await logicService.getNotification();
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Gagal memuat notifikasi: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime? dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (dateTime != null) {
      final dateToFormat = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      if (dateToFormat == today) {
        return 'Hari ini, ${DateFormat('HH:mm').format(dateTime)}';
      } else if (dateToFormat == yesterday) {
        return 'Kemarin, ${DateFormat('HH:mm').format(dateTime)}';
      } else if (now.difference(dateToFormat).inDays < 7) {
        return DateFormat('EEEE, HH:mm', 'id_ID').format(dateTime);
      } else {
        return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
      }
    }
    return "Tidak ada tanggal";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final Color pageBackgroundColor = Color(0xFFFAF4F5);

    final Color iconColor = Color(0xFFAD8BF2);

    return Stack(
      children: [
        Container(color: pageBackgroundColor),
        Positioned(
          top: 0,
          left: 0,
          child: Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/images/home_img1.png',
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.4,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body:
              _notifications.isEmpty
                  ? Center(
                    child: Text(
                      'Tidak ada notifikasi saat ini.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _notifications[index],
                        iconColor,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem item, Color iconColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shadowColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.appName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D2C5E),
                        ),
                      ),
                      Text(
                        _formatTimestamp(item.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.shipmentCode,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D2C5E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
