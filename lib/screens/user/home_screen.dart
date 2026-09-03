import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/loading_screen.dart';
import 'avisos_screen.dart';
import 'creartickets_screen.dart';
import 'detalles_screen.dart';
import 'mistickets_screen.dart';
import 'perfil_screen.dart';

IconData userNotificationIcon(Map<String, dynamic> item) {
  final type = (item['tipo'] ?? item['type'] ?? item['titulo'] ?? item['title'] ?? '')
      .toString()
      .toLowerCase();
  if (type.contains('aviso') || type.contains('warning') || type.contains('advertencia')) {
    return Icons.warning_amber_rounded;
  }
  if (type.contains('error') || type.contains('cancel')) return Icons.error_outline;
  if (type.contains('success') || type.contains('solucion')) return Icons.check_circle_outline;
  if (type.contains('coment')) return Icons.comment_outlined;
  if (type.contains('ticket')) return Icons.confirmation_number_outlined;
  return Icons.notifications_none_rounded;
}

Color userNotificationColor(Map<String, dynamic> item) {
  final type = (item['tipo'] ?? item['type'] ?? item['titulo'] ?? item['title'] ?? '')
      .toString()
      .toLowerCase();
  if (type.contains('aviso') || type.contains('warning') || type.contains('advertencia')) return Colors.amber;
  if (type.contains('error') || type.contains('cancel')) return Colors.redAccent;
  if (type.contains('success') || type.contains('solucion')) return Colors.green;
  return Colors.blueAccent;
}

