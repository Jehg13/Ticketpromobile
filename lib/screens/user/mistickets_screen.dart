import 'package:flutter/material.dart';

import 'creartickets_screen.dart';
import 'home_screen.dart';
import 'avisos_screen.dart';
import 'perfil_screen.dart';
import '../../services/mistickets_usuario_service.dart';

class MisticketsScreen extends StatefulWidget {
  const MisticketsScreen({super.key});

  @override
  State<MisticketsScreen> createState() => _MisticketsScreenState();
}

class _MisticketsScreenState extends State<MisticketsScreen> {
  static const String defaultAvatar = 'assets/images/user.png';

  final TextEditingController _buscarController =
      TextEditingController();

  List<Map<String, dynamic>> _tickets = [];

  bool _cargando = true;
  bool _cargandoDetalle = false;
  String? _error;

  String _estadoSeleccionado = 'todos';

  int _paginaActual = 1;
  int _ultimaPagina = 1;
  int _totalTickets = 0;

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _cargarTickets({
    int pagina = 1,
  }) async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta =
          await MisTicketsUsuarioService.obtenerTickets(
        buscar: _buscarController.text.trim(),
        estado: _estadoSeleccionado,
        pagina: pagina,
      );

      if (!mounted) return;

      final dynamic ticketsData = respuesta['tickets'];

      final List<Map<String, dynamic>> tickets =
          ticketsData is List
              ? ticketsData
                  .whereType<Map>()
                  .map(
                    (ticket) =>
                        Map<String, dynamic>.from(ticket),
                  )
                  .toList()
              : [];

      final dynamic pagination = respuesta['pagination'];

      int paginaActual = pagina;
      int ultimaPagina = 1;
      int total = tickets.length;

      if (pagination is Map) {
        paginaActual = _toInt(
          pagination['current_page'],
          pagina,
        );

        ultimaPagina = _toInt(
          pagination['last_page'],
          1,
        );

        total = _toInt(
          pagination['total'],
          tickets.length,
        );
      }

