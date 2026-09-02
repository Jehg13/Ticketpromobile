import 'package:flutter/material.dart';

import '../services/admin/avisosadmin_services.dart';

IconData _notificationIcon(Map<String, dynamic> item) {
  final type = (item['tipo'] ?? item['type'] ?? '').toString().toLowerCase();

  if (type.contains('aviso') ||
      type.contains('warning') ||
      type.contains('advertencia')) {
    return Icons.warning_amber_rounded;
  }
  if (type.contains('error') || type.contains('cancel')) {
    return Icons.error_outline;
  }
  if (type.contains('success') || type.contains('solucion')) {
    return Icons.check_circle_outline;
  }
  if (type.contains('coment')) {
    return Icons.comment_outlined;
  }
  if (type.contains('ticket')) {
    return Icons.confirmation_number_outlined;
  }

  return Icons.notifications_none_rounded;
}

Color _notificationColor(Map<String, dynamic> item, bool read) {
  if (read) return Colors.white54;

  final type = (item['tipo'] ?? item['type'] ?? '').toString().toLowerCase();

  if (type.contains('aviso') ||
      type.contains('warning') ||
      type.contains('advertencia')) {
    return Colors.amber;
  }
  if (type.contains('error') || type.contains('cancel')) {
    return Colors.redAccent;
  }
  if (type.contains('success') || type.contains('solucion')) {
    return Colors.green;
  }

  return Colors.blueAccent;
}

Future<void> showAdminNotificationsDialog(BuildContext context) async {
  try {
    final items = await AvisosAdminService.obtenerNotificaciones();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0D1427),
        title: Row(
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF60A5FA),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Notificaciones',
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          height: 420,
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'Cuando recibas una notificación aparecerá aquí.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final leida =
                        item['leida'] == true ||
                        item['leida'] == 1 ||
                        item['leida'] == '1' ||
                        item['leida'] == 'true';
                    final id = int.tryParse(item['id']?.toString() ?? '');

                    return ListTile(
                      leading: Icon(
                        _notificationIcon(item),
                        color: _notificationColor(item, leida),
                      ),
                      title: Text(
                        item['titulo']?.toString() ?? 'Notificación',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        item['mensaje']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: id == null
                          ? null
                          : () async {
                              await AvisosAdminService.marcarNotificacionComoLeida(
                                id,
                              );
                              if (context.mounted) {
                                Navigator.pop(dialogContext);
                                await showAdminNotificationsDialog(context);
                              }
                            },
                    );
                  },
                ),
        ),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }
}
