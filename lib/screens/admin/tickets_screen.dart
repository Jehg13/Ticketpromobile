import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/admin/ticketsadmin_services.dart';
import '../../widgets/loading_screen.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../widgets/admin_notification_bell.dart';
import '../../widgets/admin_only_drawer_item.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'users_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final TicketsAdminServices _ticketsService = TicketsAdminServices();
  static const String defaultAvatar = 'assets/images/user.png';
  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  String selectedFilter = 'Todos';
  final _buscarController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  String? _archivoComentarioPath;
  String? _archivoComentarioNombre;
  Uint8List? _archivoComentarioBytes;
  List<TicketItem> tickets = [];
  bool _cargando = true;
  String? _error;
  int _pagina = 1;
  int _ultimaPagina = 1;
  int _total = 0;
  int _totalTickets = 0;
  int _pendientes = 0;
  int _enProceso = 0;
  int _solucionados = 0;
  int _cancelados = 0;
  final Set<int> _solucionesEnviadas = <int>{};
  final Map<int, Map<String, dynamic>> _solucionesLocales =
      <int, Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _cargarTickets({int pagina = 1}) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await _ticketsService.obtenerTickets(
        filtro: _filtroApi,
        buscar: _buscarController.text,
        pagina: pagina,
      );
      final raw = res['tickets'];
      final list = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => TicketItem.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : <TicketItem>[];
      final pag = res['pagination'];
      final stats = res['estadisticas'];
      if (!mounted) return;
      setState(() {
        tickets = list;
        _pagina = pag is Map ? _toInt(pag['current_page'], pagina) : pagina;
        _ultimaPagina = pag is Map ? _toInt(pag['last_page'], 1) : 1;
        _total = pag is Map ? _toInt(pag['total'], list.length) : list.length;
        _totalTickets = stats is Map ? _toInt(stats['total'], 0) : 0;
        _pendientes = stats is Map ? _toInt(stats['pendientes'], 0) : 0;
        _enProceso = stats is Map ? _toInt(stats['en_proceso'], 0) : 0;
        _solucionados = stats is Map ? _toInt(stats['solucionados'], 0) : 0;
        _cancelados = stats is Map ? _toInt(stats['cancelados'], 0) : 0;
        _cargando = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _error = e.toString().replaceFirst('Exception: ', '');
          tickets = [];
          _total = 0;
          _totalTickets = 0;
          _pendientes = 0;
          _enProceso = 0;
          _solucionados = 0;
          _cancelados = 0;
        });
      }
    }
  }

  String get _filtroApi =>
      {
        'Mis tickets': 'mis tickets',
        'Pendientes': 'pendiente',
        'En proceso': 'en proceso',
        'Solucionados': 'solucionado',
        'Cancelados': 'cancelado',
      }[selectedFilter] ??
      'todos';

  int _toInt(dynamic value, int fallback) =>
      int.tryParse(value?.toString() ?? '') ?? fallback;

  Future<void> _verDetalle(TicketItem ticket) async {
    Map<String, dynamic> detalle = _ticketAsMap(ticket);
    if (ticket.id != null) {
      try {
        final res = await _ticketsService.obtenerTicket(ticket.id!);
        final raw = res['ticket'];
        if (raw is Map) {
          detalle = Map<String, dynamic>.from(raw);
        }
      } catch (_) {
        // La información de la lista permite mostrar el detalle aunque falle la consulta.
      }
    }
    if (!mounted) return;
    await _mostrarDetalle(detalle, ticketItem: ticket);
  }

  Map<String, dynamic> _ticketAsMap(TicketItem ticket) {
    return {
      'id': ticket.id,
      'folio': ticket.folio,
      'titulo': ticket.title,
      'tipo_falla': ticket.type,
      'prioridad': ticket.priority,
      'estado': ticket.status,
      'descripcion': ticket.description,
      'created_at': '${ticket.date} ${ticket.time}',
      'tomado_por': ticket.assignedTo == 'Sin asignar'
          ? null
          : {
              'name': ticket.assignedTo,
              'departamento': ticket.assignedRole,
              'picture': ticket.assignedPhoto,
            },
    };
  }

  Future<void> _mostrarDetalle(
    Map<String, dynamic> ticket, {
    TicketItem? ticketItem,
  }) async {
    final String folio = _string(ticket['folio'], null, fallback: 'Sin folio');
    final String titulo = _string(
      ticket['titulo'],
      ticket['title'],
      fallback: 'Sin título',
    );
    final String descripcion = _string(
      ticket['descripcion'],
      ticket['description'],
      fallback: 'Sin descripción',
    );
    final String tipoFalla = _string(
      ticket['tipo_falla'],
      ticket['tipo'],
      fallback: 'No especificado',
    );
    final String prioridad = _string(
      ticket['prioridad'],
      ticket['priority'],
      fallback: 'No especificada',
    );
    final String estado = _string(
      ticket['estado'],
      ticket['status'],
      fallback: 'No especificado',
    );
    final String fechaCreacion = _formatearFecha(
      ticket['created_at'] ?? ticket['fecha'],
    );
    final String fechaTomado = _formatearFecha(
      ticket['fecha_tomado'] ?? ticket['taken_at'] ?? ticket['tomado_at'],
    );
    final dynamic uData =
        ticket['user'] ?? ticket['usuario'] ?? ticket['levantado_por'];
    final String departamento = _string(
      ticket['departamento'],
      ticket['departamento_nombre'] ??
          (uData is Map ? uData['departamento'] : null),
      fallback: 'No especificado',
    );
    final String oficina = _string(
      ticket['oficina'],
      (ticket['oficina_nombre'] ??
          (uData is Map
              ? (uData['departamento'] is Map
                    ? uData['departamento']['oficina']
                    : null)
              : null)),
      fallback: 'No especificada',
    );
    final String equipo = _string(
      ticket['equipo'],
      ticket['nombre_equipo'],
      fallback: 'No especificado',
    );
    final Map<String, dynamic>? usuario = uData is Map
        ? Map<String, dynamic>.from(uData)
        : null;
    final String nombreUsuario = _string(
      usuario?['name'],
      usuario?['nombre'],
      fallback: 'Usuario',
    );
    final String correoUsuario = _string(
      usuario?['email'],
      usuario?['correo'],
      fallback: 'Sin correo',
    );
    final String fotoUsuario = _string(
      usuario?['picture'],
      usuario?['foto'],
      fallback: '',
    );
    final dynamic tData =
        ticket['tomado_por'] ?? ticket['tecnico'] ?? ticket['assigned_to'];
    final Map<String, dynamic>? tomadoPor = tData is Map
        ? Map<String, dynamic>.from(tData)
        : null;
    final String nombreTecnico = _string(
      tomadoPor?['name'],
      tomadoPor?['nombre'],
      fallback: 'No especificado',
    );
    final String correoTecnico = _string(
      tomadoPor?['email'],
      tomadoPor?['correo'],
      fallback: 'Sin correo',
    );
    final String fotoTecnico = _string(
      tomadoPor?['picture'] ?? tomadoPor?['foto'] ?? tomadoPor?['foto_perfil'],
      null,
      fallback: '',
    );
    final List<Map<String, dynamic>> comentarios = _convertirMapas(
      ticket['historial_comentarios'] ?? ticket['comentarios'],
    );
    final List<Map<String, dynamic>> evidencias = _convertirArchivos(
      ticket['evidencia'] ?? ticket['evidencias'] ?? ticket['archivos'],
    );
    final String infoAdicional = _string(
      ticket['informacion_adicional'],
      ticket['informacion'],
      fallback: 'Sin información adicional',
    );
    if (!mounted) return;
    _mensajeController.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final Size size = MediaQuery.of(dialogContext).size;
        final bool desktop = size.width >= 800;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: desktop ? 40 : 12,
            vertical: 20,
          ),
          child: Container(
            width: desktop ? 900 : double.infinity,
            height: size.height * .90,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1021),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .45),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailHeader(
                  dialogContext,
                  folio,
                  prioridad,
                  estado,
                  fechaCreacion,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTicketSummary(
                          titulo,
                          tipoFalla,
                          departamento,
                          oficina,
                          equipo,
                          fechaCreacion,
                          fechaTomado,
                          nombreUsuario,
                          correoUsuario,
                          fotoUsuario,
                        ),
                        const SizedBox(height: 20),
                        _buildDescriptionSection(
                          'Descripción del problema',
                          descripcion,
                        ),
                        const SizedBox(height: 18),
                        _buildDescriptionSection(
                          'Información adicional',
                          infoAdicional,
                        ),
                        const SizedBox(height: 18),
                        _buildTechnicianSection(
                          nombreTecnico,
                          correoTecnico,
                          foto: fotoTecnico,
                        ),
                        const SizedBox(height: 18),
                        _buildEvidenceSection(
                          'Evidencia proporcionada',
                          evidencias,
                        ),
                        const SizedBox(height: 24),
                        StatefulBuilder(
                          builder: (context, setDialogState) {
                            bool enviandoComentario = false;
                            final int ticketId =
                                _toNullableInt(ticket['id']) ?? 0;
                            return _buildChatSection(
                              comentarios,
                              nombreUsuario,
                              fotoUsuario,
                              ticketId: ticketId,
                              enviando: enviandoComentario,
                              archivoNombre: _archivoComentarioNombre,
                              onAttach: () async {
                                final file = await FilePicker.pickFile();
                                if (file == null) return;
                                final bytes = await file.readAsBytes();
                                setDialogState(() {
                                  _archivoComentarioPath = file.path;
                                  _archivoComentarioNombre = file.name;
                                  _archivoComentarioBytes = bytes;
                                });
                              },
                              onSend: () async {
                                if (ticketId == 0) {
                                  _mostrarMensaje(
                                    'No se pudo identificar el ticket.',
                                  );
                                  return;
                                }
                                final String mensaje = _mensajeController.text
                                    .trim();
                                final bool tieneArchivo =
                                    (_archivoComentarioBytes != null &&
                                        _archivoComentarioBytes!.isNotEmpty) ||
                                    (_archivoComentarioPath != null &&
                                        _archivoComentarioPath!.isNotEmpty);
                                if (mensaje.isEmpty && !tieneArchivo) {
                                  _mostrarMensaje(
                                    'Escribe un mensaje antes de enviar.',
                                  );
                                  return;
                                }
                                setDialogState(() => enviandoComentario = true);
                                try {
                                  final respuesta = await _ticketsService
                                      .agregarComentario(
                                        ticketId: ticketId,
                                        mensaje: mensaje,
                                        archivoPath: _archivoComentarioPath,
                                        archivoBytes: _archivoComentarioBytes,
                                        archivoNombre: _archivoComentarioNombre,
                                      );
                                  final comentario = respuesta['comentario'];
                                  if (comentario is Map) {
                                    comentarios.add(
                                      Map<String, dynamic>.from(comentario),
                                    );
                                  }
                                  _mensajeController.clear();
                                  _archivoComentarioPath = null;
                                  _archivoComentarioNombre = null;
                                  _archivoComentarioBytes = null;
                                } catch (error) {
                                  _mostrarMensaje(
                                    'No se pudo enviar el mensaje: $error',
                                  );
                                } finally {
                                  setDialogState(
                                    () => enviandoComentario = false,
                                  );
                                }
                              },
                            );
                          },
                        ),
                        if (estado.toLowerCase().trim() == 'pendiente' &&
                            ticketItem != null) ...[
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await _tomarTicket(ticketItem);
                              },
                              icon: const Icon(Icons.front_hand_outlined),
                              label: const Text('Tomar ticket'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _firmaDataUrl(List<Offset> points) async {
    final size = const ui.Size(700, 260);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..strokeWidth = 3
      ..strokeCap = ui.StrokeCap.round;
    for (var index = 0; index < points.length - 1; index++) {
      if (points[index].isInfinite || points[index + 1].isInfinite) {
        continue;
      }
      canvas.drawLine(points[index], points[index + 1], paint);
    }
    final image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('No se pudo procesar la firma.');
    }
    return 'data:image/png;base64,${base64Encode(bytes.buffer.asUint8List())}';
  }

  Future<void> _mostrarSolucion(TicketItem ticket) async {
    Map<String, dynamic> detalle = _ticketAsMap(ticket);
    if (ticket.id != null) {
      try {
        final res = await _ticketsService.obtenerTicket(ticket.id!);
        final raw = res['ticket'];
        if (raw is Map) detalle = Map<String, dynamic>.from(raw);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo cargar la solución: $e')),
          );
        }

        return;
      }
    }
    if (!mounted) return;

    final dynamic solutionData = detalle['solucion'];
    final solution = solutionData is Map
        ? Map<String, dynamic>.from(solutionData)
        : <String, dynamic>{};
    final localSolution = ticket.id == null
        ? null
        : _solucionesLocales[ticket.id!];
    final dynamic userData =
        detalle['user'] ?? detalle['usuario'] ?? detalle['levantado_por'];
    final user = userData is Map ? Map<String, dynamic>.from(userData) : null;
    final dynamic technicianData =
        detalle['tomado_por'] ?? detalle['tecnico'] ?? detalle['assigned_to'];
    final technician = technicianData is Map
        ? Map<String, dynamic>.from(technicianData)
        : null;
    final String estado = _string(
      detalle['estado'],
      detalle['status'],
      fallback: ticket.status,
    );
    final String solucion = _string(
      localSolution?['solucion'] ?? solution['solucion'],
      detalle['solucion_aplicada'],
      fallback: 'No hay una solución registrada.',
    );
    final String nombreUsuario = _string(
      user?['name'],
      user?['nombre'] ?? detalle['levantado_por'],
      fallback: ticket.levantadoPor,
    );
    final String tomadoPor = _string(
      technician?['name'],
      technician?['nombre'],
      fallback: ticket.assignedTo,
    );
    final String correoTecnico = _string(
      technician?['email'],
      technician?['correo'],
      fallback: 'Sin correo',
    );
    final String fotoTecnico = _string(
      technician?['picture'] ??
          technician?['foto'] ??
          technician?['foto_perfil'],
      null,
      fallback: '',
    );
    final String conformidad = _string(
      solution['conformidad'],
      detalle['conformidad'] ?? detalle['usuario_conformidad'],
      fallback: 'Sin información registrada.',
    );
    final String fechaSolucion = _formatearFecha(
      solution['fecha_solucion'] ??
          detalle['fecha_solucion'] ??
          detalle['solucion_at'] ??
          detalle['resolved_at'],
    );
    final String fechaFirma = _formatearFecha(
      solution['fecha_firma'] ?? detalle['fecha_firma'],
    );
    final String firma = _string(
      solution['firma'] ?? solution['firma_url'] ?? solution['imagen_firma'],
      detalle['firma'] ?? detalle['firma_url'] ?? detalle['imagen_firma'],
      fallback: '',
    );
    final evidencias = localSolution?['evidencias'] is List
        ? _convertirMapas(localSolution!['evidencias'])
        : _convertirMapas(
            solution['evidencia'] ??
                detalle['evidencias_solucion'] ??
                detalle['solucion_evidencias'],
          );
    final bool puedeEditar =
        selectedFilter == 'Mis tickets' &&
        estado.toLowerCase().trim() == 'en proceso' &&
        (ticket.id == null || !_solucionesEnviadas.contains(ticket.id));
    final solucionController = TextEditingController(
      text: solucion == 'No hay una solución registrada.' ? '' : solucion,
    );
    final evidenciaController = TextEditingController();
    final archivosSolucion = <PlatformFile>[];
    final firmaPuntos = <Offset>[];
    final problemaSolucionado = ValueNotifier<bool>(true);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final desktop = size.width >= 800;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: desktop ? 40 : 12,
            vertical: 20,
          ),
          child: Container(
            width: desktop ? 850 : double.infinity,
            height: size.height * .90,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1021),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSolutionHeader(dialogContext, ticket),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSolutionIntro(ticket),
                        const SizedBox(height: 22),
                        _buildSolutionTicketInfo(ticket),
                        const SizedBox(height: 20),
                        _buildSolutionStatus(estado),
                        const SizedBox(height: 18),
                        puedeEditar
                            ? _buildEditableSolution(
                                solucionController,
                                evidenciaController,
                                archivosSolucion,
                                firmaPuntos,
                                problemaSolucionado,
                              )
                            : _buildRegisteredSolution(
                                'Solución aplicada',
                                solucion,
                              ),
                        const SizedBox(height: 20),
                        puedeEditar
                            ? const SizedBox.shrink()
                            : _buildEvidenceSection(
                                'Evidencias de la solución',
                                evidencias,
                              ),
                        const SizedBox(height: 20),
                        _buildRegisteredSolution(
                          '¿El problema fue solucionado?',
                          estado.toLowerCase().trim() == 'solucionado'
                              ? 'Sí, fue solucionado'
                              : 'No fue solucionado',
                        ),
                        const SizedBox(height: 20),
                        _buildRegisteredSolution(
                          'Fecha de solución',
                          fechaSolucion,
                        ),
                        const SizedBox(height: 20),
                        puedeEditar
                            ? _buildSignaturePad(firmaPuntos)
                            : _buildRegisteredSignature(
                                nombreUsuario: nombreUsuario,
                                conformidad: conformidad,
                                fechaFirma: fechaFirma,
                                firma: firma,
                              ),
                        const SizedBox(height: 20),
                        _buildTechnicianSection(
                          tomadoPor,
                          correoTecnico,
                          label: 'Tomado por',
                          foto: fotoTecnico,
                        ),
                        if (puedeEditar) ...[
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (solucionController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Escribe la solución aplicada.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (firmaPuntos.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Agrega la firma de conformidad.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final id = ticket.id;
                                if (id == null) return;
                                final messenger = ScaffoldMessenger.maybeOf(
                                  context,
                                );
                                final dialogNavigator = Navigator.of(
                                  dialogContext,
                                );
                                try {
                                  final String nombreFirmante =
                                      nombreUsuario.trim().isEmpty
                                      ? 'Usuario'
                                      : nombreUsuario;

                                  await _ticketsService.guardarSolucion(
                                    ticketId: id,
                                    solucion: solucionController.text.trim(),
                                    nombreFirmante: nombreFirmante,
                                    fechaSolucion: DateTime.now()
                                        .toIso8601String(),
                                    fechaFirma: DateTime.now()
                                        .toIso8601String(),
                                    firma: await _firmaDataUrl(firmaPuntos),
                                    problemaSolucionado:
                                        problemaSolucionado.value,
                                    evidencias: archivosSolucion,
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger?.showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                  return;
                                }
                                if (ticket.id != null) {
                                  _solucionesEnviadas.add(ticket.id!);
                                  _solucionesLocales[ticket.id!] = {
                                    'solucion': solucionController.text.trim(),
                                    'evidencias': archivosSolucion
                                        .map(
                                          (file) => {
                                            'nombre': file.name,
                                            'ruta': '',
                                          },
                                        )
                                        .toList(),
                                  };
                                }

                                if (!mounted) return;
                                dialogNavigator.pop();
                                if (mounted) setState(() {});
                                messenger?.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Solución guardada correctamente.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_rounded, size: 17),
                              label: const Text('Guardar solución'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    solucionController.dispose();
    evidenciaController.dispose();
    problemaSolucionado.dispose();
  }

  Widget _buildEditableSolution(
    TextEditingController solucionController,
    TextEditingController evidenciaController,
    List<PlatformFile> archivos,
    List<Offset> firmaPuntos,
    ValueNotifier<bool> problemaSolucionado,
  ) {
    return _solutionCard(
      title: 'Solución aplicada',
      icon: Icons.build_circle_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: solucionController,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _solutionInputDecoration(
              'Describe la solución aplicada...',
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: problemaSolucionado,
            builder: (context, solucionado, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿El problema fue solucionado?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _solutionChoice(
                  title: 'Sí, fue solucionado',
                  icon: Icons.check_circle_outline_rounded,
                  color: greenAccent,
                  selected: solucionado,
                  onTap: () => problemaSolucionado.value = true,
                ),
                const SizedBox(height: 8),
                _solutionChoice(
                  title: 'No fue solucionado',
                  icon: Icons.cancel_outlined,
                  color: Colors.redAccent,
                  selected: !solucionado,
                  onTap: () => problemaSolucionado.value = false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: evidenciaController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: _solutionInputDecoration(
              'Descripción opcional de la evidencia',
            ),
          ),
          const SizedBox(height: 10),
          StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.any,
                    );
                    setState(() => archivos.addAll(result));
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Subir evidencias'),
                ),
                if (archivos.isNotEmpty)
                  Text(
                    '${archivos.length} archivo(s) seleccionado(s)',
                    style: const TextStyle(color: textMuted, fontSize: 10),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _solutionChoice({
    required String title,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: .10)
              : const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color.withValues(alpha: .55) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected) Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturePad(List<Offset> points) {
    return _solutionCard(
      title: 'Firma de conformidad',
      icon: Icons.draw_outlined,
      iconColor: const Color(0xFFA78BFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 145,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26),
            ),
            child: StatefulBuilder(
              builder: (context, setSignatureState) => Listener(
                onPointerDown: (event) {
                  points.add(event.localPosition);
                  setSignatureState(() {});
                },
                onPointerMove: (event) {
                  points.add(event.localPosition);
                  setSignatureState(() {});
                },
                onPointerUp: (_) {
                  points.add(Offset.infinite);
                  setSignatureState(() {});
                },
                child: CustomPaint(
                  painter: _SignaturePainter(points),
                  child: const Center(
                    child: Text(
                      'Firma aquí',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: points.clear,
              child: const Text('Limpiar firma'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _solutionInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: textMuted, fontSize: 11),
    filled: true,
    fillColor: const Color(0xFF060A17),
    contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white10),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: accentBlue),
    ),
  );

  Widget _buildRegisteredSolution(String title, String value) {
    return _solutionCard(
      title: title,
      icon: title == 'Fecha de solución'
          ? Icons.calendar_month_outlined
          : Icons.build_circle_outlined,
      iconColor: title == 'Fecha de solución'
          ? const Color(0xFFA78BFA)
          : const Color(0xFF60A5FA),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredSignature({
    required String nombreUsuario,
    required String conformidad,
    required String fechaFirma,
    required String firma,
  }) {
    return _solutionCard(
      title: 'Conformidad del usuario',
      icon: Icons.verified_user_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información registrada al momento de cerrar el ticket.',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 18),
          _solutionDetailRow('Persona que levantó el ticket', nombreUsuario),
          _solutionDetailRow('Conformidad', conformidad),
          _solutionDetailRow(
            'Fecha de firma',
            fechaFirma == 'Sin fecha' ? 'Sin fecha registrada' : fechaFirma,
            last: firma.isEmpty,
          ),
          if (firma.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Firma',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(minHeight: 90, maxHeight: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(
                _buildFileUrl(firma),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Text(
                    'Firma registrada',
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolutionHeader(BuildContext context, TicketItem ticket) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1535),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_outlined,
            color: Color(0xFF34D399),
            size: 23,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solución del ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ticket.folio,
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionPanel(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF060A17),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white10),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
    ),
  );

  Widget _buildSolutionSection(String title, IconData icon, Widget child) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF60A5FA), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      );

  Widget _buildSolutionIntro(TicketItem ticket) => _buildSolutionPanel(
    'Completa la información de la solución y la firma de conformidad antes de dar de alta el ticket.',
  );

  Widget _buildSolutionTicketInfo(TicketItem ticket) => _buildSolutionSection(
    'Información del ticket',
    Icons.confirmation_number_outlined,
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111A35), Color(0xFF0D1427)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x403B82F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticket.folio,
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            ticket.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.handshake_outlined,
                color: Color(0xFF34D399),
                size: 17,
              ),
              const SizedBox(width: 7),
              const Text(
                'Tomado por',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ticket.assignedTo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildSolutionStatus(String status) => _buildSolutionSection(
    'Estado del ticket',
    Icons.info_outline,
    _buildSolutionPanel(status),
  );

  Widget _buildDetailHeader(
    BuildContext context,
    String folio,
    String prioridad,
    String estado,
    String fecha,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1535),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folio,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _priorityBadge(prioridad),
                    _statusBadge(_textoEstado(estado), _tipoEstado(estado)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        fecha,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSummary(
    String titulo,
    String tipoFalla,
    String departamento,
    String oficina,
    String equipo,
    String fechaCreacion,
    String fechaTomado,
    String nombreUsuario,
    String correoUsuario,
    String fotoUsuario,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: .16),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF60A5FA),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información del ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Datos principales y ubicación del reporte',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1226), Color(0xFF070C1B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF111A35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.subject_rounded,
                      color: Color(0xFF60A5FA),
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Título del ticket',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Detalles',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _summaryInfoTile(
                      Icons.warning_amber_rounded,
                      'Tipo de falla',
                      tipoFalla,
                    ),
                    _summaryInfoTile(
                      Icons.business_outlined,
                      'Departamento',
                      departamento,
                    ),
                    _summaryInfoTile(
                      Icons.location_on_outlined,
                      'Oficina',
                      oficina,
                    ),
                    _summaryInfoTile(
                      Icons.devices_other_outlined,
                      'Equipo',
                      equipo,
                    ),
                    _summaryInfoTile(
                      Icons.calendar_today_outlined,
                      'Levantado',
                      fechaCreacion,
                    ),
                    _summaryInfoTile(
                      Icons.handshake_outlined,
                      'Tomado',
                      fechaTomado == 'Sin fecha'
                          ? 'Aún sin tomar'
                          : fechaTomado,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 14),
              const Text(
                'Levantado por',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildProfileImage(fotoUsuario, radius: 25),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          correoUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
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
        ),
      ],
    );
  }

  Widget _summaryInfoTile(IconData icon, String label, String value) {
    return SizedBox(
      width: 245,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101A31),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF334155).withValues(alpha: .45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF93C5FD), size: 16),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF060A17),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianSection(
    String nombre,
    String correo, {
    String label = 'Técnico',
    String foto = '',
  }) {
    return _solutionCard(
      title: 'Técnico asignado',
      icon: Icons.support_agent_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileImage(foto, radius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _solutionDetailRow(label, nombre),
          _solutionDetailRow('Correo', correo, last: true),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection(
    String titulo,
    List<Map<String, dynamic>> evidencias,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        evidencias.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF060A17),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: Colors.grey,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'No se proporcionaron archivos.',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: evidencias.map(_buildFileItem).toList(),
              ),
      ],
    );
  }

  Widget _buildFileItem(Map<String, dynamic> archivo) {
    final String nombre = _string(
      archivo['nombre'],
      archivo['name'] ?? archivo['archivo'],
      fallback: 'Archivo',
    );
    final String ruta = _string(
      archivo['ruta'],
      archivo['path'] ?? archivo['url'] ?? archivo['archivo'],
      fallback: '',
    );
    return InkWell(
      onTap: ruta.isEmpty ? null : () => _abrirArchivo(ruta),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ruta.isEmpty ? Colors.white10 : const Color(0x403B82F6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: .18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insert_drive_file_outlined,
                color: Color(0xFF60A5FA),
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ruta.isEmpty ? 'Archivo no disponible' : 'Abrir archivo',
                    style: TextStyle(
                      color: ruta.isEmpty
                          ? Colors.grey
                          : const Color(0xFF60A5FA),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (ruta.isNotEmpty)
              const Icon(
                Icons.open_in_new_rounded,
                color: Color(0xFF60A5FA),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection(
    List<Map<String, dynamic>> comentarios,
    String nombreUsuario,
    String fotoUsuario, {
    required int ticketId,
    required Future<void> Function() onSend,
    required bool enviando,
    required VoidCallback onAttach,
    String? archivoNombre,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.forum_outlined, color: Color(0xFF60A5FA), size: 19),
            SizedBox(width: 8),
            Text(
              'Conversación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF060A17),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 360,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: comentarios.isEmpty
                      ? _buildEmptyChat()
                      : ListView.separated(
                          itemCount: comentarios.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildChatMessage(
                            comentarios[index],
                            nombreUsuario,
                            fotoUsuario,
                          ),
                        ),
                ),
              ),
              _buildChatComposer(
                ticketId: ticketId,
                onSend: onSend,
                enviando: enviando,
                onAttach: onAttach,
                archivoNombre: archivoNombre,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF0F1535),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay mensajes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Inicia una conversación con soporte.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(
    Map<String, dynamic> comentario,
    String nombreUsuario,
    String fotoUsuario,
  ) {
    final dynamic uData = comentario['usuario'] ?? comentario['user'];
    final Map<String, dynamic>? usuario = uData is Map
        ? Map<String, dynamic>.from(uData)
        : null;
    final String nombre = _string(
      usuario?['name'],
      usuario?['nombre'],
      fallback: nombreUsuario,
    );
    final String rol = _string(
      usuario?['role'],
      usuario?['rol'],
      fallback: 'Usuario',
    );
    final String foto = _string(
      usuario?['picture'],
      usuario?['foto'],
      fallback: fotoUsuario,
    );
    final String mensaje = _string(
      comentario['mensaje'],
      comentario['message'],
      fallback: '',
    );
    final String archivo = _string(
      comentario['archivo'],
      comentario['file'],
      fallback: '',
    );
    final String fecha = _formatearFecha(comentario['created_at']);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(foto, radius: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        rol,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (mensaje.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxWidth: 650),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1535),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mensaje,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              if (archivo.isNotEmpty) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _abrirArchivo(archivo),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1535),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x403B82F6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.attach_file_rounded,
                          color: Color(0xFF60A5FA),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            archivo.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.open_in_new_rounded,
                          color: Color(0xFF60A5FA),
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                fecha,
                style: const TextStyle(color: Colors.grey, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatComposer({
    required int ticketId,
    required Future<void> Function() onSend,
    required bool enviando,
    required VoidCallback onAttach,
    String? archivoNombre,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: enviando ? null : onAttach,
            icon: const Icon(
              Icons.attach_file_rounded,
              color: Colors.grey,
              size: 20,
            ),
            tooltip: 'Adjuntar archivo',
          ),
          if (archivoNombre != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, right: 6),
                child: Text(
                  archivoNombre,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: _mensajeController,
              enabled: !enviando,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0B1021),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enviando ? Colors.white10 : const Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: enviando || ticketId == 0
                  ? null
                  : () async => onSend(),
              icon: enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
              tooltip: enviando ? 'Enviando...' : 'Enviar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String path, {double radius = 20}) {
    final String cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage(defaultAvatar),
      );
    }
    final String imageUrl = ApiService.profileImageUrl(cleanPath);
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF1E293B),
      child: ClipOval(
        child: Image.network(
          '$imageUrl?profile_refresh=${cleanPath.hashCode}',
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Image.asset(
            defaultAvatar,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _priorityBadge(String prioridad) {
    final String valor = prioridad.toLowerCase().trim();
    Color color;
    Color background;
    switch (valor) {
      case 'critica':
      case 'crítica':
        color = const Color(0xFFF87171);
        background = const Color(0xFF4C1D1D);
        break;
      case 'alta':
        color = const Color(0xFFF97316);
        background = const Color(0xFF431407);
        break;
      case 'media':
        color = const Color(0xFFEAB308);
        background = const Color(0xFF3A2E07);
        break;
      default:
        color = const Color(0xFF60A5FA);
        background = const Color(0xFF1E3A8A);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        prioridad,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusBadge(String text, String tipo) {
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
      default:
        bg = const Color(0xFF1E3A8A);
        color = const Color(0xFF3B82F6);
        icon = Icons.circle;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _solutionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1427),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _solutionDetailRow(String label, String value, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildFileUrl(String ruta) {
    String url = ruta.trim();
    if (url.isEmpty) {
      return '';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    url = url.replaceFirst(RegExp(r'^/+'), '');
    if (url.startsWith('storage/')) {
      url = url.substring('storage/'.length);
    }
    if (url.startsWith('api/')) {
      url = url.substring('api/'.length);
    }
    return '${ApiService.serverUrl}/archivo/$url';
  }

  Future<void> _abrirArchivo(String ruta) async {
    final String url = _buildFileUrl(ruta);
    if (url.isEmpty) {
      _mostrarMensaje('No se encontró la ruta del archivo.');
      return;
    }
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      _mostrarMensaje('La dirección del archivo no es válida.');
      return;
    }
    try {
      final bool abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir el archivo.');
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir el archivo.');
      }
    }
  }

  List<Map<String, dynamic>> _convertirArchivos(dynamic data) {
    if (data is! List) return <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> resultado = [];
    for (final dynamic archivo in data) {
      if (archivo is Map) {
        final Map<String, dynamic> mapa = Map<String, dynamic>.from(archivo);
        final String ruta = _string(
          mapa['ruta'],
          mapa['path'] ?? mapa['url'] ?? mapa['archivo'] ?? mapa['file'],
          fallback: '',
        );
        final String nombre = _string(
          mapa['nombre'],
          mapa['name'] ?? mapa['archivo'],
          fallback: ruta.isNotEmpty ? ruta.split('/').last : 'Archivo',
        );
        mapa['nombre'] = nombre;
        mapa['ruta'] = ruta;
        resultado.add(mapa);
      } else {
        final String ruta = archivo.toString();
        resultado.add({'nombre': ruta.split('/').last, 'ruta': ruta});
      }
    }
    return resultado;
  }

  List<Map<String, dynamic>> _convertirMapas(dynamic data) {
    if (data is! List) return <Map<String, dynamic>>[];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _string(dynamic value, dynamic secondValue, {String fallback = ''}) {
    String normalize(dynamic item) {
      if (item is Map) {
        return normalize(
          item['nombre'] ??
              item['name'] ??
              item['razon_social'] ??
              item['descripcion'] ??
              item['value'],
        );
      }
      if (item is List) {
        return item.map(normalize).where((text) => text.isNotEmpty).join(', ');
      }
      return item?.toString().trim() ?? '';
    }

    final first = normalize(value);
    if (first.isNotEmpty) return first;
    final second = normalize(secondValue);
    if (second.isNotEmpty) return second;
    return fallback;
  }

  int? _toNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value != null) return int.tryParse(value.toString().trim());
    return null;
  }

  String _formatearFecha(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return 'Sin fecha';
    final DateTime? fecha = DateTime.tryParse(value.toString());
    if (fecha == null) return value.toString();
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String anio = fecha.year.toString();
    final String hora = fecha.hour.toString().padLeft(2, '0');
    final String minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

  String _textoEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'pendiente':
        return 'Pendiente';
      case 'en proceso':
      case 'en_proceso':
      case 'proceso':
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
      default:
        return 'proceso';
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  void _mostrarSuccess(String mensaje) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
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
                    color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF22C55E),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Éxito',
                  style: TextStyle(
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
                      backgroundColor: const Color(0xFF22C55E),
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

  @override
  Widget build(BuildContext context) {
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
          const AdminNotificationBell(),
          const SizedBox(width: 8),
          const AdminProfileMenu(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(activeMenu: 'Tickets'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tickets',
              style: TextStyle(
                color: textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta y da seguimiento a todos los tickets que se han creado',
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  KPIStatCard(
                    title: 'Total de tickets',
                    count: _totalTickets.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.confirmation_number_outlined,
                    iconColor: accentBlue,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Pendientes',
                    count: _pendientes.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.access_time_rounded,
                    iconColor: Colors.amber,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'En proceso',
                    count: _enProceso.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.sync,
                    iconColor: cyanAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Solucionados',
                    count: _solucionados.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.check_circle_outline,
                    iconColor: greenAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cancelados',
                    count: _cancelados.toString(),
                    subtitle: 'Este mes',
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.redAccent,
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
                  _buildFilterChip('Mis tickets'),
                  _buildFilterChip('Pendientes'),
                  _buildFilterChip('En proceso'),
                  _buildFilterChip('Solucionados'),
                  _buildFilterChip('Cancelados'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: textMuted, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _buscarController,
                            onSubmitted: (_) => _cargarTickets(),
                            style: TextStyle(color: textWhite, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: textMuted,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Este mes',
                        style: TextStyle(color: textWhite, fontSize: 12),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            else if (tickets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      color: textMuted,
                      size: 42,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay tickets',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No se encontraron tickets para este filtro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return TicketCard(
                    ticket: ticket,
                    onView: () => _verDetalle(ticket),
                    onTake: _accionTicket(ticket),
                  );
                },
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    'Mostrando ${tickets.isEmpty ? 0 : ((_pagina - 1) * tickets.length + 1)} a ${((_pagina - 1) * tickets.length + tickets.length)} de $_total tickets',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pagina > 1
                            ? () => _cargarTickets(pagina: _pagina - 1)
                            : null,
                        child: _buildPageBtn(
                          icon: Icons.chevron_left,
                          disabled: _pagina <= 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildPageBtn(text: '$_pagina', selected: true),
                      const SizedBox(width: 6),
                      if (_pagina < _ultimaPagina)
                        GestureDetector(
                          onTap: () => _cargarTickets(pagina: _pagina + 1),
                          child: _buildPageBtn(text: '${_pagina + 1}'),
                        ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _pagina < _ultimaPagina
                            ? () => _cargarTickets(pagina: _pagina + 1)
                            : null,
                        child: _buildPageBtn(
                          icon: Icons.chevron_right,
                          disabled: _pagina >= _ultimaPagina,
                        ),
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
    );
  }

  VoidCallback? _accionTicket(TicketItem ticket) {
    final estado = ticket.status.toLowerCase().trim();
    if (estado == 'en proceso' && selectedFilter != 'Mis tickets') return null;
    if (selectedFilter == 'Mis tickets' && estado == 'en proceso') {
      return () => _mostrarSolucion(ticket);
    }
    if (estado == 'solucionado' || estado == 'cancelado') {
      return () => _mostrarSolucion(ticket);
    }
    return () => _tomarTicket(ticket);
  }

  Future<void> _tomarTicket(TicketItem ticket) async {
    if (ticket.id == null) return;
    try {
      await _ticketsService.tomarTicket(ticket.id!);
      if (!mounted) return;
      _mostrarSuccess('Ticket tomado correctamente.');
      _cargarTickets(pagina: _pagina);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          _pagina = 1;
        });
        _cargarTickets();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryBlue : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textWhite : textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPageBtn({
    String? text,
    IconData? icon,
    bool selected = false,
    bool disabled = false,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? primaryBlue
            : (disabled ? Colors.white.withValues(alpha: 0.02) : cardBg),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: selected ? primaryBlue : Colors.white10),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: disabled ? Colors.white24 : textWhite, size: 18)
            : Text(
                text!,
                style: TextStyle(
                  color: selected ? textWhite : textMuted,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < points.length - 1; index++) {
      if (points[index].isInfinite || points[index + 1].isInfinite) continue;
      canvas.drawLine(points[index], points[index + 1], paint);
    }
    final guidePaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(20, size.height - 22),
      Offset(size.width - 20, size.height - 22),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class TicketItem {
  final int? id;
  final String folio;
  final String title;
  final String type;
  final String priority;
  final String status;
  final String assignedTo;
  final String assignedRole;
  final String assignedPhoto;
  final String date;
  final String time;
  final String description;
  final String levantadoPor;

  TicketItem({
    this.id,
    required this.folio,
    required this.title,
    required this.type,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.assignedRole,
    this.assignedPhoto = '',
    required this.date,
    required this.time,
    this.description = '',
    this.levantadoPor = 'Usuario',
  });

  factory TicketItem.fromMap(Map<String, dynamic> map) {
    String textValue(dynamic value, {String fallback = ''}) {
      if (value is List) {
        return value
            .where((item) => item != null)
            .map((item) => textValue(item))
            .where((item) => item.isNotEmpty)
            .join(', ');
      }
      if (value is Map) {
        return textValue(
          value['name'] ??
              value['nombre'] ??
              value['title'] ??
              value['descripcion'] ??
              value['value'],
          fallback: fallback,
        );
      }
      return value?.toString() ?? fallback;
    }

    final assigned = map['tomado_por'] ?? map['tecnico'] ?? map['assigned_to'];
    final assignedMap = assigned is Map
        ? Map<String, dynamic>.from(assigned)
        : null;
    final requester = map['user'] ?? map['usuario'] ?? map['levantado_por'];
    final requesterMap = requester is Map
        ? Map<String, dynamic>.from(requester)
        : null;
    final date = DateTime.tryParse(map['created_at']?.toString() ?? '');
    final dynamic department = assignedMap?['departamento'];
    final String departmentText = textValue(department);
    final dynamic requesterName =
        requesterMap?['name'] ?? requesterMap?['nombre'] ?? requester;
    final String requesterText = textValue(requesterName, fallback: 'Usuario');
    final dynamic assignedName = assignedMap?['name'] ?? assignedMap?['nombre'];
    final String assignedText = textValue(
      assignedName,
      fallback: 'Sin asignar',
    );
    final String assignedPhoto = textValue(
      assignedMap?['picture'] ??
          assignedMap?['foto'] ??
          assignedMap?['foto_perfil'],
    );
    return TicketItem(
      id: int.tryParse((map['id'] ?? '').toString()),
      folio: textValue(map['folio'], fallback: 'Sin folio'),
      title: textValue(map['titulo'] ?? map['title'], fallback: 'Sin título'),
      type: textValue(
        map['tipo_falla'] ?? map['tipo'],
        fallback: 'No especificado',
      ),
      priority: textValue(map['prioridad'], fallback: 'No especificada'),
      status: textValue(map['estado'], fallback: 'No especificado'),
      assignedTo: assignedText,
      assignedRole: departmentText,
      assignedPhoto: assignedPhoto,
      date: date == null
          ? 'Sin fecha'
          : '${date.day}/${date.month}/${date.year}',
      time: date == null
          ? ''
          : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      description: textValue(map['descripcion']),
      levantadoPor: requesterText,
    );
  }
}

class TicketCard extends StatelessWidget {
  final TicketItem ticket;
  final VoidCallback? onView;
  final VoidCallback? onTake;

  const TicketCard({super.key, required this.ticket, this.onView, this.onTake});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 11, 10, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF172554), Color(0xFF111827)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x403B82F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          color: Color(0xFF60A5FA),
                          size: 16,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            ticket.folio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFBFDBFE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildPriorityBadge(ticket.priority),
                        const SizedBox(width: 5),
                        _buildStatusBadge(ticket.status),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      ticket.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Icon(Icons.memory, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: compact ? constraints.maxWidth - 36 : 220,
                    ),
                    child: Text(
                      ticket.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${ticket.date} • ${ticket.time}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _assignedPhoto(),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (ticket.assignedRole.isNotEmpty)
                                Text(
                                  ticket.assignedRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onView,
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
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onTake,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.front_hand_outlined,
                            color: onTake == null
                                ? Colors.white24
                                : const Color(0xFF10B981),
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color bg = Colors.red.withValues(alpha: 0.15);
    Color text = Colors.redAccent;
    IconData icon = Icons.error_outline;

    if (priority == 'Media') {
      bg = Colors.amber.withValues(alpha: 0.15);
      text = Colors.amber;
      icon = Icons.keyboard_arrow_up;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 11),
          const SizedBox(width: 3),
          Text(
            priority,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.amber.withValues(alpha: 0.15);
    Color text = Colors.amber;
    String prefix = '• ';
    final normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus == 'solucionado') {
      bg = const Color(0xFF10B981).withValues(alpha: 0.15);
      text = const Color(0xFF10B981);
      prefix = '✓ ';
    } else if (normalizedStatus == 'cancelado') {
      bg = Colors.red.withValues(alpha: 0.15);
      text = Colors.redAccent;
      prefix = '✕ ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$prefix$status',
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _assignedPhoto() {
    final path = ticket.assignedPhoto.trim();
    if (path.isEmpty) {
      return const CircleAvatar(
        radius: 10,
        backgroundColor: Color(0xFF3B82F6),
        child: Text('US', style: TextStyle(color: Colors.white, fontSize: 8)),
      );
    }

    final imageUrl = ApiService.profileImageUrl(path);
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 20,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
          radius: 10,
          backgroundColor: Color(0xFF3B82F6),
          child: Text('US', style: TextStyle(color: Colors.white, fontSize: 8)),
        ),
      ),
    );
  }
}

class KPIStatCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const KPIStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      padding: const EdgeInsets.all(10),
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
            children: [
              Icon(icon, color: iconColor, size: 15),
              const SizedBox(width: 4),
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
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
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
      backgroundColor: const Color(0xFF0D1630),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0D1630)),
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
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>?>(
                  future: SessionService.getUser(),
                  builder: (context, snapshot) {
                    final user = snapshot.data ?? {};
                    final name = (user['name'] ?? 'Administrador').toString();

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const TicketsAdminAvatar(radius: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'Administrador',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const AdminDrawerRole(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard_rounded,
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
            },
          ),
          AdminOnlyDrawerItem(
            child: _drawerItem(
              context,
              Icons.published_with_changes_rounded,
              'Cambios',
              selected: activeMenu == 'Cambios',
              onTap: () {
                Navigator.pop(context);
                navigateWithLoading(
                  context,
                  const CambiosScreen(),
                  mensaje: 'Cargando cambios...',
                );
              },
            ),
          ),
          AdminOnlyDrawerItem(
            child: _drawerItem(
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
            Icons.logout,
            'Cerrar sesión',
            isExit: true,
            onTap: () {
              Navigator.pop(context);
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isExit
                ? Colors.redAccent
                : (selected ? Colors.white : const Color(0xFF94A3B8)),
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isExit
                  ? Colors.redAccent
                  : (selected ? Colors.white : const Color(0xFF94A3B8)),
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

class TicketsAdminAvatar extends StatelessWidget {
  const TicketsAdminAvatar({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadPicture(),
      builder: (context, snapshot) {
        final picture = snapshot.data?.trim() ?? '';
        final isDefault = SessionService.isDefaultProfilePicture(picture);
        final imageUrl = isDefault ? '' : ApiService.profileImageUrl(picture);

        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF4F46E5),
          child: ClipOval(
            child: !isDefault && imageUrl.isNotEmpty
                ? Image.network(
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
                  )
                : Image.asset(
                    'assets/images/user.png',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }

  Future<String?> _loadPicture() async {
    final response = await ApiService.getUser();
    if (response['success'] == true && response['user'] is Map) {
      final user = response['user'] as Map;
      return (user['picture'] ?? user['foto'] ?? user['foto_perfil'])
          ?.toString()
          .trim();
    }
    return SessionService.getPicture();
  }
}
