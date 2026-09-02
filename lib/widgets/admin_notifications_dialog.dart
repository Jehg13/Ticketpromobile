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

  return read ? const Color(0xFF60A5FA) : const Color(0xFF60A5FA);
}

Future<void> showAdminNotificationsDialog(BuildContext context) async {
  try {
    final items = await AvisosAdminService.obtenerNotificaciones();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        final unreadCount = items.where((item) {
          final value = item['leida'];
          return value != true && value != 1 && value != '1' && value != 'true';
        }).length;

        return Dialog(
          backgroundColor: const Color(0xFF0D1427),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue.withValues(alpha: 0.18)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 650),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF60A5FA),
                        size: 27,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Notificaciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton.icon(
                          onPressed: () async {
                            final ok =
                                await AvisosAdminService.marcarTodasNotificacionesLeidas();
                            if (!context.mounted) return;
                            if (ok) {
                              Navigator.pop(dialogContext);
                              await showAdminNotificationsDialog(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No se pudieron actualizar las notificaciones.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF60A5FA),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                          icon: const Icon(Icons.done_all_rounded, size: 18),
                          label: const Text(
                            'Marcar leídas',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'Cuando recibas una notificación aparecerá aquí.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (itemContext, index) {
                            final item = items[index];
                            final leida =
                                item['leida'] == true ||
                                item['leida'] == 1 ||
                                item['leida'] == '1' ||
                                item['leida'] == 'true';
                            final id = int.tryParse(
                              item['id']?.toString() ?? '',
                            );

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: leida
                                    ? const Color(0xFF182442)
                                    : const Color(0xFF1C2D4D),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: leida
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.blue.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    _notificationIcon(item),
                                    color: _notificationColor(item, leida),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['titulo']?.toString() ??
                                              'Notificación',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (!leida)
                                        const Icon(
                                          Icons.circle,
                                          color: Color(0xFF60A5FA),
                                          size: 8,
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    item['mensaje']?.toString() ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  onTap: id == null
                                      ? null
                                      : () async {
                                          await AvisosAdminService.marcarNotificacionComoLeida(
                                            id,
                                          );
                                          if (context.mounted) {
                                            Navigator.pop(dialogContext);
                                            await showAdminNotificationsDialog(
                                              context,
                                            );
                                          }
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }
}
