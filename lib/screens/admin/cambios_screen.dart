import 'package:flutter/material.dart';

import '../../services/admin/cambios_services.dart';
import '../../widgets/loading_screen.dart';
import '../../services/session_service.dart';
import '../../widgets/admin_notifications_dialog.dart';
import 'avisosadmin_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class CambiosScreen extends StatefulWidget {
  const CambiosScreen({super.key});

  @override
  State<CambiosScreen> createState() => _CambiosScreenState();
}

class _CambiosScreenState extends State<CambiosScreen> {
  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color greenAccent = Color(0xFF00A86B);
  static const Color redAccent = Color(0xFFE11D48);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  String selectedFilter = 'Todos';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  List<SolicitudCambio> solicitudes = [];

  bool cargando = true;
  bool cargandoDetalle = false;
  bool operando = false;

  String? error;

  int paginaActual = 1;
  int ultimaPagina = 1;
  int totalSolicitudesApi = 0;

  int total = 0;
  int pendientes = 0;
  int aprobadas = 0;
  int rechazadas = 0;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      final nuevoTexto = searchController.text.toLowerCase();

      if (searchQuery != nuevoTexto && mounted) {
        setState(() {
          searchQuery = nuevoTexto;
        });
      }
    });

    _cargarSolicitudes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _texto(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    return value.toString().trim();
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  String _limpiarError(dynamic e) {
    final mensaje = e.toString();

    if (mensaje.startsWith('Exception: ')) {
      return mensaje.substring(11);
    }

    return mensaje;
  }

  Future<void> _cargarSolicitudes({int pagina = 1}) async {
    if (pagina < 1) {
      pagina = 1;
    }

    if (mounted) {
      setState(() {
        cargando = true;
        error = null;
      });
    }

    try {
      final respuesta = await CambiosService.obtenerSolicitudes(
        pagina: pagina,
        porPagina: 10,
        buscar: searchController.text.trim(),
        estado: _estadoApi(selectedFilter),
      );

      if (!mounted) {
        return;
      }

      final data = _map(respuesta);
      final solicitudesData = data['solicitudes'];

      final lista = <SolicitudCambio>[];

      if (solicitudesData is List) {
        for (final elemento in solicitudesData) {
          final mapa = _map(elemento);

          if (mapa.isNotEmpty) {
            lista.add(SolicitudCambio.fromJson(mapa));
          }
        }
      }

      final pagination = _map(data['pagination']);
      final estadisticas = _map(data['estadisticas']);

      setState(() {
        solicitudes = lista;

        paginaActual = _toInt(pagination['current_page']) ?? pagina;

        ultimaPagina = _toInt(pagination['last_page']) ?? 1;

        totalSolicitudesApi = _toInt(pagination['total']) ?? lista.length;

        total = _toInt(estadisticas['total']) ?? totalSolicitudesApi;

        pendientes = _toInt(estadisticas['pendientes']) ?? 0;

        aprobadas = _toInt(estadisticas['aprobadas']) ?? 0;

        rechazadas = _toInt(estadisticas['rechazadas']) ?? 0;

        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = _limpiarError(e);
      });
    }
  }

  String? _estadoApi(String filtro) {
    switch (filtro) {
      case 'En revisión':
        return 'pendiente';
      case 'Aprobada':
        return 'aprobada';
      case 'Rechazada':
        return 'rechazada';
      default:
        return null;
    }
  }

  Future<void> _buscar() async {
    await _cargarSolicitudes(pagina: 1);
  }

  Future<void> _verDetalle(SolicitudCambio item) async {
    if (item.id == null) {
      _mostrarMensaje('No se pudo identificar la solicitud.');
      return;
    }

    setState(() {
      cargandoDetalle = true;
    });

    try {
      final respuesta = await CambiosService.obtenerSolicitud(item.id!);

      if (!mounted) {
        return;
      }

      final data = _map(respuesta);
      final solicitudData = _map(data['solicitud']);

      final solicitud = solicitudData.isNotEmpty
          ? SolicitudCambio.fromJson(solicitudData)
          : item;

      setState(() {
        cargandoDetalle = false;
      });

      _mostrarDetalleSolicitud(solicitud);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargandoDetalle = false;
      });

      _mostrarMensaje(_limpiarError(e));
    }
  }

  Future<void> _aprobarSolicitud(
    SolicitudCambio item,
    String comentario,
  ) async {
    if (item.id == null) {
      _mostrarMensaje('No se pudo identificar la solicitud.');
      return;
    }

    setState(() {
      operando = true;
    });

    try {
      final respuesta = await CambiosService.aprobarSolicitud(
        id: item.id!,
        comentarioAdmin: comentario.trim().isEmpty ? null : comentario.trim(),
      );

      if (!mounted) {
        return;
      }

      final mensaje = _texto(respuesta['message']);

      Navigator.of(context).pop();

      _mostrarMensaje(
        mensaje.isNotEmpty
            ? mensaje
            : 'La solicitud fue aprobada correctamente.',
      );

      await _cargarSolicitudes(pagina: paginaActual);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          operando = false;
        });
      }
    }
  }

  Future<void> _rechazarSolicitud(
    SolicitudCambio item,
    String comentario,
  ) async {
    if (item.id == null) {
      _mostrarMensaje('No se pudo identificar la solicitud.');
      return;
    }

    if (comentario.trim().isEmpty) {
      _mostrarMensaje('Debes indicar el motivo del rechazo.');
      return;
    }

    setState(() {
      operando = true;
    });

    try {
      final respuesta = await CambiosService.rechazarSolicitud(
        id: item.id!,
        comentarioAdmin: comentario.trim(),
      );

      if (!mounted) {
        return;
      }

      final mensaje = _texto(respuesta['message']);

      Navigator.of(context).pop();

      _mostrarMensaje(
        mensaje.isNotEmpty
            ? mensaje
            : 'La solicitud fue rechazada correctamente.',
      );

      await _cargarSolicitudes(pagina: paginaActual);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          operando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final color = isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF22C55E);
        final icon = isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_rounded;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  isError ? 'Error' : 'Éxito',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<SolicitudCambio> get solicitudesFiltradas {
    if (searchQuery.isEmpty) {
      return solicitudes;
    }

    return solicitudes.where((solicitud) {
      return solicitud.folio.toLowerCase().contains(searchQuery) ||
          solicitud.solicitante.toLowerCase().contains(searchQuery) ||
          solicitud.email.toLowerCase().contains(searchQuery) ||
          solicitud.campo.toLowerCase().contains(searchQuery) ||
          solicitud.motivo.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = solicitudesFiltradas;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Pro',
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              showAdminNotificationsDialog(context);
            },
          ),
          const SizedBox(width: 8),
          const AdminProfileMenu(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(activeMenu: 'Cambios'),
      body: RefreshIndicator(
        onRefresh: () => _cargarSolicitudes(pagina: paginaActual),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solicitudes de cambio',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Consulta y da seguimiento a las solicitudes de cambio de información de cuentas',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    KPIStatCard(
                      title: 'Total de solicitudes',
                      count: '$total',
                      icon: Icons.folder_open_outlined,
                      iconColor: accentBlue,
                    ),
                    const SizedBox(width: 10),
                    KPIStatCard(
                      title: 'En revisión',
                      count: '$pendientes',
                      icon: Icons.access_time,
                      iconColor: Colors.amber,
                    ),
                    const SizedBox(width: 10),
                    KPIStatCard(
                      title: 'Aprobadas',
                      count: '$aprobadas',
                      icon: Icons.check_circle_outline,
                      iconColor: greenAccent,
                    ),
                    const SizedBox(width: 10),
                    KPIStatCard(
                      title: 'Rechazadas',
                      count: '$rechazadas',
                      icon: Icons.cancel_outlined,
                      iconColor: redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos'),
                    _buildFilterChip('En revisión', dotColor: Colors.amber),
                    _buildFilterChip('Aprobada', dotColor: greenAccent),
                    _buildFilterChip('Rechazada', dotColor: redAccent),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: textMuted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: textWhite, fontSize: 13),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _buscar(),
                        decoration: const InputDecoration(
                          hintText: 'Buscar solicitud...',
                          hintStyle: TextStyle(color: textMuted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchController.clear();
                          _buscar();
                        },
                        child: const Icon(
                          Icons.close,
                          color: textMuted,
                          size: 17,
                        ),
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _buscar,
                      icon: const Icon(
                        Icons.search,
                        color: accentBlue,
                        size: 19,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (cargando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(color: accentBlue),
                  ),
                )
              else if (error != null)
                _buildError()
              else if (filtradas.isEmpty)
                _buildEmpty()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final item = filtradas[index];

                    return SolicitudCard(
                      item: item,
                      onTap: () {
                        _verDetalle(item);
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              if (!cargando && error == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mostrando ${filtradas.length} de $totalSolicitudesApi solicitudes',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildPageBtn(
                            icon: Icons.chevron_left,
                            disabled: paginaActual <= 1,
                            onTap: paginaActual > 1
                                ? () => _cargarSolicitudes(
                                    pagina: paginaActual - 1,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 4),
                          _buildPageBtn(text: '$paginaActual', selected: true),
                          const SizedBox(width: 4),
                          _buildPageBtn(
                            icon: Icons.chevron_right,
                            disabled: paginaActual >= ultimaPagina,
                            onTap: paginaActual < ultimaPagina
                                ? () => _cargarSolicitudes(
                                    pagina: paginaActual + 1,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: redAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: redAccent, size: 40),
          const SizedBox(height: 10),
          const Text(
            'No se pudieron cargar las solicitudes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error ?? 'Ocurrió un error inesperado.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => _cargarSolicitudes(pagina: paginaActual),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: textMuted, size: 40),
          SizedBox(height: 10),
          Text(
            'No se encontraron solicitudes',
            style: TextStyle(
              color: textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Intenta con otro filtro o término de búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? dotColor}) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        if (selectedFilter == label) {
          return;
        }

        setState(() {
          selectedFilter = label;
        });

        _cargarSolicitudes(pagina: 1);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryBlue : Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? textWhite : textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (dotColor != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageBtn({
    String? text,
    IconData? icon,
    bool selected = false,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue
              : disabled
              ? Colors.white.withValues(alpha: 0.02)
              : cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? primaryBlue : Colors.white10),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: disabled ? Colors.white24 : textWhite,
                  size: 16,
                )
              : Text(
                  text!,
                  style: TextStyle(
                    color: selected ? textWhite : textMuted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }

  void _mostrarDetalleSolicitud(SolicitudCambio item) {
    final comentarioAprobacionController = TextEditingController();

    final comentarioRechazoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: operando
                          ? null
                          : () => Navigator.pop(modalContext),
                      icon: const Icon(Icons.close, color: textWhite, size: 22),
                      tooltip: 'Cerrar',
                    ),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalle de la solicitud',
                          style: TextStyle(
                            color: textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(item.estado),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Solicitado por',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: primaryBlue,
                            child: Text(
                              _iniciales(item.solicitante),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.solicitante,
                                  style: const TextStyle(
                                    color: textWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.email.isNotEmpty)
                                  Text(
                                    item.email,
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                if (item.puesto.isNotEmpty)
                                  Text(
                                    item.puesto,
                                    style: const TextStyle(
                                      color: accentBlue,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Campo solicitado',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.campo,
                                style: const TextStyle(
                                  color: textWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha solicitud',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.fecha,
                                style: const TextStyle(
                                  color: textWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Información actual',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    _buildInfoContainer(item.infoActual),
                    const SizedBox(height: 14),
                    const Text(
                      'Información solicitada',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item.infoSolicitada,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Motivo de solicitud',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.motivo,
                      style: const TextStyle(color: textWhite, fontSize: 13),
                    ),
                    if (item.estado == 'En revisión') ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      const Text(
                        'Resolver solicitud',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCommentField(
                        controller: comentarioAprobacionController,
                        hint: 'Comentario opcional al aprobar...',
                        enabled: !operando,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenAccent,
                            disabledBackgroundColor: greenAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: operando
                              ? null
                              : () {
                                  _aprobarSolicitud(
                                    item,
                                    comentarioAprobacionController.text,
                                  );
                                },
                          icon: operando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            operando ? 'Procesando...' : 'Aprobar solicitud',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildCommentField(
                        controller: comentarioRechazoController,
                        hint: 'Motivo del rechazo...',
                        enabled: !operando,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redAccent,
                            disabledBackgroundColor: redAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: operando
                              ? null
                              : () {
                                  _rechazarSolicitud(
                                    item,
                                    comentarioRechazoController.text,
                                  );
                                },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Rechazar solicitud',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      comentarioAprobacionController.dispose();
      comentarioRechazoController.dispose();

      if (mounted) {
        setState(() {
          operando = false;
        });
      }
    });
  }

  String _iniciales(String nombre) {
    if (nombre.trim().isEmpty) {
      return 'US';
    }

    final partes = nombre.trim().split(RegExp(r'\s+'));

    if (partes.length == 1) {
      return partes.first
          .substring(0, partes.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  Widget _buildInfoContainer(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        value.isEmpty ? 'Sin información' : value,
        style: const TextStyle(color: textWhite, fontSize: 13),
      ),
    );
  }

  Widget _buildCommentField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: textWhite, fontSize: 12),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textMuted, fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.amber.withValues(alpha: 0.15);
    Color text = Colors.amber;

    if (status == 'Aprobada') {
      bg = greenAccent.withValues(alpha: 0.15);
      text = greenAccent;
    } else if (status == 'Rechazada') {
      bg = redAccent.withValues(alpha: 0.15);
      text = redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SolicitudCambio {
  final int? id;
  final String folio;
  final String solicitante;
  final String email;
  final String puesto;
  final String campo;
  String estado;
  final String fecha;
  final String fechaTabla;
  final String infoActual;
  final String infoSolicitada;
  final String motivo;

  SolicitudCambio({
    this.id,
    required this.folio,
    required this.solicitante,
    required this.email,
    required this.puesto,
    required this.campo,
    required this.estado,
    required this.fecha,
    required this.fechaTabla,
    required this.infoActual,
    required this.infoSolicitada,
    required this.motivo,
  });

  factory SolicitudCambio.fromJson(Map<String, dynamic> json) {
    final usuario = _mapFromJson(json['usuario']);

    final nombre = _stringFromJson(usuario['name']).isNotEmpty
        ? _stringFromJson(usuario['name'])
        : _stringFromJson(json['nombre_usuario']);

    final email = _stringFromJson(usuario['email']).isNotEmpty
        ? _stringFromJson(usuario['email'])
        : _stringFromJson(json['email']);

    final role = _stringFromJson(usuario['role']).isNotEmpty
        ? _stringFromJson(usuario['role'])
        : _stringFromJson(json['role']);

    final campo = _stringFromJson(json['campo']);
    final estadoApi = _stringFromJson(json['estado']);
    final fecha = _stringFromJson(json['created_at']);
    final id = _intFromJson(json['id']);

    return SolicitudCambio(
      id: id,
      folio: id?.toString() ?? _stringFromJson(json['folio']),
      solicitante: nombre.isNotEmpty ? nombre : _stringFromJson(json['login']),
      email: email,
      puesto: role,
      campo: campo,
      estado: _estadoFlutter(estadoApi),
      fecha: _formatearFecha(fecha),
      fechaTabla: _formatearFecha(fecha),
      infoActual: _stringFromJson(json['valor_actual']),
      infoSolicitada: _stringFromJson(json['nuevo_valor']),
      motivo: _stringFromJson(json['motivo']),
    );
  }

  static Map<String, dynamic> _mapFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  static String _stringFromJson(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  static int? _intFromJson(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  static String _estadoFlutter(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'En revisión';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return estado.isEmpty ? 'En revisión' : estado;
    }
  }

  static String _formatearFecha(String fecha) {
    if (fecha.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(fecha).toLocal();

      String dos(int value) => value.toString().padLeft(2, '0');

      return '${dos(date.day)}/${dos(date.month)}/${date.year} '
          '${dos(date.hour)}:${dos(date.minute)}';
    } catch (_) {
      return fecha;
    }
  }
}

class SolicitudCard extends StatelessWidget {
  final SolicitudCambio item;
  final VoidCallback onTap;

  const SolicitudCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Text(
              item.folio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.solicitante,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.email.isNotEmpty)
                  Text(
                    item.email,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Campo: ',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    Expanded(
                      child: Text(
                        item.campo,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(item.estado),
              const SizedBox(height: 8),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.amber.withValues(alpha: 0.15);
    Color text = Colors.amber;

    if (status == 'Aprobada') {
      bg = const Color(0xFF00A86B).withValues(alpha: 0.15);
      text = const Color(0xFF00A86B);
    } else if (status == 'Rechazada') {
      bg = const Color(0xFFE11D48).withValues(alpha: 0.15);
      text = const Color(0xFFE11D48);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class KPIStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;

  const KPIStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  final String activeMenu;

  const CustomSidebar({super.key, this.activeMenu = 'Inicio'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _CambiosScreenState.sidebarBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: _CambiosScreenState.sidebarBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      TextSpan(
                        text: 'Pro',
                        style: TextStyle(
                          color: _CambiosScreenState.accentBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const AdminAvatar(radius: 16),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jesus Hinojosa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Administrador',
                            style: TextStyle(
                              color: _CambiosScreenState.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.grid_view_rounded,
            'Inicio',
            selected: activeMenu == 'Inicio',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AdminScreen(),
                mensaje: 'Cargando inicio...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.confirmation_number_outlined,
            'Tickets',
            selected: activeMenu == 'Tickets',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const TicketsScreen(),
                mensaje: 'Cargando tickets...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.sync_alt_rounded,
            'Cambios',
            selected: activeMenu == 'Cambios',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _drawerItem(
            context,
            Icons.people_outline,
            'Usuarios',
            selected: activeMenu == 'Usuarios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const UserScreen(),
                mensaje: 'Cargando usuarios...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.devices_other,
            'Dispositivos',
            selected: activeMenu == 'Dispositivos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const DispositivosScreen(),
                mensaje: 'Cargando dispositivos...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.campaign_outlined,
            'Avisos',
            selected: activeMenu == 'Avisos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AvisosadminScreen(),
                mensaje: 'Cargando avisos...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.person_outline,
            'Mi perfil',
            selected: activeMenu == 'Mi perfil',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const PerfiladminScreen(),
                mensaje: 'Cargando perfil...',
              );
            },
          ),
          const Divider(color: Colors.white10),
          _drawerItem(
            context,
            Icons.logout_rounded,
            'Cerrar sesión',
            isExit: true,
            onTap: () async {
              await SessionService.clearSession();

              if (!context.mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool selected = false,
    bool isExit = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? _CambiosScreenState.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isExit
                ? Colors.redAccent
                : selected
                ? Colors.white
                : _CambiosScreenState.textMuted,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isExit
                  ? Colors.redAccent
                  : selected
                  ? Colors.white
                  : _CambiosScreenState.textMuted,
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
