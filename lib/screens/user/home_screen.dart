import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../services/ticket_service.dart';
import 'mistickets_screen.dart';
import 'creartickets_screen.dart';
import 'avisos_screen.dart';

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
      debugPrint('Error cargando usuario: $e');

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
        throw Exception(
          'El servidor devolvió una respuesta vacía.',
        );
      }

      if (respuesta['success'] != true) {
        final mensaje = _textoSeguro(
          respuesta['message'],
        );

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

      final recientes = _convertirListaMap(
        respuesta['tickets_recientes'],
      );

      Map<String, dynamic>? ultimo;

      final ultimoRaw = respuesta['ultimo_ticket'];

      if (ultimoRaw is Map) {
        ultimo = Map<String, dynamic>.from(
          ultimoRaw,
        );
      }

      final actividadesRecibidas =
          _obtenerListaRespuesta(
        respuesta,
        [
          'actividad',
          'actividades',
          'actividad_reciente',
          'actividades_recientes',
        ],
      );

      final avisosRecibidos =
          _obtenerListaRespuesta(
        respuesta,
        [
          'avisos',
          'avisos_importantes',
          'avisos_recientes',
        ],
      );

      final notificacionesRecibidas =
          _obtenerListaRespuesta(
        respuesta,
        [
          'notificaciones',
          'notifications',
          'notificaciones_recientes',
        ],
      );

      final noLeidas = _enteroSeguro(
        respuesta['notificaciones_no_leidas'],
      );

      if (!mounted) return;

      setState(() {
        ticketsTotal =
            _enteroSeguro(resumen['total']);

        ticketsAbiertos =
            _enteroSeguro(resumen['abiertos']);

        ticketsEnProceso =
            _enteroSeguro(resumen['en_proceso']);

        ticketsSolucionados =
            _enteroSeguro(resumen['solucionados']);

        ticketsCancelados =
            _enteroSeguro(resumen['cancelados']);

        ticketsRecientes = recientes;
        ultimoTicket = ultimo;
        actividades = actividadesRecibidas;
        avisos = avisosRecibidos;
        notificaciones = notificacionesRecibidas;
        notificacionesNoLeidas = noLeidas;

        cargandoTickets = false;
        errorTickets = null;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Error cargando dashboard: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

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

  List<Map<String, dynamic>> _convertirListaMap(
    dynamic valor,
  ) {
    final resultado =
        <Map<String, dynamic>>[];

    if (valor is! List) {
      return resultado;
    }

    for (final item in valor) {
      if (item is Map) {
        resultado.add(
          Map<String, dynamic>.from(item),
        );
      }
    }

    return resultado;
  }

  String _limpiarError(Object error) {
    final texto = error.toString();

    if (texto.startsWith('Exception: ')) {
      return texto.substring(
        'Exception: '.length,
      );
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
      return int.tryParse(
            valor.trim(),
          ) ??
          0;
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

  String _datoUsuario(
    String campo, {
    String defecto = 'No disponible',
  }) {
    final datos = usuario;

    if (datos == null) {
      return defecto;
    }

    final texto = _textoSeguro(
      datos[campo],
    );

    return texto.isNotEmpty
        ? texto
        : defecto;
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
      final texto = _textoSeguro(
        datos[campo],
      );

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return defecto;
  }

  String get nombreUsuario {
    final nombre = _datoUsuario(
      'name',
      defecto: '',
    );

    if (nombre.isNotEmpty) {
      return nombre;
    }

    return _datoUsuario(
      'login',
      defecto: 'Usuario',
    );
  }

  String get loginUsuario {
    return _datoUsuario(
      'login',
      defecto: 'Usuario',
    );
  }

  String get emailUsuario {
    return _datoUsuario('email');
  }

  String get rolUsuario {
    return _datoUsuario('role');
  }

  String get empresaUsuario {
    return _datoAlternativo([
      'empresa',
      'empresa_nombre',
      'nombre_empresa',
    ]);
  }

  String get departamentoUsuario {
    return _datoAlternativo([
      'departamento',
      'departamento_nombre',
      'nombre_departamento',
    ]);
  }

  String get oficinaUsuario {
    return _datoAlternativo([
      'oficina',
      'oficina_nombre',
      'nombre_oficina',
    ]);
  }

  String get empleadoUsuario {
    return _datoAlternativo([
      'numero_empleado',
      'numeroEmpleado',
      'empleado',
    ]);
  }

  void _abrirCrearTicket(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CrearticketsScreen(),
      ),
    );
  }

  void _abrirMisTickets(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MisticketsScreen(),
      ),
    );
  }

  void _abrirAvisos(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AvisosScreen(),
      ),
    );
  }

  void _abrirNotificaciones() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.75,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor:
              const Color(0xFF0D1427),
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
            side: BorderSide(
              color:
                  Colors.blue.withOpacity(0.18),
            ),
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 560,
              maxHeight: 650,
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    18,
                    12,
                    16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2563EB,
                          ).withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .notifications_none_rounded,
                          color:
                              Color(0xFF60A5FA),
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Notificaciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              notificaciones
                                      .isEmpty
                                  ? 'No tienes notificaciones'
                                  : '$notificacionesNoLeidas sin leer',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.white10,
                  height: 1,
                ),
                Expanded(
                  child: notificaciones.isEmpty
                      ? _buildNotificacionesVacias()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          itemCount:
                              notificaciones.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 8,
                          ),
                          itemBuilder:
                              (context, index) {
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
                color: Colors.white.withOpacity(
                  0.04,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .notifications_off_outlined,
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
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacionItem(
    Map<String, dynamic> notificacion,
  ) {
    final titulo = _obtenerTituloNotificacion(
      notificacion,
    );

    final mensaje =
        _obtenerMensajeNotificacion(
      notificacion,
    );

    final fecha =
        _obtenerFechaNotificacion(
      notificacion,
    );

    final tipo =
        _textoSeguro(
      notificacion['tipo'],
    ).toLowerCase();

    final leida =
        _esNotificacionLeida(
      notificacion,
    );

    final color =
        _colorNotificacion(tipo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: leida
            ? const Color(0xFF141C33)
            : const Color(0xFF182442),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: leida
              ? Colors.white.withOpacity(
                  0.04,
                )
              : color.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: Icon(
              _iconoNotificacion(tipo),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: leida
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!leida)
                      Container(
                        width: 7,
                        height: 7,
                        margin:
                            const EdgeInsets.only(
                          left: 6,
                          top: 3,
                        ),
                        decoration:
                            const BoxDecoration(
                          color:
                              Color(0xFF3B82F6),
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
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  fecha,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerTituloNotificacion(
    Map<String, dynamic> notificacion,
  ) {
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

    final folio =
        _textoSeguro(notificacion['folio']);

    if (folio.isNotEmpty) {
      return 'Notificación del ticket $folio';
    }

    return 'Notificación';
  }

  String _obtenerMensajeNotificacion(
    Map<String, dynamic> notificacion,
  ) {
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

  String _obtenerFechaNotificacion(
    Map<String, dynamic> notificacion,
  ) {
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
        return _formatearFechaActividad(
          texto,
        );
      }
    }

    return 'Fecha no disponible';
  }

  bool _esNotificacionLeida(
    Map<String, dynamic> notificacion,
  ) {
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
      final texto =
          valor.toLowerCase().trim();

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

    if (tipo.contains('error') ||
        tipo.contains('cancel')) {
      return Colors.redAccent;
    }

    if (tipo.contains('success') ||
        tipo.contains('solucion')) {
      return Colors.green;
    }

    return Colors.blueAccent;
  }

  IconData _iconoNotificacion(
    String tipo,
  ) {
    if (tipo.contains('aviso') ||
        tipo.contains('warning') ||
        tipo.contains('advertencia')) {
      return Icons.warning_amber_rounded;
    }

    if (tipo.contains('error') ||
        tipo.contains('cancel')) {
      return Icons.error_outline;
    }

    if (tipo.contains('success') ||
        tipo.contains('solucion')) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor:
          const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor:
                  const Color(0xFF0B1021),
              elevation: 0,
              iconTheme:
                  const IconThemeData(
                color: Colors.white,
              ),
              title: const AppLogo(
                fontSize: 20,
              ),
              actions: [
                _buildNotificationButton(
                  compact: true,
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(right: 16),
                  child: UserAvatar(
                    radius: 16,
                  ),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(),
            ),
          Expanded(
            child: Column(
              children: [
                if (isDesktop)
                  _buildDesktopHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarTickets,
                    child:
                        SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _buildHeader(
                            context,
                            isDesktop,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (errorTickets !=
                              null)
                            _buildErrorTickets(),
                          _buildLayout(
                            context,
                            isDesktop,
                          ),
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1021),
        border: Border(
          bottom: BorderSide(
            color: Colors.white10,
          ),
        ),
      ),
      child: Row(
        children: [
          const AppLogo(
            fontSize: 23,
          ),
          const Spacer(),
          _buildNotificationButton(),
          const SizedBox(width: 8),
          const UserAvatar(
            radius: 17,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              nombreUsuario,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton({
    bool compact = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed:
              _abrirNotificacionDesdeHeader,
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
              constraints:
                  const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration:
                  const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                notificacionesNoLeidas >
                        99
                    ? '99+'
                    : '$notificacionesNoLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.bold,
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
      margin:
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            Colors.red.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              Colors.red.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudieron cargar los datos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorTickets ??
                      'Error desconocido',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      _cargarTickets,
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                  ),
                  label: const Text(
                    'Reintentar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDesktop,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth < 500;

        if (compact) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                cargandoUsuario
                    ? 'Cargando...'
                    : 'Bienvenido, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Inicio / Dashboard',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  onPressed: () {
                    _abrirCrearTicket(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Nuevo ticket',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    cargandoUsuario
                        ? 'Cargando...'
                        : 'Bienvenido, $nombreUsuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  const Text(
                    'Inicio / Dashboard',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _abrirCrearTicket(
                  context,
                );
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Nuevo ticket',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLayout(
    BuildContext context,
    bool isDesktop,
  ) {
    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildUserInfo(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    _buildTicketSummary(),
              ),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLastTicket(),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildActivity(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildRecentTickets(
                      true,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
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
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              Colors.blue.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
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
          constraints:
              const BoxConstraints(
            maxWidth: 460,
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0xFF2563EB,
                    ),
                    width: 2,
                  ),
                ),
                child: const UserAvatar(
                  radius: 42,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                nombreUsuario,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rolUsuario,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF141C33),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      Icons.person_outline,
                      'Nombre:',
                      nombreUsuario,
                    ),
                    _infoRow(
                      Icons.account_circle_outlined,
                      'Usuario:',
                      loginUsuario,
                    ),
                    _infoRow(
                      Icons.business_outlined,
                      'Empresa:',
                      empresaUsuario,
                    ),
                    _infoRow(
                      Icons.apartment_outlined,
                      'Departamento:',
                      departamentoUsuario,
                    ),
                    _infoRow(
                      Icons.email_outlined,
                      'Correo:',
                      emailUsuario,
                    ),
                    _infoRow(
                      Icons.location_city_outlined,
                      'Oficina:',
                      oficinaUsuario,
                    ),
                    _infoRow(
                      Icons.badge_outlined,
                      'Empleado:',
                      empleadoUsuario,
                    ),
                    _infoRow(
                      Icons.work_outline,
                      'Rol:',
                      rolUsuario,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Icon(
              icon,
              size: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
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
            child:
                CircularProgressIndicator(),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _metricBadge(
            ticketsAbiertos,
            'Abiertos',
            Colors.yellow,
          ),
          _metricBadge(
            ticketsEnProceso,
            'En proceso',
            Colors.blue,
          ),
          _metricBadge(
            ticketsSolucionados,
            'Solucionados',
            Colors.green,
          ),
          _metricBadge(
            ticketsCancelados,
            'Cancelados',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(
    int count,
    String label,
    Color color,
  ) {
    return Container(
      width: 72,
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
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
            child:
                CircularProgressIndicator(),
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    final ticket = ultimoTicket!;

    final folio =
        _textoSeguro(ticket['folio']);

    final tipo =
        _textoSeguro(ticket['tipo_falla']);

    final estado =
        _textoSeguro(ticket['estado']);

    final prioridad =
        _textoSeguro(ticket['prioridad']);

    final departamento =
        _textoSeguro(ticket['departamento']);

    final oficina =
        _textoSeguro(ticket['oficina']);

    final asignadoA =
        _obtenerUsuarioTicket(
      ticket['asignado_a'],
      ticket['asignado_a_usuario'],
    );

    final tomadoPor =
        _obtenerUsuarioTicket(
      ticket['tomado_por'],
      ticket['tomado_por_usuario'],
    );

    final fechaReporte =
        _formatearFecha(
      ticket['created_at'],
    );

    final fechaAsignacion =
        _formatearFecha(
      ticket['fecha_asignacion'],
    );

    final solucion =
        ticket['solucion'];

    final problemaSolucionado =
        solucion is Map
            ? solucion[
                'problema_solucionado']
            : null;

    final seSoluciono =
        problemaSolucionado == true ||
        problemaSolucionado == 1 ||
        problemaSolucionado
                ?.toString()
                .toLowerCase() ==
            'true';

    return _buildCard(
      title: 'Último ticket',
      trailing: TextButton(
        onPressed: () {
          _abrirMisTickets(context);
        },
        child: const Text(
          'Ver detalles',
        ),
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141C33),
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              folio.isNotEmpty
                  ? folio
                  : 'Sin folio',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            _ticketDetailRow(
              'Tipo de falla:',
              tipo.isNotEmpty
                  ? tipo
                  : 'N/A',
            ),
            _ticketDetailRow(
              'Fecha reporte:',
              fechaReporte,
            ),
            _ticketDetailRow(
              'Departamento:',
              departamento.isNotEmpty
                  ? departamento
                  : 'N/A',
            ),
            _ticketDetailRow(
              'Asignado a:',
              asignadoA.isNotEmpty
                  ? asignadoA
                  : 'N/A',
            ),
            _ticketDetailRow(
              'Sucursal / Oficina:',
              oficina.isNotEmpty
                  ? oficina
                  : 'N/A',
            ),
            _ticketDetailRow(
              'Tomado por:',
              tomadoPor.isNotEmpty
                  ? tomadoPor
                  : 'N/A',
            ),
            _ticketDetailRow(
              'Estado:',
              estado.isNotEmpty
                  ? estado
                  : 'N/A',
              valueColor:
                  _colorEstado(estado),
            ),
            _ticketDetailRow(
              'Asignación:',
              fechaAsignacion,
            ),
            _ticketDetailRow(
              'Prioridad:',
              prioridad.isNotEmpty
                  ? prioridad
                  : 'N/A',
              valueColor:
                  _colorPrioridad(
                prioridad,
              ),
            ),
            _ticketDetailRow(
              '¿Se solucionó?',
              seSoluciono
                  ? 'Sí'
                  : 'No',
              valueColor:
                  seSoluciono
                      ? Colors.green
                      : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerUsuarioTicket(
    dynamic login,
    dynamic usuarioRelacionado,
  ) {
    if (usuarioRelacionado is Map) {
      final nombre =
          _textoSeguro(
        usuarioRelacionado['name'],
      );

      if (nombre.isNotEmpty) {
        return nombre;
      }

      final loginRelacionado =
          _textoSeguro(
        usuarioRelacionado['login'],
      );

      if (loginRelacionado.isNotEmpty) {
        return loginRelacionado;
      }
    }

    return _textoSeguro(login);
  }

  String _formatearFecha(
    dynamic fecha,
  ) {
    if (fecha == null) {
      return 'N/A';
    }

    final texto =
        _textoSeguro(fecha);

    if (texto.isEmpty) {
      return 'N/A';
    }

    final fechaParsed =
        DateTime.tryParse(texto);

    if (fechaParsed == null) {
      return texto;
    }

    final dia = fechaParsed.day
        .toString()
        .padLeft(2, '0');

    final mes =
        _nombreMes(
      fechaParsed.month,
    );

    final anio =
        fechaParsed.year.toString();

    return '$dia $mes $anio';
  }

  String _formatearFechaActividad(
    dynamic fecha,
  ) {
    if (fecha == null) {
      return 'Fecha no disponible';
    }

    final texto =
        _textoSeguro(fecha);

    if (texto.isEmpty) {
      return 'Fecha no disponible';
    }

    final fechaParsed =
        DateTime.tryParse(texto);

    if (fechaParsed == null) {
      return texto;
    }

    final dia = fechaParsed.day
        .toString()
        .padLeft(2, '0');

    final mes =
        _nombreMes(
      fechaParsed.month,
    );

    final anio =
        fechaParsed.year.toString();

    final hora = fechaParsed.hour
        .toString()
        .padLeft(2, '0');

    final minuto =
        fechaParsed.minute
            .toString()
            .padLeft(2, '0');

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

  Widget _ticketDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color:
                    valueColor ??
                        Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTickets(
    bool isDesktop,
  ) {
    return _buildCard(
      title: 'Mis tickets recientes',
      trailing: TextButton(
        onPressed: () {
          _abrirMisTickets(context);
        },
        child: const Text(
          'Ver todos',
        ),
      ),
      child: ticketsRecientes.isEmpty
          ? const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(20),
                child: Text(
                  'No tienes tickets recientes.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : isDesktop
              ? _buildTicketsDesktop()
              : _buildTicketsMobile(),
    );
  }

  Widget _buildTicketsDesktop() {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowColor:
            MaterialStateProperty.all(
          const Color(0xFF141C33),
        ),
        columns: const [
          DataColumn(
            label: Text(
              'Folio',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Tipo',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Acción',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        rows: ticketsRecientes.map(
          (ticket) {
            final folio =
                _textoSeguro(
              ticket['folio'],
            );

            final tipo =
                _textoSeguro(
              ticket['tipo_falla'],
            );

            final estado =
                _textoSeguro(
              ticket['estado'],
            );

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    folio.isNotEmpty
                        ? folio
                        : 'Sin folio',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    tipo.isNotEmpty
                        ? tipo
                        : 'No disponible',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    estado.isNotEmpty
                        ? estado
                        : 'No disponible',
                    style: TextStyle(
                      color:
                          _colorEstado(
                        estado,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon:
                        const Icon(
                      Icons
                          .visibility_outlined,
                      size: 18,
                      color:
                          Colors.blueAccent,
                    ),
                    onPressed: () {
                      _abrirMisTickets(
                        context,
                      );
                    },
                    tooltip:
                        'Ver ticket',
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildTicketsMobile() {
    return Column(
      children:
          ticketsRecientes.map(
        (ticket) {
          final folio =
              _textoSeguro(
            ticket['folio'],
          );

          final tipo =
              _textoSeguro(
            ticket['tipo_falla'],
          );

          final estado =
              _textoSeguro(
            ticket['estado'],
          );

          final titulo =
              _textoSeguro(
            ticket['titulo'],
          );

          return Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(
              bottom: 8,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF141C33),
              borderRadius:
                  BorderRadius.circular(
                6,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        folio.isNotEmpty
                            ? folio
                            : 'Sin folio',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 12,
                          color:
                              Colors.white,
                        ),
                      ),
                      if (titulo
                          .isNotEmpty)
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        tipo.isNotEmpty
                            ? tipo
                            : 'No disponible',
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                      Text(
                        estado.isNotEmpty
                            ? estado
                            : 'No disponible',
                        style: TextStyle(
                          color:
                              _colorEstado(
                            estado,
                          ),
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(
                    Icons
                        .visibility_outlined,
                    color:
                        Colors.blueAccent,
                    size: 20,
                  ),
                  onPressed: () {
                    _abrirMisTickets(
                      context,
                    );
                  },
                  tooltip:
                      'Ver ticket',
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Color _colorEstado(
    String estado,
  ) {
    switch (
        estado.toLowerCase().trim()) {
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

  Color _colorPrioridad(
    String prioridad,
  ) {
    switch (
        prioridad.toLowerCase().trim()) {
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
      trailing:
          actividades.isNotEmpty
              ? Text(
                  '${actividades.length}',
                  style:
                      const TextStyle(
                    color:
                        Colors.blueAccent,
                    fontWeight:
                        FontWeight.bold,
                  ),
                )
              : null,
      child: actividades.isEmpty
          ? const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(20),
                child: Text(
                  'No hay actividad reciente.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Column(
              children:
                  List.generate(
                actividades.length,
                (index) {
                  final actividad =
                      actividades[index];

                  final texto =
                      _obtenerTextoActividad(
                    actividad,
                  );

                  final fecha =
                      _obtenerFechaActividad(
                    actividad,
                  );

                  final color =
                      _colorActividad(
                    actividad,
                  );

                  return _activityItem(
                    texto,
                    fecha,
                    color,
                    isLast:
                        index ==
                            actividades
                                    .length -
                                1,
                  );
                },
              ),
            ),
    );
  }

  String _obtenerTextoActividad(
    Map<String, dynamic> actividad,
  ) {
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
      final texto =
          _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    final folio =
        _textoSeguro(
      actividad['folio'],
    );

    final accion =
        _textoSeguro(
      actividad['accion'],
    );

    if (accion.isNotEmpty &&
        folio.isNotEmpty) {
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

  String _obtenerFechaActividad(
    Map<String, dynamic> actividad,
  ) {
    final posibles = [
      actividad['fecha'],
      actividad['fecha_actividad'],
      actividad['created_at'],
      actividad['updated_at'],
      actividad['date'],
      actividad['createdAt'],
    ];

    for (final valor in posibles) {
      final texto =
          _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return _formatearFechaActividad(
          valor,
        );
      }
    }

    return 'Fecha no disponible';
  }

  Color _colorActividad(
    Map<String, dynamic> actividad,
  ) {
    final tipo =
        _textoSeguro(
      actividad['tipo'],
    ).toLowerCase();

    final accion =
        _textoSeguro(
      actividad['accion'],
    ).toLowerCase();

    final texto =
        _obtenerTextoActividad(
      actividad,
    ).toLowerCase();

    final contenido =
        '$tipo $accion $texto';

    if (contenido.contains('tom') ||
        contenido.contains('asign')) {
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
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 3,
              top: 12,
              bottom: -6,
              child: Container(
                width: 1,
                color: Colors.white10,
              ),
            ),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 5,
                ),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      time,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 10,
                      ),
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
        child: const Text(
          'Ver todos',
        ),
      ),
      child: avisos.isEmpty
          ? const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(20),
                child: Text(
                  'No hay avisos disponibles.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Column(
              children: avisos
                  .take(3)
                  .map(
                    (aviso) {
                      final titulo =
                          _obtenerTituloAviso(
                        aviso,
                      );

                      final fecha =
                          _obtenerFechaAviso(
                        aviso,
                      );

                      final descripcion =
                          _obtenerDescripcionAviso(
                        aviso,
                      );

                      final tipo =
                          _textoSeguro(
                        aviso['tipo'],
                      ).toLowerCase();

                      final color =
                          _colorAviso(
                        tipo,
                      );

                      return _noticeItem(
                        titulo,
                        fecha,
                        descripcion,
                        _iconoAviso(
                          tipo,
                        ),
                        color,
                      );
                    },
                  )
                  .toList(),
            ),
    );
  }

  String _obtenerTituloAviso(
    Map<String, dynamic> aviso,
  ) {
    final posibles = [
      aviso['titulo'],
      aviso['title'],
      aviso['nombre'],
      aviso['name'],
    ];

    for (final valor in posibles) {
      final texto =
          _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return 'Aviso';
  }

  String _obtenerDescripcionAviso(
    Map<String, dynamic> aviso,
  ) {
    final posibles = [
      aviso['descripcion'],
      aviso['description'],
      aviso['texto'],
      aviso['mensaje'],
      aviso['message'],
    ];

    for (final valor in posibles) {
      final texto =
          _textoSeguro(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _obtenerFechaAviso(
    Map<String, dynamic> aviso,
  ) {
    final posibles = [
      aviso['fecha'],
      aviso['created_at'],
      aviso['updated_at'],
      aviso['date'],
    ];

    for (final valor in posibles) {
      final texto =
          _textoSeguro(valor);

      if (texto.isNotEmpty) {
        final parsed =
            DateTime.tryParse(texto);

        if (parsed != null) {
          final dia = parsed.day
              .toString()
              .padLeft(2, '0');

          final mes =
              _nombreMes(
            parsed.month,
          );

          final anio =
              parsed.year.toString();

          return '$dia $mes $anio';
        }

        return texto;
      }
    }

    return 'Fecha no disponible';
  }

  Color _colorAviso(
    String tipo,
  ) {
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

  IconData _iconoAviso(
    String tipo,
  ) {
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
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141C33),
        borderRadius:
            BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (description
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
            onPressed: () {
              _abrirAvisos(context);
            },
            tooltip: 'Ver aviso',
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final double radius;

  const UserAvatar({
    super.key,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          const Color(0xFF2563EB),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: radius * 1.15,
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({
    super.key,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight:
              FontWeight.bold,
        ),
        children: const [
          TextSpan(
            text: 'Ticket',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: 'Pro',
            style: TextStyle(
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class AppNavigationDrawer
    extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
  child: Container(
    color: const Color(0xFF0B1021),
    padding: const EdgeInsets.symmetric(
      vertical: 36,
      horizontal: 16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(
          fontSize: 26,
        ),

        const SizedBox(height: 24),

        // ============================================================
        // USUARIO
        // ============================================================

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
              child: const UserAvatar(
                radius: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: SessionService.getUser(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final user = snapshot.data;

                  final nombre = _obtenerNombreDrawer(
                    user,
                  );

                  final rol = _obtenerCampoDrawer(
                    user,
                    'role',
                  );

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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

        const Divider(
          color: Colors.white12,
          height: 1,
        ),

        const SizedBox(height: 20),

        // ============================================================
        // INICIO
        // ============================================================

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

        // ============================================================
        // MIS TICKETS
        // ============================================================

        _drawerItem(
          icon: Icons.confirmation_number_outlined,
          title: 'Mis tickets',
          onTap: () {
            // Cerrar Drawer
            Navigator.pop(context);

            // Transición suave
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration:
                    const Duration(milliseconds: 300),
                reverseTransitionDuration:
                    const Duration(milliseconds: 250),

                pageBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                ) {
                  return const MisticketsScreen();
                },

                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),

        // ============================================================
        // CREAR TICKET
        // ============================================================

        _drawerItem(
          icon: Icons.build_outlined,
          title: 'Crear ticket',
          onTap: () {
            // Cerrar Drawer
            Navigator.pop(context);

            // Transición suave
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration:
                    const Duration(milliseconds: 300),
                reverseTransitionDuration:
                    const Duration(milliseconds: 250),

                pageBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                ) {
                  return const CrearticketsScreen();
                },

                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),

        // ============================================================
        // AVISOS
        // ============================================================

        _drawerItem(
          icon: Icons.warning_amber_rounded,
          title: 'Avisos',
          onTap: () {
            // Cerrar Drawer
            Navigator.pop(context);

            // Transición suave
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration:
                    const Duration(milliseconds: 300),
                reverseTransitionDuration:
                    const Duration(milliseconds: 250),

                pageBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                ) {
                  return const AvisosScreen();
                },

                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),

        // ============================================================
        // MI PERFIL
        // ============================================================

        _drawerItem(
          icon: Icons.person_outline_rounded,
          title: 'Mi perfil',
          onTap: () {
            // Aquí puedes colocar tu pantalla de perfil
          },
        ),

        const Spacer(),

        // ============================================================
        // CERRAR SESIÓN
        // ============================================================

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

  String _obtenerCampoDrawer(
    Map<String, dynamic>? user,
    String campo,
  ) {
    if (user == null) {
      return '';
    }

    final valor = user[campo];

    if (valor == null) {
      return '';
    }

    if (valor is Map) {
      final resultado =
          valor['nombre'] ??
              valor['name'] ??
              valor['value'];

      return resultado
              ?.toString()
              .trim() ??
          '';
    }

    return valor
        .toString()
        .trim();
  }

  String _obtenerNombreDrawer(
    Map<String, dynamic>? user,
  ) {
    final nombre =
        _obtenerCampoDrawer(
      user,
      'name',
    );

    if (nombre.isNotEmpty) {
      return nombre;
    }

    final login =
        _obtenerCampoDrawer(
      user,
      'login',
    );

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
    final itemColor =
        color ??
            (isActive
                ? Colors.white
                : Colors.grey);

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Material(
        color: isActive
            ? const Color(0xFF2563EB)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(10),
        clipBehavior:
            Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          leading: Icon(
            icon,
            color: itemColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight: isActive
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}