      setState(() {
        _tickets = tickets;
        _paginaActual = paginaActual;
        _ultimaPagina = ultimaPagina;
        _totalTickets = total;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = _limpiarError(e);
      });
    }
  }

  Future<void> _verDetalle(
    Map<String, dynamic> ticket,
  ) async {
    final dynamic idData = ticket['id'];

    final int? id = _toNullableInt(idData);

    if (id == null) {
      _mostrarMensaje(
        'No se pudo identificar el ticket.',
      );
      return;
    }

    setState(() {
      _cargandoDetalle = true;
    });

    try {
      final respuesta =
          await MisTicketsUsuarioService.obtenerTicket(
        id,
      );

      if (!mounted) return;

      final dynamic ticketData = respuesta['ticket'];

      if (ticketData is! Map) {
        throw Exception(
          'La información del ticket no es válida.',
        );
      }

      final detalle = Map<String, dynamic>.from(ticketData);

      setState(() {
        _cargandoDetalle = false;
      });

      await _mostrarDetalle(detalle);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoDetalle = false;
      });

      _mostrarMensaje(
        _limpiarError(e),
      );
    }
  }

  Future<void> _mostrarDetalle(
    Map<String, dynamic> ticket,
  ) async {
    final String folio = _string(
      ticket['folio'],
      null,
      fallback: 'Sin folio',
    );

    final String titulo = _string(
      ticket['titulo'],
      null,
      fallback: 'Sin título',
    );

    final String descripcion = _string(
      ticket['descripcion'],
      null,
      fallback: 'Sin descripción',
    );

    final String tipoFalla = _string(
      ticket['tipo_falla'],
      null,
      fallback: 'No especificado',
    );

    final String prioridad = _string(
      ticket['prioridad'],
      null,
      fallback: 'No especificada',
    );

    final String estado = _string(
      ticket['estado'],
      null,
      fallback: 'No especificado',
    );

    final String fecha = _formatearFecha(
      ticket['created_at'],
    );

    final dynamic solucionData = ticket['solucion'];

    Map<String, dynamic>? solucion;

    if (solucionData is Map) {
      solucion = Map<String, dynamic>.from(
        solucionData,
      );
    }

    final dynamic comentariosData =
        ticket['historial_comentarios'];

    final List<Map<String, dynamic>> comentarios =
        comentariosData is List
            ? comentariosData
                .whereType<Map>()
                .map(
                  (comentario) =>
                      Map<String, dynamic>.from(
                    comentario,
                  ),
                )
                .toList()
            : [];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final width =
            MediaQuery.of(dialogContext).size.width;

        return AlertDialog(
          backgroundColor: const Color(0xFF0B1021),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            20,
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      folio,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(
                _textoEstado(estado),
                _tipoEstado(estado),
              ),
            ],
          ),
          content: SizedBox(
            width: width > 700 ? 620 : width * .9,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _detailSection(
                    'Información del ticket',
                    [
                      _detailRow(
                        'Tipo de falla',
                        tipoFalla,
                      ),
                      _detailRow(
                        'Prioridad',
                        prioridad,
                      ),
                      _detailRow(
                        'Fecha de creación',
                        fecha,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _detailSection(
                    'Descripción',
                    [
                      Text(
                        descripcion,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  if (solucion != null) ...[
                    const SizedBox(height: 18),
                    _buildSolutionSection(
                      solucion,
                    ),
                  ],
                  if (comentarios.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildCommentsSection(
                      comentarios,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSolutionSection(
    Map<String, dynamic> solucion,
  ) {
    final String descripcion = _string(
      solucion['descripcion'],
      solucion['solucion'] ?? solucion['detalle'],
      fallback: 'Sin información',
    );

    final String fecha = _formatearFecha(
      solucion['created_at'],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withOpacity(.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF10B981),
                size: 19,
              ),
              const SizedBox(width: 8),
              const Text(
                'Solución aplicada',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (fecha != 'Sin fecha') ...[
            const SizedBox(height: 8),
            Text(
              fecha,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(
    List<Map<String, dynamic>> comentarios,
  ) {
    return _detailSection(
      'Comentarios',
      comentarios.map((comentario) {
        final String mensaje = _string(
          comentario['mensaje'],
          null,
          fallback: 'Sin mensaje',
        );

        final String fecha = _formatearFecha(
          comentario['created_at'],
        );

        final dynamic usuarioData =
            comentario['usuario'];

        String usuario = 'Usuario';

        if (usuarioData is Map) {
          usuario = _string(
            usuarioData['name'],
            usuarioData['login'],
            fallback: 'Usuario',
          );
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF060A17),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      usuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    fecha,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                mensaje,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _detailSection(
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
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
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _string(
    dynamic value,
    dynamic secondValue, {
    String fallback = '',
  }) {
    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    if (secondValue != null &&
        secondValue.toString().trim().isNotEmpty) {
      return secondValue.toString();
    }

    return fallback;
  }

  int? _toNullableInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value != null) {
      return int.tryParse(
        value.toString().trim(),
      );
    }

    return null;
  }

  String _formatearFecha(dynamic value) {
    if (value == null) {
      return 'Sin fecha';
    }

    final fecha = DateTime.tryParse(
      value.toString(),
    );

    if (fecha == null) {
      return value.toString();
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto =
        fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  int _toInt(
    dynamic value,
    int fallback,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  String _limpiarError(dynamic error) {
    final texto = error.toString();

    if (texto.startsWith('Exception: ')) {
      return texto.substring(11);
    }

    return texto;
  }

  String _textoEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'pendiente':
        return 'Pendiente';
      case 'en proceso':
        return 'En proceso';
      case 'solucionado':
        return 'Solucionado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  String _tipoEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'pendiente':
        return 'pendiente';
      case 'solucionado':
        return 'solucionado';
      case 'cancelado':
        return 'cancelado';
      case 'en proceso':
      default:
        return 'proceso';
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const AppLogo(
                fontSize: 20,
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(
                    right: 16,
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(
                      defaultAvatar,
                    ),
                  ),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(
              activeRoute: 'Mis tickets',
            ),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(
                activeRoute: 'Mis tickets',
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? 24 : 16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    isDesktop,
                  ),
                  const SizedBox(height: 24),
                  _buildMainCard(
                    context,
                    isDesktop,
                  ),
                ],
              ),
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
    if (!isDesktop) {
      return const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Mis tickets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mis tickets / Dashboard',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Mis tickets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mis tickets / Dashboard',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(
            defaultAvatar,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    bool isDesktop,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(.12),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis tickets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Consulta y da seguimiento a todos tus tickets registrados',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_totalTickets ticket${_totalTickets == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                _buildSearchAndFilter(),
              ],
            )
          else
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis tickets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Consulta y da seguimiento a todos tus tickets registrados',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_totalTickets ticket${_totalTickets == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
          ],
          const SizedBox(height: 20),
          _buildTicketsList(isDesktop),
          const SizedBox(height: 16),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 280,
          height: 38,
          child: TextField(
            controller: _buscarController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            onChanged: (_) {
              setState(() {});
            },
            onSubmitted: (_) {
              _cargarTickets(
                pagina: 1,
              );
            },
            decoration: InputDecoration(
              hintText:
                  'Buscar folio, título o fecha...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.grey,
                size: 18,
              ),
              suffixIcon:
                  _buscarController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 17,
                          ),
                          onPressed: () {
                            _buscarController.clear();
                            setState(() {});
                            _cargarTickets(
                              pagina: 1,
                            );
                          },
                        )
                      : null,
              filled: true,
              fillColor: const Color(0xFF060A17),
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8),
                borderSide:
                    const BorderSide(
                  color: Colors.white12,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ),
        _buildEstadoFilter(),
      ],
    );
  }

  Widget _buildEstadoFilter() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _estadoSeleccionado,
          dropdownColor: const Color(0xFF0B1021),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
            size: 18,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
          items: const [
            DropdownMenuItem(
              value: 'todos',
              child: Text('Todos'),
            ),
            DropdownMenuItem(
              value: 'pendiente',
              child: Text('Pendientes'),
            ),
            DropdownMenuItem(
              value: 'en proceso',
              child: Text('En proceso'),
            ),
            DropdownMenuItem(
              value: 'solucionado',
              child: Text('Solucionados'),
            ),
            DropdownMenuItem(
              value: 'cancelado',
              child: Text('Cancelados'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _estadoSeleccionado = value;
            });

            _cargarTickets(
              pagina: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketsList(
    bool isDesktop,
  ) {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2563EB),
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_tickets.isEmpty) {
      return _buildEmptyState();
    }

    if (!isDesktop) {
      return Column(
        children: _tickets
            .map(_buildMobileTicketItem)
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(3.0),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.0),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white10,
                  ),
                ),
              ),
              children: [
                _tableHeaderCell('Folio'),
                _tableHeaderCell('Título del ticket'),
                _tableHeaderCell('Estado'),
                _tableHeaderCell('Fecha de creación'),
                _tableHeaderCell(
                  'Acciones',
                  alignRight: true,
                ),
              ],
            ),
            ..._tickets.map(
              (ticket) {
                final estado = _string(
                  ticket['estado'],
                  null,
                  fallback: 'Pendiente',
                );

                return TableRow(
                  decoration:
                      const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white10,
                      ),
                    ),
                  ),
                  children: [
                    TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment
                              .middle,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Text(
                          _string(
                            ticket['folio'],
                            null,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment
                              .middle,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _string(
                                ticket['titulo'],
                                null,
                                fallback: 'Sin título',
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _string(
                                ticket['descripcion'],
                                null,
                                fallback:
                                    'Sin descripción',
                              ),
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment
                              .middle,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Align(
                          alignment:
                              Alignment.centerLeft,
                          child: _statusBadge(
                            _textoEstado(estado),
                            _tipoEstado(estado),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment
                              .middle,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Text(
                          _formatearFecha(
                            ticket['created_at'],
                          ),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment
                              .middle,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 4,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons
                                    .visibility_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  _cargandoDetalle
                                      ? null
                                      : () =>
                                          _verDetalle(
                                            ticket,
                                          ),
                              tooltip: 'Ver detalle',
                              visualDensity:
                                  VisualDensity.compact,
                              padding:
                                  const EdgeInsets.all(4),
                              constraints:
                                  const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTicketItem(
    Map<String, dynamic> ticket,
  ) {
    final estado = _string(
      ticket['estado'],
      null,
      fallback: 'Pendiente',
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1427),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _string(
                    ticket['folio'],
                    null,
                    fallback: 'Sin folio',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(
                _textoEstado(estado),
                _tipoEstado(estado),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _string(
              ticket['titulo'],
              null,
              fallback: 'Sin título',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _string(
              ticket['descripcion'],
              null,
              fallback: 'Sin descripción',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatearFecha(
                    ticket['created_at'],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 17,
                    color: Colors.grey,
                  ),
                  onPressed:
                      _cargandoDetalle
                          ? null
                          : () =>
                              _verDetalle(ticket),
                  tooltip: 'Ver ticket',
                  padding: EdgeInsets.zero,
                  visualDensity:
                      VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_ultimaPagina <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white70,
          ),
          onPressed:
              _paginaActual > 1 && !_cargando
                  ? () {
                      _cargarTickets(
                        pagina: _paginaActual - 1,
                      );
                    }
                  : null,
        ),
        Text(
          '$_paginaActual / $_ultimaPagina',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onPressed:
              _paginaActual < _ultimaPagina &&
                      !_cargando
                  ? () {
                      _cargarTickets(
                        pagina: _paginaActual + 1,
                      );
                    }
                  : null,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se encontraron tickets',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _buscarController.text.trim().isNotEmpty ||
                    _estadoSeleccionado != 'todos'
                ? 'Intenta cambiar los filtros de búsqueda.'
                : 'Todavía no tienes tickets registrados.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFF87171),
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            _error ??
                'No se pudieron cargar los tickets.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              _cargarTickets(
                pagina: _paginaActual,
              );
            },
            icon: const Icon(
              Icons.refresh,
              size: 17,
            ),
            label: const Text(
              'Reintentar',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String title, {
    bool alignRight = false,
  }) {
    return TableCell(
      verticalAlignment:
          TableCellVerticalAlignment.middle,
      child: _tableHeader(
        title,
        alignRight: alignRight,
      ),
    );
  }

  Widget _tableHeader(
    String title, {
    bool alignRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Text(
        title,
        textAlign:
            alignRight
                ? TextAlign.right
                : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusBadge(
    String text,
    String tipo,
  ) {
    Color bg;
    Color color;
    IconData icon;

    switch (tipo) {
      case 'pendiente':
        bg = const Color(0xFF3A2E07);
        color = const Color(0xFFEAB308);
        icon = Icons.circle;
        break;

      case 'solucionado':
        bg = const Color(0xFF064E3B);
        color = const Color(0xFF10B981);
        icon = Icons.check;
        break;

      case 'cancelado':
        bg = const Color(0xFF4C1D1D);
        color = const Color(0xFFF87171);
        icon = Icons.close;
        break;

      case 'proceso':
      default:
        bg = const Color(0xFF1E3A8A);
        color = const Color(0xFF3B82F6);
        icon = Icons.circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          fontWeight: FontWeight.bold,
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

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({
    super.key,
    this.activeRoute = 'Mis tickets',
  });

  static const String defaultAvatar =
      'assets/images/user.png';

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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const AppLogo(
              fontSize: 26,
            ),
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
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      defaultAvatar,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Administración',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              isActive: activeRoute == 'Inicio',
              onTap: () {
                if (activeRoute == 'Inicio') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const HomeScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon:
                  Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              isActive:
                  activeRoute == 'Mis tickets',
              onTap: () {
                if (activeRoute == 'Mis tickets') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MisticketsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              isActive:
                  activeRoute == 'Crear ticket',
              onTap: () {
                if (activeRoute == 'Crear ticket') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CrearticketsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Avisos',
              isActive: activeRoute == 'Avisos',
              onTap: () {
                if (activeRoute == 'Avisos') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AvisosScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              isActive: activeRoute == 'Mi perfil',
              onTap: () {
                if (activeRoute == 'Mi perfil') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MiPerfilScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              color: Colors.white70,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final Color itemColor =
        color ??
        (isActive ? Colors.white : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Material(
        color: isActive
            ? const Color(0xFF2563EB)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(
            icon,
            color: itemColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight:
                  isActive
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