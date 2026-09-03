import 'package:flutter/material.dart';

import '../services/session_service.dart';

class AdminOnlyDrawerItem extends StatelessWidget {
  final Widget child;

  const AdminOnlyDrawerItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.canManageUsersAndChanges(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }

}

class AdminDrawerRole extends StatelessWidget {
  const AdminDrawerRole({super.key, this.color = const Color(0xFF94A3B8)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};
        final role = (user['role'] ?? user['rol'] ?? '').toString().trim();
        return Text(
          role.isNotEmpty ? role : 'Sin rol',
          style: TextStyle(color: color, fontSize: 11),
        );
      },
    );
  }
}
