import 'dart:async';

import 'package:flutter/material.dart';

import '../services/admin/avisosadmin_services.dart';
import 'admin_notifications_dialog.dart';

class AdminNotificationBell extends StatefulWidget {
  const AdminNotificationBell({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<AdminNotificationBell> createState() => _AdminNotificationBellState();
}

class _AdminNotificationBellState extends State<AdminNotificationBell> {
  Timer? _timer;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadUnread());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnread() async {
    try {
      final notifications = await AvisosAdminService.obtenerNotificaciones();
      final unread = notifications.where((item) {
        final value = item['leida'];
        return value != true && value != 1 && value != '1' && value != 'true';
      }).length;
      if (mounted) setState(() => _unread = unread);
    } catch (_) {
      return;
    }
  }

  Future<void> _openNotifications() async {
    await showAdminNotificationsDialog(context);
    await _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      onPressed: widget.onPressed ?? _openNotifications,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.white),
          if (_unread > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