Future<void> showUserMessage(BuildContext context, String message, {bool isError = false}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0D1427),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: isError ? Colors.redAccent : Colors.greenAccent,
        size: 42,
      ),
      title: Text(isError ? 'Ocurrió un problema' : '¡Listo!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

Future<void> showUserNotifications(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<List<Map<String, dynamic>>> notificationsFuture =
              TicketService.obtenerNotificaciones();

          return Dialog(
            backgroundColor: const Color(0xFF0D1427),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.withValues(alpha: 0.18)),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: notificationsFuture,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                final unreadCount = items.where((item) {
                  final leida = item['leida'];
                  return leida != true && leida != 1 && leida != '1' && leida != 'true';
                }).length;

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560, maxHeight: 650),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Color(0xFF60A5FA), size: 27),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Notificaciones',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (unreadCount > 0)
                              TextButton.icon(
                                onPressed: () async {
                                  final ok = await TicketService.marcarTodasNotificacionesLeidas();
                                  if (!dialogContext.mounted) return;
                                  if (ok) {
                                    setState(() {
                                      notificationsFuture = TicketService.obtenerNotificaciones();
                                    });
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notificaciones marcadas como leídas.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(
                                        content: Text('No se pudieron actualizar las notificaciones.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF60A5FA),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.done_all_rounded, size: 18),
                                label: const Text('Marcar leídas', style: TextStyle(fontSize: 11)),
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      Expanded(
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const LoadingScreen(mensaje: 'Cargando tu información...')
                            : items.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Cuando recibas una notificación aparecerá aquí.',
                                      style: TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: items.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                                    itemBuilder: (_, index) {
                                      final item = items[index];
                                      final String urlDestino = ApiService.resolveNotificationUrl(item['url']);
                                      final bool leida = item['leida'] == true ||
                                          item['leida'] == 1 ||
                                          item['leida'] == '1' ||
                                          item['leida'] == 'true';
                                      final int? itemId = int.tryParse(item['id']?.toString() ?? '');

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: leida ? const Color(0xFF182442) : const Color(0xFF1C2D4D),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: leida ? Colors.white.withValues(alpha: 0.06) : Colors.blue.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              userNotificationIcon(item),
                                              color: userNotificationColor(item),
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item['titulo']?.toString() ??
                                                        item['title']?.toString() ??
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
                                              item['mensaje']?.toString() ?? item['message']?.toString() ?? '',
                                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                                            ),
                                            onTap: () async {
                                              if (itemId != null) {
                                                await TicketService.marcarNotificacionComoLeida(itemId);
                                                if (dialogContext.mounted) {
                                                  setState(() {
                                                    notificationsFuture = TicketService.obtenerNotificaciones();
                                                  });
                                                }
                                              }

                                              final parsedUrl = Uri.tryParse(urlDestino);
                                              if (parsedUrl == null || !parsedUrl.hasScheme || !parsedUrl.hasAuthority) {
                                                return;
                                              }

                                              if (dialogContext.mounted) {
                                                Navigator.of(dialogContext).pop();
                                              }

                                              final opened = await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
                                              if (!opened && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('No se pudo abrir la notificación.'),
                                                    backgroundColor: Colors.red,
                                                  ),
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
                );
              },
            ),
          );
        },
      );
    },
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? usuario;

  bool cargandoUsuario = true;
  bool cargandoTickets = true;

  String? errorTickets;

  int ticketsTotal = 0;
  int ticketsAbiertos = 0;
  int ticketsEnProceso = 0;
  int ticketsSolucionados = 0;
  int ticketsCancelados = 0;

  int notificacionesNoLeidas = 0;

  Map<String, dynamic>? ultimoTicket;

  List<Map<String, dynamic>> ticketsRecientes = [];
  List<Map<String, dynamic>> actividades = [];
  List<Map<String, dynamic>> avisos = [];
  List<Map<String, dynamic>> notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
    _cargarTickets();
  }

  Future<void> _cargarUsuario() async {
    try {
      final usuarioGuardado = await SessionService.getUser();

      if (!mounted) return;

      setState(() {
        usuario = usuarioGuardado;
        cargandoUsuario = false;
      });
    } catch (e) {


      if (!mounted) return;

      setState(() {
        usuario = null;
        cargandoUsuario = false;
      });
    }
  }

  Future<void> _cargarTickets() async {
    if (!mounted) return;

    setState(() {
      cargandoTickets = true;
      errorTickets = null;
    });

    try {
      final respuesta = await TicketService.obtenerTickets();

      if (respuesta.isEmpty) {
        throw Exception('El servidor devolvió una respuesta vacía.');
      }

      if (respuesta['success'] != true) {
        final mensaje = _textoSeguro(respuesta['message']);

        throw Exception(
          mensaje.isNotEmpty
              ? mensaje
              : 'El servidor no pudo obtener los tickets.',
        );
      }

      final resumenRaw = respuesta['resumen'];

      Map<String, dynamic> resumen = {};

      if (resumenRaw is Map) {
        resumen = Map<String, dynamic>.from(resumenRaw);
      }

      final recientes = _convertirListaMap(respuesta['tickets_recientes']);

      Map<String, dynamic>? ultimo;

      final ultimoRaw = respuesta['ultimo_ticket'];

      if (ultimoRaw is Map) {
        ultimo = Map<String, dynamic>.from(ultimoRaw);
      }

      final actividadesRecibidas = _obtenerListaRespuesta(respuesta, [
        'actividad',
        'actividades',
        'actividad_reciente',
        'actividades_recientes',
      ]);

      final avisosRecibidos = _obtenerListaRespuesta(respuesta, [
        'avisos',
        'avisos_importantes',
        'avisos_recientes',
      ]);

      final notificacionesRecibidas = _obtenerListaRespuesta(respuesta, [
        'notificaciones',
        'notifications',
        'notificaciones_recientes',
      ]);

      final noLeidas = _enteroSeguro(respuesta['notificaciones_no_leidas']);

      if (!mounted) return;

      setState(() {
        ticketsTotal = _enteroSeguro(resumen['total']);

        ticketsAbiertos = _enteroSeguro(resumen['abiertos']);

        ticketsEnProceso = _enteroSeguro(resumen['en_proceso']);

        ticketsSolucionados = _enteroSeguro(resumen['solucionados']);

        ticketsCancelados = _enteroSeguro(resumen['cancelados']);

        ticketsRecientes = recientes;
        ultimoTicket = ultimo;
        actividades = actividadesRecibidas;
        avisos = avisosRecibidos;
        notificaciones = notificacionesRecibidas;
        notificacionesNoLeidas = noLeidas;

        cargandoTickets = false;
        errorTickets = null;
      });
    } catch (e) {




      if (!mounted) return;

      setState(() {
        cargandoTickets = false;
        errorTickets = _limpiarError(e);

        ticketsTotal = 0;
        ticketsAbiertos = 0;
        ticketsEnProceso = 0;
        ticketsSolucionados = 0;
        ticketsCancelados = 0;

        ticketsRecientes = [];
        ultimoTicket = null;
        actividades = [];
        avisos = [];
        notificaciones = [];
        notificacionesNoLeidas = 0;
      });
    }
  }

  List<Map<String, dynamic>> _obtenerListaRespuesta(
    Map<String, dynamic> respuesta,
    List<String> claves,
  ) {
    for (final clave in claves) {
      final valor = respuesta[clave];

      if (valor is List) {
        return _convertirListaMap(valor);
      }
    }

    return [];
  }

  List<Map<String, dynamic>> _convertirListaMap(dynamic valor) {
    final resultado = <Map<String, dynamic>>[];

    if (valor is! List) {
      return resultado;
    }

    for (final item in valor) {
      if (item is Map) {
        resultado.add(Map<String, dynamic>.from(item));
      }
    }

    return resultado;
  }

  String _limpiarError(Object error) {
    final texto = error.toString();

    if (texto.startsWith('Exception: ')) {
      return texto.substring('Exception: '.length);
    }

    return texto;
  }

  int _enteroSeguro(dynamic valor) {
    if (valor == null) return 0;

    if (valor is int) return valor;

    if (valor is double) {
      return valor.toInt();
    }

    if (valor is num) {
      return valor.toInt();
    }

    if (valor is String) {
      return int.tryParse(valor.trim()) ?? 0;
    }

    return 0;
  }

  String _textoSeguro(dynamic valor) {
    if (valor == null) return '';

    if (valor is String) {
      return valor.trim();
    }

    if (valor is num || valor is bool) {
      return valor.toString();
    }

    if (valor is Map) {
      final posibles = [
        valor['nombre'],
        valor['name'],
        valor['value'],
        valor['descripcion'],
        valor['description'],
        valor['titulo'],
        valor['title'],
        valor['mensaje'],
        valor['message'],
        valor['texto'],
        valor['text'],
        valor['login'],
        valor['folio'],
      ];

      for (final item in posibles) {
        final texto = _textoSeguro(item);

        if (texto.isNotEmpty) {
          return texto;
        }
      }
    }

    return '';
  }

  String _datoUsuario(String campo, {String defecto = 'No disponible'}) {
    final datos = usuario;

    if (datos == null) {
      return defecto;
    }

    final texto = _textoSeguro(datos[campo]);

    return texto.isNotEmpty ? texto : defecto;
  }

  String _datoAlternativo(
    List<String> campos, {
    String defecto = 'No disponible',
  }) {
    final datos = usuario;

    if (datos == null) {
      return defecto;
    }

    for (final campo in campos) {
      final texto = _textoSeguro(datos[campo]);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return defecto;
  }

  String get nombreUsuario {
    final nombre = _datoUsuario('name', defecto: '');

    if (nombre.isNotEmpty) {
      return nombre;
    }

    return _datoUsuario('login', defecto: 'Usuario');
  }

  String get loginUsuario {
    return _datoUsuario('login', defecto: 'Usuario');
  }

  String get emailUsuario {
    return _datoUsuario('email');
  }

  String get rolUsuario {
    return _datoUsuario('role');
  }

  String get empresaUsuario {
    return _datoAlternativo(['empresa', 'empresa_nombre', 'nombre_empresa']);
  }

  String get departamentoUsuario {
    return _datoAlternativo([
      'departamento',
      'departamento_nombre',
      'nombre_departamento',
    ]);
  }

  String get oficinaUsuario {
    return _datoAlternativo(['oficina', 'oficina_nombre', 'nombre_oficina']);
  }

  String get empleadoUsuario {
    return _datoAlternativo(['numero_empleado', 'numeroEmpleado', 'empleado']);
  }

  void _abrirCrearTicket(BuildContext context) {
    navigateWithLoading(context, const CrearticketsScreen(), mensaje: 'Preparando crear ticket...');
  }

  void _abrirMisTickets(BuildContext context) {
    navigateWithLoading(context, const MisticketsScreen(), mensaje: 'Cargando tus tickets...');
  }

  void _abrirDetalleTicket(BuildContext context, Map<String, dynamic> ticket) {
    navigateWithLoading(
      context,
      DetallesScreen(ticket: ticket),
      mensaje: 'Cargando detalle del ticket...',
    );
  }

  void _abrirAvisos(BuildContext context) {
    navigateWithLoading(context, const AvisosScreen(), mensaje: 'Cargando avisos...');
  }

  void _abrirNotificaciones() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
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
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF60A5FA),
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notificaciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              notificaciones.isEmpty
                                  ? 'No tienes notificaciones'
                                  : '$notificacionesNoLeidas sin leer',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                  child: notificaciones.isEmpty
                      ? _buildNotificacionesVacias()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: notificaciones.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _buildNotificacionItem(
                              notificaciones[index],
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
  }

  Widget _buildNotificacionesVacias() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: Colors.white38,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay notificaciones',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cuando recibas una notificación aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacionItem(Map<String, dynamic> notificacion) {
    final titulo = _obtenerTituloNotificacion(notificacion);

    final mensaje = _obtenerMensajeNotificacion(notificacion);

    final fecha = _obtenerFechaNotificacion(notificacion);

    final tipo = _textoSeguro(notificacion['tipo']).toLowerCase();

    final leida = _esNotificacionLeida(notificacion);

    final color = _colorNotificacion(tipo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: leida ? const Color(0xFF141C33) : const Color(0xFF182442),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: leida
              ? Colors.white.withValues(alpha: 0.04)
              : color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(_iconoNotificacion(tipo), color: color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: leida ? FontWeight.w600 : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!leida)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: 6, top: 3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (mensaje.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    mensaje,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  fecha,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerTituloNotificacion(Map<String, dynamic> notificacion) {
    final posibles = [
      notificacion['titulo'],
      notificacion['title'],
      notificacion['nombre'],
      notificacion['asunto'],
      notificacion['subject'],
      notificacion['tipo_notificacion'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    final folio = _textoSeguro(notificacion['folio']);

    if (folio.isNotEmpty) {
      return 'Notificación del ticket $folio';
    }

    return 'Notificación';
  }

  String _obtenerMensajeNotificacion(Map<String, dynamic> notificacion) {
    final posibles = [
      notificacion['mensaje'],
      notificacion['message'],
      notificacion['descripcion'],
      notificacion['description'],
      notificacion['texto'],
      notificacion['text'],
      notificacion['contenido'],
      notificacion['body'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _obtenerFechaNotificacion(Map<String, dynamic> notificacion) {
    final posibles = [
      notificacion['fecha'],
      notificacion['created_at'],
      notificacion['updated_at'],
      notificacion['date'],
      notificacion['fecha_notificacion'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return _formatearFechaActividad(texto);
      }
    }

    return 'Fecha no disponible';
  }

  bool _esNotificacionLeida(Map<String, dynamic> notificacion) {
    final valor =
        notificacion['leida'] ??
        notificacion['leido'] ??
        notificacion['read'] ??
        notificacion['vista'] ??
        notificacion['is_read'];

    if (valor is bool) {
      return valor;
    }

    if (valor is int) {
      return valor == 1;
    }

    if (valor is String) {
      final texto = valor.toLowerCase().trim();

      return texto == '1' ||
          texto == 'true' ||
          texto == 'leida' ||
          texto == 'leído' ||
          texto == 'leido' ||
          texto == 'read';
    }

    return false;
  }

  Color _colorNotificacion(String tipo) {
    if (tipo.contains('aviso') ||
        tipo.contains('warning') ||
        tipo.contains('advertencia')) {
      return Colors.amber;
    }

    if (tipo.contains('error') || tipo.contains('cancel')) {
      return Colors.redAccent;
    }

    if (tipo.contains('success') || tipo.contains('solucion')) {
      return Colors.green;
    }

    return Colors.blueAccent;
  }

  IconData _iconoNotificacion(String tipo) {
    if (tipo.contains('aviso') ||
        tipo.contains('warning') ||
        tipo.contains('advertencia')) {
      return Icons.warning_amber_rounded;
    }

    if (tipo.contains('error') || tipo.contains('cancel')) {
      return Icons.error_outline;
    }

    if (tipo.contains('success') || tipo.contains('solucion')) {
      return Icons.check_circle_outline;
    }

    if (tipo.contains('coment')) {
      return Icons.comment_outlined;
    }

    if (tipo.contains('ticket')) {
      return Icons.confirmation_number_outlined;
    }

    return Icons.notifications_none_rounded;
  }

  void _abrirNotificacionDesdeHeader() {
    _abrirNotificaciones();
  }

  Widget _buildUserMenu({double radius = 17}) {
    return PopupMenuButton<String>(
      tooltip: 'Abrir menú de usuario',
      offset: const Offset(0, 46),
      padding: EdgeInsets.zero,
      color: const Color(0xFF0F172A),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      onSelected: (value) async {
        if (value == 'perfil') {
          await navigateWithLoading(
            context,
            const MiPerfilScreen(),
            mensaje: 'Cargando tu perfil...',
          );
        } else if (value == 'logout') {
          await SessionService.clearSession();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'perfil',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Mi perfil', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      child: UserAvatar(radius: radius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;

    if (cargandoUsuario || cargandoTickets) {
      return const LoadingScreen(mensaje: 'Cargando tu información...');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const AppLogo(fontSize: 20),
              actions: [
                _buildNotificationButton(compact: true),
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: _buildUserMenu(radius: 16),
                ),
              ],
            ),
      drawer: isDesktop ? null : const AppNavigationDrawer(),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(width: 260, child: AppNavigationDrawer()),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildDesktopHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarTickets,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, isDesktop),
                          const SizedBox(height: 20),
                          if (errorTickets != null) _buildErrorTickets(),
                          _buildLayout(context, isDesktop),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1021),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const AppLogo(fontSize: 23),
          const Spacer(),
          _buildNotificationButton(),
          const SizedBox(width: 8),
          _buildUserMenu(),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              nombreUsuario,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton({bool compact = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _abrirNotificacionDesdeHeader,
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: compact ? 22 : 23,
          ),
          tooltip: 'Notificaciones',
        ),
        if (notificacionesNoLeidas > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                notificacionesNoLeidas > 99 ? '99+' : '$notificacionesNoLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorTickets() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudieron cargar los datos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorTickets ?? 'Error desconocido',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _cargarTickets,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cargandoUsuario ? 'Cargando...' : 'Bienvenido, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Inicio / Dashboard',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _abrirCrearTicket(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Nuevo ticket',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cargandoUsuario
                        ? 'Cargando...'
                        : 'Bienvenido, $nombreUsuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Inicio / Dashboard',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _abrirCrearTicket(context);
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Nuevo ticket',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUserInfo()),
              const SizedBox(width: 16),
              Expanded(child: _buildTicketSummary()),
            ],
          )
        else
          Column(
            children: [
              _buildTicketSummary(),
              const SizedBox(height: 16),
              _buildUserInfo(),
            ],
          ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLastTicket(),
                    const SizedBox(height: 16),
                    _buildActivity(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildRecentTickets(true),
                    const SizedBox(height: 16),
                    _buildNotices(),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildLastTicket(),
              const SizedBox(height: 16),
              _buildRecentTickets(false),
              const SizedBox(height: 16),
              _buildActivity(),
              const SizedBox(height: 16),
              _buildNotices(),
            ],
          ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1427),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return _buildCard(
      title: 'Mi información',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const UserAvatar(radius: 42),
              ),
              const SizedBox(height: 16),
              Text(
                nombreUsuario,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.35)),
                ),
                child: Text(
                  rolUsuario,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF101A2F), Color(0xFF171F38)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person_outline, 'Nombre:', nombreUsuario),
                    _infoRow(Icons.account_circle_outlined, 'Usuario:', loginUsuario),
                    _infoRow(Icons.business_outlined, 'Empresa:', empresaUsuario),
                    _infoRow(Icons.apartment_outlined, 'Departamento:', departamentoUsuario),
                    _infoRow(Icons.email_outlined, 'Correo:', emailUsuario),
                    _infoRow(Icons.location_city_outlined, 'Oficina:', oficinaUsuario),
                    _infoRow(Icons.badge_outlined, 'Empleado:', empleadoUsuario),
                    _infoRow(Icons.work_outline, 'Rol:', rolUsuario),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final bool isEmail = label == 'Correo:';
    final bool isLongValue = value.length > 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: isLongValue && !isEmail ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: const Color(0xFF93C5FD)),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: isEmail ? 74 : 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              maxLines: isEmail ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSummary() {
    if (cargandoTickets) {
      return _buildCard(
        title: 'Resumen de mis tickets',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return _buildCard(
      title: 'Resumen de mis tickets',
      trailing: Text(
        'Total: $ticketsTotal',
        style: const TextStyle(
          color: Colors.purpleAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _metricBadge(ticketsAbiertos, 'Abiertos', Colors.yellow)),
          const SizedBox(width: 8),
          Expanded(child: _metricBadge(ticketsEnProceso, 'En proceso', Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _metricBadge(ticketsSolucionados, 'Solucionados', Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _metricBadge(ticketsCancelados, 'Cancelados', Colors.red)),
        ],
      ),
    );
  }

  Widget _metricBadge(int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLastTicket() {
    if (cargandoTickets) {
      return _buildCard(
        title: 'Último ticket',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (ultimoTicket == null) {
      return _buildCard(
        title: 'Último ticket',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No tienes tickets registrados.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      );
    }

    final ticket = ultimoTicket!;

    final folio = _textoSeguro(ticket['folio']);

    final tipo = _textoSeguro(ticket['tipo_falla']);

    final estado = _textoSeguro(ticket['estado']);

    final prioridad = _textoSeguro(ticket['prioridad']);

    final departamento = _textoSeguro(ticket['departamento']);

    final oficina = _textoSeguro(ticket['oficina']);

    final asignadoA = _obtenerUsuarioTicket(
      ticket['asignado_a'],
      ticket['asignado_a_usuario'],
    );

    final tomadoPor = _obtenerUsuarioTicket(
      ticket['tomado_por'],
      ticket['tomado_por_usuario'],
    );

    final fechaReporte = _formatearFecha(ticket['created_at']);

    final fechaAsignacion = _formatearFecha(ticket['fecha_asignacion']);

    final solucion = ticket['solucion'];

    final problemaSolucionado = solucion is Map
        ? solucion['problema_solucionado']
        : null;

    final seSoluciono =
        problemaSolucionado == true ||
        problemaSolucionado == 1 ||
        problemaSolucionado?.toString().toLowerCase() == 'true';

    final detailItems = [
      {'label': 'Tipo de falla', 'value': tipo.isNotEmpty ? tipo : 'N/A'},
      {'label': 'Prioridad', 'value': prioridad.isNotEmpty ? prioridad : 'N/A', 'color': _colorPrioridad(prioridad)},
      {'label': 'Departamento', 'value': departamento.isNotEmpty ? departamento : 'N/A'},
      {'label': 'Asignado a', 'value': asignadoA.isNotEmpty ? asignadoA : 'N/A'},
      {'label': 'Sucursal / Oficina', 'value': oficina.isNotEmpty ? oficina : 'N/A'},
      {'label': 'Tomado por', 'value': tomadoPor.isNotEmpty ? tomadoPor : 'N/A'},
      {'label': 'Fecha reporte', 'value': fechaReporte},
      {'label': 'Asignación', 'value': fechaAsignacion},
      {'label': '¿Se solucionó?', 'value': seSoluciono ? 'Sí' : 'No', 'color': seSoluciono ? Colors.green : Colors.red},
    ];

    return _buildCard(
      title: 'Último ticket',
      trailing: TextButton(
        onPressed: () => _abrirDetalleTicket(context, ticket),
        child: const Text('Ver detalles'),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101A2F), Color(0xFF171F38)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.30)),
                    ),
                    child: Text(
                      folio.isNotEmpty ? folio : 'Sin folio',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _colorEstado(estado).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _colorEstado(estado).withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    estado.isNotEmpty ? estado : 'N/A',
                    style: TextStyle(
                      color: _colorEstado(estado),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 8) / 2;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detailItems.map((item) {
                    final value = item['value']?.toString() ?? 'N/A';
                    final color = item['color'] as Color? ?? Colors.white;

                    return SizedBox(
                      width: itemWidth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(minHeight: 62),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121B2D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['label']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: color,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerUsuarioTicket(dynamic login, dynamic usuarioRelacionado) {
    if (usuarioRelacionado is Map) {
      final nombre = _textoSeguro(usuarioRelacionado['name']);

      if (nombre.isNotEmpty) {
        return nombre;
      }

      final loginRelacionado = _textoSeguro(usuarioRelacionado['login']);

      if (loginRelacionado.isNotEmpty) {
        return loginRelacionado;
      }
    }

    return _textoSeguro(login);
  }

  String _obtenerEquipoTicket(Map<String, dynamic> ticket) {
    final posibles = [
      ticket['equipo'],
      ticket['equipo_nombre'],
      ticket['nombre_equipo'],
      ticket['equipoName'],
      ticket['team'],
      ticket['team_name'],
      ticket['nombreEquipo'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);
      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) {
      return 'N/A';
    }

    final texto = _textoSeguro(fecha);

    if (texto.isEmpty) {
      return 'N/A';
    }

    final fechaParsed = DateTime.tryParse(texto);

    if (fechaParsed == null) {
      return texto;
    }

    final dia = fechaParsed.day.toString().padLeft(2, '0');

    final mes = _nombreMes(fechaParsed.month);

    final anio = fechaParsed.year.toString();

    return '$dia $mes $anio';
  }

  String _formatearFechaActividad(dynamic fecha) {
    if (fecha == null) {
      return 'Fecha no disponible';
    }

    final texto = _textoSeguro(fecha);

    if (texto.isEmpty) {
      return 'Fecha no disponible';
    }

    final fechaParsed = DateTime.tryParse(texto);

    if (fechaParsed == null) {
      return texto;
    }

    final dia = fechaParsed.day.toString().padLeft(2, '0');

    final mes = _nombreMes(fechaParsed.month);

    final anio = fechaParsed.year.toString();

    final hora = fechaParsed.hour.toString().padLeft(2, '0');

    final minuto = fechaParsed.minute.toString().padLeft(2, '0');

    return '$dia $mes $anio - $hora:$minuto';
  }

  String _nombreMes(int mes) {
    const meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    if (mes >= 1 && mes <= 12) {
      return meses[mes];
    }

    return '';
  }

  Widget _buildRecentTickets(bool isDesktop) {
    if (ticketsRecientes.isEmpty) {
      return _buildCard(
        title: 'Mis tickets recientes',
        trailing: TextButton(
          onPressed: () => _abrirMisTickets(context),
          child: const Text('Ver todos'),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No tienes tickets recientes.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      );
    }

    return _buildCard(
      title: 'Mis tickets recientes',
      trailing: TextButton.icon(
        onPressed: () => _abrirMisTickets(context),
        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
        label: const Text('Ver todos'),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF121B2D)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: isDesktop ? _buildTicketsDesktop() : _buildTicketsMobile(),
      ),
    );
  }

  Widget _buildTicketsDesktop() {
    final crossAxisCount = 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = (width - 12) / crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ticketsRecientes.map((ticket) {
            return SizedBox(
              width: itemWidth,
              child: _buildRecentTicketCard(ticket),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTicketsMobile() {
    return Column(
      children: ticketsRecientes.map((ticket) => _buildRecentTicketCard(ticket)).toList(),
    );
  }

  Widget _buildRecentTicketCard(Map<String, dynamic> ticket) {
    final folio = _textoSeguro(ticket['folio']);
    final titulo = _textoSeguro(ticket['titulo']);
    final tipo = _textoSeguro(ticket['tipo_falla']);
    final estado = _textoSeguro(ticket['estado']);
    final fecha = _formatearFecha(ticket['created_at']);
    final prioridad = _textoSeguro(ticket['prioridad']);
    final equipo = _obtenerEquipoTicket(ticket);
    final mostrarEquipo = _debeMostrarEquipo(ticket, tipo);

    final chips = <Widget>[];
    chips.add(_ticketInfoChip('Tipo', tipo.isNotEmpty ? tipo : 'N/A', Colors.blue));
    chips.add(
      _ticketInfoChip(
        'Prioridad',
        prioridad.isNotEmpty ? prioridad : 'N/A',
        _colorPrioridad(prioridad),
      ),
    );
    if (mostrarEquipo && equipo.isNotEmpty) {
      chips.add(_ticketInfoChip('Equipo', equipo, Colors.tealAccent));
    }
    chips.add(_ticketInfoChip('Fecha', fecha, Colors.purpleAccent));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _abrirDetalleTicket(context, ticket),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF101B2F), Color(0xFF111C32)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF93C5FD).withValues(alpha: 0.24),
                        ),
                      ),
                      child: Text(
                        folio.isNotEmpty ? folio : 'Sin folio',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFDBEAFE),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _colorEstado(estado).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _colorEstado(estado).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      estado.isNotEmpty ? estado : 'No disponible',
                      style: TextStyle(
                        color: _colorEstado(estado),
                        fontSize: 9.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                titulo.isNotEmpty ? titulo : 'Ticket sin título',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Text(
                        tipo.isNotEmpty ? tipo : 'Sin tipo',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _abrirDetalleTicket(context, ticket),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: const Color(0xFF1D4ED8).withValues(alpha: 0.18),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('Ver', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _debeMostrarEquipo(Map<String, dynamic> ticket, String tipo) {
    final tipoFormateado = tipo.toLowerCase();
    if (tipoFormateado.contains('equipo')) {
      return true;
    }

    final opciones = [
      ticket['tipo'],
      ticket['categoria'],
      ticket['tipo_ticket'],
      ticket['tipo_falla'],
    ];

    for (final valor in opciones) {
      final texto = _textoSeguro(valor).toLowerCase();
      if (texto.contains('equipo')) {
        return true;
      }
    }

    return false;
  }

  Widget _ticketInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 9.5,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'abierto':
      case 'abiertos':
        return Colors.yellow;

      case 'en proceso':
      case 'en_proceso':
        return Colors.blue;

      case 'solucionado':
      case 'solucionados':
        return Colors.green;

      case 'cancelado':
      case 'cancelados':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Color _colorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase().trim()) {
      case 'critica':
      case 'crítica':
        return Colors.red;

      case 'alta':
        return Colors.orange;

      case 'media':
        return Colors.yellow;

      case 'normal':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Widget _buildActivity() {
    return _buildCard(
      title: 'Actividad reciente',
      trailing: actividades.isNotEmpty
          ? Text(
              '${actividades.length}',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      child: actividades.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No hay actividad reciente.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            )
          : Column(
              children: List.generate(actividades.length, (index) {
                final actividad = actividades[index];

                final texto = _obtenerTextoActividad(actividad);

                final fecha = _obtenerFechaActividad(actividad);

                final color = _colorActividad(actividad);

                return _activityItem(
                  texto,
                  fecha,
                  color,
                  isLast: index == actividades.length - 1,
                );
              }),
            ),
    );
  }

  String _obtenerTextoActividad(Map<String, dynamic> actividad) {
    final posibles = [
      actividad['texto'],
      actividad['mensaje'],
      actividad['message'],
      actividad['descripcion'],
      actividad['description'],
      actividad['actividad'],
      actividad['titulo'],
      actividad['title'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    final folio = _textoSeguro(actividad['folio']);

    final accion = _textoSeguro(actividad['accion']);

    if (accion.isNotEmpty && folio.isNotEmpty) {
      return '$accion $folio';
    }

    if (accion.isNotEmpty) {
      return accion;
    }

    if (folio.isNotEmpty) {
      return 'Actividad relacionada con el ticket $folio';
    }

    return 'Actividad reciente';
  }

  String _obtenerFechaActividad(Map<String, dynamic> actividad) {
    final posibles = [
      actividad['fecha'],
      actividad['fecha_actividad'],
      actividad['created_at'],
      actividad['updated_at'],
      actividad['date'],
      actividad['createdAt'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return _formatearFechaActividad(valor);
      }
    }

    return 'Fecha no disponible';
  }

  Color _colorActividad(Map<String, dynamic> actividad) {
    final tipo = _textoSeguro(actividad['tipo']).toLowerCase();

    final accion = _textoSeguro(actividad['accion']).toLowerCase();

    final texto = _obtenerTextoActividad(actividad).toLowerCase();

    final contenido = '$tipo $accion $texto';

    if (contenido.contains('tom') || contenido.contains('asign')) {
      return Colors.green;
    }

    if (contenido.contains('coment')) {
      return Colors.blue;
    }

    if (contenido.contains('solucion')) {
      return Colors.green;
    }

    if (contenido.contains('cancel')) {
      return Colors.red;
    }

    if (contenido.contains('cre')) {
      return Colors.blue;
    }

    return Colors.blueAccent;
  }

  Widget _activityItem(
    String text,
    String time,
    Color color, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 3,
              top: 12,
              bottom: -6,
              child: Container(width: 1, color: Colors.white10),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(Icons.circle, size: 8, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotices() {
    return _buildCard(
      title: 'Avisos importantes',
      trailing: TextButton(
        onPressed: () {
          _abrirAvisos(context);
        },
        child: const Text('Ver todos'),
      ),
      child: avisos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No hay avisos disponibles.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            )
          : Column(
              children: avisos.take(3).map((aviso) {
                final titulo = _obtenerTituloAviso(aviso);

                final fecha = _obtenerFechaAviso(aviso);

                final descripcion = _obtenerDescripcionAviso(aviso);

                final tipo = _textoSeguro(aviso['tipo']).toLowerCase();

                final color = _colorAviso(tipo);

                return _noticeItem(
                  titulo,
                  fecha,
                  descripcion,
                  _iconoAviso(tipo),
                  color,
                );
              }).toList(),
            ),
    );
  }

  String _obtenerTituloAviso(Map<String, dynamic> aviso) {
    final posibles = [
      aviso['titulo'],
      aviso['title'],
      aviso['nombre'],
      aviso['name'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return 'Aviso';
  }

  String _obtenerDescripcionAviso(Map<String, dynamic> aviso) {
    final posibles = [
      aviso['descripcion'],
      aviso['description'],
      aviso['texto'],
      aviso['mensaje'],
      aviso['message'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _obtenerFechaAviso(Map<String, dynamic> aviso) {
    final posibles = [
      aviso['fecha'],
      aviso['created_at'],
      aviso['updated_at'],
      aviso['date'],
    ];

    for (final valor in posibles) {
      final texto = _textoSeguro(valor);

      if (texto.isNotEmpty) {
        final parsed = DateTime.tryParse(texto);

        if (parsed != null) {
          final dia = parsed.day.toString().padLeft(2, '0');

          final mes = _nombreMes(parsed.month);

          final anio = parsed.year.toString();

          return '$dia $mes $anio';
        }

        return texto;
      }
    }

    return 'Fecha no disponible';
  }

  Color _colorAviso(String tipo) {
    switch (tipo) {
      case 'warning':
      case 'mantenimiento':
      case 'incidente':
        return Colors.amber;

      case 'info':
      case 'informativo':
        return Colors.blue;

      case 'success':
      case 'general':
        return Colors.green;

      default:
        return Colors.blueAccent;
    }
  }

  IconData _iconoAviso(String tipo) {
    switch (tipo) {
      case 'warning':
      case 'mantenimiento':
        return Icons.warning_amber_rounded;

      case 'incidente':
        return Icons.error_outline;

      case 'info':
      case 'informativo':
        return Icons.info_outline;

      case 'success':
        return Icons.check_circle_outline;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  Widget _noticeItem(
    String title,
    String date,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111B2E), Color(0xFF131D31)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.26)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final double radius;

  const UserAvatar({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final picture = snapshot.data?['picture']?.toString();
        final imageUrl = picture == null || picture.trim().isEmpty
            ? ''
            : ApiService.profileImageUrl(picture);
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF2563EB),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? Image.asset(
                    'assets/images/user.png',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    '$imageUrl?profile_refresh=${picture.hashCode}',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/images/user.png',
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class UserHeaderActions extends StatelessWidget {
  final VoidCallback onNotifications;
  final int unreadCount;

  const UserHeaderActions({
    super.key,
    required this.onNotifications,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotifications,
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              tooltip: 'Notificaciones',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        PopupMenuButton<String>(
          tooltip: 'Abrir menú de usuario',
          offset: const Offset(0, 50),
          padding: EdgeInsets.zero,
          color: const Color(0xFF0F172A),
          elevation: 14,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.blue.withValues(alpha: 0.22)),
          ),
          onSelected: (value) async {
            if (value == 'perfil') {
              await navigateWithLoading(
                context,
                const MiPerfilScreen(),
                mensaje: 'Cargando tu perfil...',
              );
            } else {
              await SessionService.clearSession();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'perfil',
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: Color(0xFF93C5FD)),
                  SizedBox(width: 10),
                  Text('Mi perfil', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFFCA5A5)),
                  SizedBox(width: 10),
                  Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: UserAvatar(radius: 16),
          ),
        ),
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        children: const [
          TextSpan(
            text: 'Ticket',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Pro',
            style: TextStyle(color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0B1021),
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(fontSize: 26),

            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  child: const UserAvatar(radius: 20),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: SessionService.getUser(),
                    builder: (context, snapshot) {
                      final user = snapshot.data;

                      final nombre = _obtenerNombreDrawer(user);

                      final rol = _obtenerCampoDrawer(user, 'role');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          Text(
                            rol,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(color: Colors.white12, height: 1),

            const SizedBox(height: 20),

            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              isActive: true,
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),

            _drawerItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              onTap: () {
                Navigator.pop(context);
                navigateWithLoading(context, const MisticketsScreen(), mensaje: 'Cargando tus tickets...');
              },
            ),

            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              onTap: () {
                Navigator.pop(context);
                navigateWithLoading(context, const CrearticketsScreen(), mensaje: 'Preparando crear ticket...');
              },
            ),

            _drawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Avisos',
              onTap: () {
                Navigator.pop(context);
                navigateWithLoading(context, const AvisosScreen(), mensaje: 'Cargando avisos...');
              },
            ),

            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              onTap: () {
                Navigator.pop(context);
                navigateWithLoading(
                  context,
                  const MiPerfilScreen(),
                  mensaje: 'Cargando tu perfil...',
                );
              },
            ),

            const Divider(color: Colors.white12, height: 1),

            _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              color: Colors.white70,
              onTap: () async {
                await SessionService.clearSession();

                if (!context.mounted) {
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerCampoDrawer(Map<String, dynamic>? user, String campo) {
    if (user == null) {
      return '';
    }

    final valor = user[campo];

    if (valor == null) {
      return '';
    }

    if (valor is Map) {
      final resultado = valor['nombre'] ?? valor['name'] ?? valor['value'];

      return resultado?.toString().trim() ?? '';
    }

    return valor.toString().trim();
  }

  String _obtenerNombreDrawer(Map<String, dynamic>? user) {
    final nombre = _obtenerCampoDrawer(user, 'name');

    if (nombre.isNotEmpty) {
      return nombre;
    }

    final login = _obtenerCampoDrawer(user, 'login');

    if (login.isNotEmpty) {
      return login;
    }

    return 'Usuario';
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? (isActive ? Colors.white : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(icon, color: itemColor),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
