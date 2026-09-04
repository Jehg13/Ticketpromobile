import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../services/mistickets_usuario_service.dart';
import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
import 'avisos_screen.dart';
import 'creartickets_screen.dart';
import 'home_screen.dart' as home;
import 'perfil_screen.dart';

class MisticketsScreen extends StatefulWidget {
  const MisticketsScreen({super.key});
  @override
  State<MisticketsScreen> createState() => _MisticketsScreenState();
}

class _MisticketsScreenState extends State<MisticketsScreen> {
  static const String defaultAvatar = 'assets/images/user.png';
  final TextEditingController _buscarController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  String? _archivoComentarioPath;
  String? _archivoComentarioNombre;
  Uint8List? _archivoComentarioBytes;
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
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _cargarTickets({int pagina = 1}) async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final Map<String, dynamic> res =
          await MisTicketsUsuarioService.obtenerTickets(
            buscar: _buscarController.text.trim(),
            estado: _estadoSeleccionado,
            pagina: pagina,
          );
      if (!mounted) return;
      final dynamic ticketsData = res['tickets'];
      final List<Map<String, dynamic>> tickets = ticketsData is List
          ? ticketsData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];
      final dynamic pag = res['pagination'];
      int pAct = pagina;
      int pUlt = 1;
      int tot = tickets.length;
      if (pag is Map) {
        pAct = _toInt(pag['current_page'], pagina);
        pUlt = _toInt(pag['last_page'], 1);
        tot = _toInt(pag['total'], tickets.length);
      }
      setState(() {
        _tickets = tickets;
        _paginaActual = pAct;
        _ultimaPagina = pUlt;
        _totalTickets = tot;
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

  Future<void> _verDetalle(Map<String, dynamic> ticket) async {
    final int? id = _toNullableInt(ticket['id']);
    if (id == null) {
      _mostrarMensaje('No se pudo identificar el ticket.');
      return;
    }
    if (!mounted) return;
    setState(() => _cargandoDetalle = true);
    try {
      final Map<String, dynamic> res =
          await MisTicketsUsuarioService.obtenerTicket(id);
      if (!mounted) return;
      final dynamic tData = res['ticket'];
      if (tData is! Map) {
        throw Exception('La información del ticket no es válida.');
      }
      final Map<String, dynamic> detalle = Map<String, dynamic>.from(tData);
      setState(() => _cargandoDetalle = false);
      await _mostrarDetalle(detalle);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoDetalle = false);
      _mostrarMensaje(_limpiarError(e));
    }
  }

  Future<void> _mostrarDetalle(Map<String, dynamic> ticket) async {
    final String folio = _string(ticket['folio'], null, fallback: 'Sin folio');
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
    final String fechaCreacion = _formatearFecha(ticket['created_at']);
    final String fechaTomado = _formatearFecha(
      ticket['fecha_tomado'] ?? ticket['taken_at'] ?? ticket['tomado_at'],
    );
    final String departamento = _string(
      ticket['departamento'],
      ticket['departamento_nombre'],
      fallback: 'No especificado',
    );
    final String oficina = _string(
      ticket['oficina'],
      ticket['oficina_nombre'],
      fallback: 'No especificada',
    );
    final String equipo = _string(
      ticket['equipo'],
      ticket['nombre_equipo'],
      fallback: 'No especificado',
    );
    final bool problemaSolucionado = _esProblemaSolucionado(
      ticket['problema_solucionado'] ?? ticket['solucionado'],
    );
    final String nombreFirmante = _string(
      ticket['nombre_firmante'],
      null,
      fallback: 'No especificado',
    );
    final String fechaFirma = _formatearFecha(
      ticket['fecha_firma'],
    );
    final dynamic uData =
        ticket['user'] ?? ticket['usuario'] ?? ticket['levantado_por'];
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
    final dynamic tData = ticket['tomado_por'] ?? ticket['tecnico'];
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
                        _buildTechnicianSection(nombreTecnico, correoTecnico),
                        const SizedBox(height: 18),
                        _buildTicketClosureSummary(
                          problemaSolucionado,
                          nombreFirmante,
                          fechaFirma,
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
                                if (mensaje.isEmpty &&
                                    (_archivoComentarioBytes == null ||
                                        _archivoComentarioBytes!.isEmpty) &&
                                    (_archivoComentarioPath == null ||
                                        _archivoComentarioPath!.isEmpty)) {
                                  _mostrarMensaje(
                                    'Escribe un mensaje antes de enviar.',
                                  );
                                  return;
                                }
                                setDialogState(() => enviandoComentario = true);
                                try {
                                  final Map<String, dynamic> res =
                                      await MisTicketsUsuarioService.agregarComentario(
                                        ticketId: ticketId,
                                        mensaje: mensaje,
                                        archivoPath:
                                            _archivoComentarioBytes == null
                                            ? _archivoComentarioPath
                                            : null,
                                        archivoBytes: _archivoComentarioBytes,
                                        archivoNombre: _archivoComentarioNombre,
                                      );
                                  final dynamic comentario = res['comentario'];
                                  if (comentario is Map) {
                                    setDialogState(() {
                                      comentarios.add(
                                        Map<String, dynamic>.from(comentario),
                                      );
                                    });
                                  }
                                  _mensajeController.clear();
                                  _archivoComentarioPath = null;
                                  _archivoComentarioNombre = null;
                                  _archivoComentarioBytes = null;
                                } catch (e) {
                                  _mostrarMensaje(_limpiarError(e));
                                } finally {
                                  setDialogState(
                                    () => enviandoComentario = false,
                                  );
                                }
                              },
                            );
                          },
                        ),
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
    final List<Widget> infoTiles = <Widget>[
      _summaryInfoTile(
        Icons.warning_amber_rounded,
        'Tipo de falla',
        tipoFalla,
      ),
      if (departamento.isNotEmpty && !departamento.toLowerCase().contains('no especificado'))
        _summaryInfoTile(
          Icons.business_outlined,
          'Departamento',
          departamento,
        ),
      if (oficina.isNotEmpty && !oficina.toLowerCase().contains('no especificada'))
        _summaryInfoTile(
          Icons.location_on_outlined,
          'Oficina',
          oficina,
        ),
      if (equipo.isNotEmpty && !equipo.toLowerCase().contains('no especificado'))
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
        fechaTomado == 'Sin fecha' ? 'Aún sin tomar' : fechaTomado,
      ),
    ];

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
                  children: infoTiles,
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

  Widget _buildTechnicianSection(String nombre, String correo) {
    return _solutionCard(
      title: 'Técnico asignado',
      icon: Icons.support_agent_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Column(
        children: [
          _solutionDetailRow('Técnico', nombre),
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

  Widget _buildSignatureImage(String path) {
    final String cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.draw_outlined, color: Colors.grey, size: 42),
            SizedBox(height: 10),
            Text(
              'No se registró una imagen de firma.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      );
    }
    final String imageUrl = ApiService.firmaUrl(cleanPath);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180, maxHeight: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x403B82F6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isEmpty
            ? const Center(
                child: Text(
                  'Este ticket no tiene firma.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFFF87171),
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No se pudo cargar la imagen de la firma.',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        imageUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  );
                },
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
            style: const TextStyle(color: Colors.white, fontSize: 12),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _cargarTickets(pagina: 1),
            decoration: InputDecoration(
              hintText: 'Buscar folio, título o fecha...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.grey,
                size: 18,
              ),
              suffixIcon: _buscarController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 17,
                      ),
                      onPressed: () {
                        _buscarController.clear();
                        setState(() {});
                        _cargarTickets(pagina: 1);
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF060A17),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
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
          style: const TextStyle(color: Colors.white, fontSize: 11),
          items: const [
            DropdownMenuItem(value: 'todos', child: Text('Todos')),
            DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
            DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
            DropdownMenuItem(value: 'solucionado', child: Text('Solucionados')),
            DropdownMenuItem(value: 'cancelado', child: Text('Cancelados')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _estadoSeleccionado = value);
            _cargarTickets(pagina: 1);
          },
        ),
      ),
    );
  }

  Widget _buildTicketsList(bool isDesktop) {
    if (_error != null) return _buildError();
    if (_tickets.isEmpty) return _buildEmptyState();
    if (!isDesktop) {
      return Column(
        children: _tickets
            .map((ticket) => _buildMobileTicketItem(ticket))
            .toList(),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1050,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(3.0),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.2),
          },
          children: [_tableHeaderRow(), ..._tickets.map(_tableTicketRow)],
        ),
      ),
    );
  }

  TableRow _tableHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      children: [
        _tableHeaderCell('Folio'),
        _tableHeaderCell('Título del ticket'),
        _tableHeaderCell('Estado'),
        _tableHeaderCell('Fecha de creación'),
        _tableHeaderCell('Acciones', alignRight: true),
      ],
    );
  }

  TableRow _tableTicketRow(Map<String, dynamic> ticket) {
    final String estado = _string(
      ticket['estado'],
      null,
      fallback: 'Pendiente',
    );
    final bool habilitadoSolucion = _puedeVerSolucion(ticket);
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              _string(ticket['folio'], null, fallback: 'Sin folio'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _string(ticket['titulo'], null, fallback: 'Sin título'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _string(
                    ticket['descripcion'],
                    null,
                    fallback: 'Sin descripción',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(_textoEstado(estado), _tipoEstado(estado)),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              _formatearFecha(ticket['created_at']),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(
                  icon: Icons.visibility_outlined,
                  color: Colors.grey,
                  tooltip: 'Ver detalle',
                  onPressed: _cargandoDetalle
                      ? null
                      : () => _verDetalle(ticket),
                ),
                const SizedBox(width: 4),
                _buildActionIcon(
                  icon: Icons.handshake_outlined,
                  color: const Color(0xFF34D399),
                  tooltip: habilitadoSolucion
                      ? 'Ver solución'
                      : 'Disponible al solucionar o cancelar',
                  onPressed: (_cargandoDetalle || !habilitadoSolucion)
                      ? null
                      : () => _mostrarSolucion(ticket),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (onPressed == null ? Colors.white10 : color).withValues(
            alpha: .08,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (onPressed == null ? Colors.white10 : color).withValues(
              alpha: .12,
            ),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 17,
            color: onPressed == null ? Colors.white24 : color,
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildMobileTicketItem(Map<String, dynamic> ticket) {
    final String estado = _string(
      ticket['estado'],
      null,
      fallback: 'Pendiente',
    );
    final String prioridad = _string(
      ticket['prioridad'],
      ticket['priority'],
      fallback: 'Sin prioridad',
    );
    final bool habilitadoSolucion = _puedeVerSolucion(ticket);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121B31), Color(0xFF0C1324)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _estadoStripeColor(estado),
                  _estadoStripeColor(estado).withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF93C5FD).withValues(alpha: .18)),
                        ),
                        child: Text(
                          _string(ticket['folio'], null, fallback: 'Sin folio'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFDBEAFE),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(_textoEstado(estado), _tipoEstado(estado)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _string(ticket['titulo'], null, fallback: 'Sin título'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _string(ticket['descripcion'], null, fallback: 'Sin descripción'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.45),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1324),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF93C5FD)),
                          const SizedBox(width: 5),
                          Text(
                            _formatearFecha(ticket['created_at']),
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    _priorityBadge(prioridad),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1324),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: .04)),
                        ),
                        child: Text(
                          'Revisa y gestiona este ticket',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildMobileActionIcon(
                      icon: Icons.visibility_outlined,
                      color: Colors.grey,
                      tooltip: 'Ver ticket',
                      onPressed: _cargandoDetalle ? null : () => _verDetalle(ticket),
                    ),
                    const SizedBox(width: 6),
                    _buildMobileActionIcon(
                      icon: Icons.handshake_outlined,
                      color: const Color(0xFF34D399),
                      tooltip: habilitadoSolucion
                          ? 'Ver solución'
                          : 'Disponible al solucionar o cancelar',
                      onPressed: (_cargandoDetalle || !habilitadoSolucion)
                          ? null
                          : () => _mostrarSolucion(ticket),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (onPressed == null ? Colors.white10 : color).withValues(
            alpha: .08,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (onPressed == null ? Colors.white10 : color).withValues(
              alpha: .12,
            ),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 17,
            color: onPressed == null ? Colors.white24 : color,
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  bool _puedeVerSolucion(Map<String, dynamic> ticket) {
    final String estado = _string(
      ticket['estado'],
      null,
      fallback: '',
    ).toLowerCase().trim();
    final bool cancelado = estado == 'cancelado';
    final dynamic solucion = ticket['solucion'];
    final dynamic solucionAplicada = ticket['solucion_aplicada'];
    final bool tieneSolucion = solucion is Map
        ? solucion.values.any(
            (value) => value != null && value.toString().trim().isNotEmpty,
          )
        : solucion != null && solucion.toString().trim().isNotEmpty;
    final bool tieneSolucionAplicada =
        solucionAplicada != null &&
        solucionAplicada.toString().trim().isNotEmpty;
    return cancelado || tieneSolucion || tieneSolucionAplicada;
  }

  Widget _buildPagination() {
    if (_ultimaPagina <= 1) return const SizedBox.shrink();

    final bool puedeAnterior = _paginaActual > 1 && !_cargando;
    final bool puedeSiguiente = _paginaActual < _ultimaPagina && !_cargando;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaginationButton(
              icon: Icons.chevron_left_rounded,
              enabled: puedeAnterior,
              onPressed: puedeAnterior
                  ? () => _cargarTickets(pagina: _paginaActual - 1)
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111B2F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Página $_paginaActual / $_ultimaPagina',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildPaginationButton(
              icon: Icons.chevron_right_rounded,
              enabled: puedeSiguiente,
              onPressed: puedeSiguiente
                  ? () => _cargarTickets(pagina: _paginaActual + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF1D4ED8).withValues(alpha: 0.15) : Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? const Color(0xFF93C5FD).withValues(alpha: 0.25)
              : Colors.white10,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: enabled ? const Color(0xFFDBEAFE) : Colors.white24,
          size: 20,
        ),
        splashRadius: 18,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Color _estadoStripeColor(String estado) {
    final String valor = estado.toLowerCase();
    if (valor.contains('pendiente') || valor.contains('pend')) {
      return const Color(0xFFFBBF24);
    }
    if (valor.contains('proceso') || valor.contains('en proceso')) {
      return const Color(0xFF60A5FA);
    }
    if (valor.contains('solucion') || valor.contains('cerrado')) {
      return const Color(0xFF34D399);
    }
    if (valor.contains('cancel')) {
      return const Color(0xFFF87171);
    }
    return const Color(0xFF93C5FD);
  }

  Widget _buildEmptyState() {
    final bool filtrado =
        _buscarController.text.trim().isNotEmpty ||
        _estadoSeleccionado != 'todos';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
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
            filtrado
                ? 'Intenta cambiar los filtros de búsqueda.'
                : 'Todavía no tienes tickets registrados.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFF87171),
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'No se pudieron cargar los tickets.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _cargarTickets(pagina: _paginaActual),
            icon: const Icon(Icons.refresh, size: 17),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String title, {bool alignRight = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: _tableHeader(title, alignRight: alignRight),
    );
  }

  Widget _tableHeader(String title, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _mostrarSolucion(Map<String, dynamic> ticket) async {
    if (!_puedeVerSolucion(ticket)) {
      _mostrarMensaje('La solución todavía no está disponible.');
      return;
    }
    final int? id = _toNullableInt(ticket['id']);
    if (id == null) {
      _mostrarMensaje('No se pudo identificar el ticket.');
      return;
    }
    if (!mounted) return;
    setState(() => _cargandoDetalle = true);
    try {
      final Map<String, dynamic> res =
          await MisTicketsUsuarioService.obtenerTicket(id);
      if (!mounted) return;
      final dynamic tData = res['ticket'];
      if (tData is! Map) {
        throw Exception('La información del ticket no es válida.');
      }
      final Map<String, dynamic> detalle = Map<String, dynamic>.from(tData);
      setState(() => _cargandoDetalle = false);
      await _mostrarDialogoSolucion(detalle);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoDetalle = false);
      _mostrarMensaje(_limpiarError(e));
    }
  }

  Future<void> _mostrarDialogoSolucion(Map<String, dynamic> ticket) async {
    final String folio = _string(ticket['folio'], null, fallback: 'Sin folio');
    final String titulo = _string(
      ticket['titulo'],
      null,
      fallback: 'Sin título',
    );
    final dynamic tData = ticket['tomado_por'] ?? ticket['tecnico'];
    final String tomadoPor = tData is Map
        ? _string(tData['name'], tData['nombre'], fallback: 'No especificado')
        : _string(tData, null, fallback: 'No especificado');
    final String correoTecnico = tData is Map
        ? _string(tData['email'], tData['correo'], fallback: 'Sin correo')
        : 'Sin correo';
    final dynamic solData = ticket['solucion'];
    final Map<String, dynamic>? sMap = solData is Map
        ? Map<String, dynamic>.from(solData)
        : null;
    final String solucion = _string(
      sMap?['solucion'],
      ticket['solucion_aplicada'],
      fallback: 'No hay una solución registrada.',
    );
    final String solucionadoPor = _string(
      sMap?['solucionado_por'],
      ticket['solucionado_por'],
      fallback: tomadoPor,
    );
    final String fechaSolucion = _formatearFecha(
      sMap?['fecha_solucion'] ??
          ticket['fecha_solucion'] ??
          ticket['solucion_at'] ??
          ticket['resolved_at'],
    );
    final String problemaSolucionadoRaw = _string(
      sMap?['problema_solucionado'],
      ticket['problema_solucionado'],
      fallback: '',
    );
    final bool problemaSolucionado = _esProblemaSolucionado(
      problemaSolucionadoRaw.isNotEmpty
          ? problemaSolucionadoRaw
          : ticket['solucionado'],
    );
    final dynamic solucionadoPorUsuario =
        sMap?['solucionado_por_usuario'] ??
        ticket['solucionado_por_usuario'] ??
        (ticket['solucion'] is Map
            ? ticket['solucion']['solucionado_por_usuario']
            : null);
    final dynamic usuarioTicket =
        ticket['user'] ??
        ticket['usuario'] ??
        ticket['levantado_por'] ??
        ticket['asignado_a'] ??
        ticket['tomado_por'];
    final String nombreFirmante = _resolverNombreFirmante(
      sMap?['nombre_firmante'],
      ticket['nombre_firmante'],
      solucionadoPorUsuario is Map ? solucionadoPorUsuario['name'] : null,
      solucionadoPorUsuario is Map ? solucionadoPorUsuario['nombre'] : null,
      usuarioTicket is Map ? usuarioTicket['name'] : null,
      usuarioTicket is Map ? usuarioTicket['nombre'] : null,
      ticket['login'],
      ticket['usuario_login'],
    );
    final String fechaFirma = _formatearFecha(
      sMap?['fecha_firma'] ?? ticket['fecha_firma'],
    );
    final String observacionesFirma = _string(
      sMap?['observaciones_firma'],
      ticket['observaciones_firma'] ?? ticket['comentario_firma'],
      fallback: 'Sin observaciones registradas.',
    );
    final String imagenFirma = _obtenerImagenFirma(sMap, ticket);
    final List<Map<String, dynamic>> evidenciasSolucion = _convertirArchivos(
      sMap?['evidencia'] ??
          ticket['evidencias_solucion'] ??
          ticket['solucion_evidencias'],
    );
    final String estado = _string(
      ticket['estado'],
      null,
      fallback: 'Solucionado',
    );
    if (!mounted) return;
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
            width: desktop ? 850 : double.infinity,
            height: size.height * .90,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1021),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .50),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSolutionHeader(dialogContext, folio, titulo),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSolutionIntro(folio, titulo),
                        const SizedBox(height: 22),
                        _buildSolutionTicketInfo(
                          folio,
                          titulo,
                          tomadoPor,
                          correoTecnico,
                        ),
                        const SizedBox(height: 20),
                        _buildSolutionStatus(estado),
                        const SizedBox(height: 18),
                        _buildAppliedSolution(solucion),
                        const SizedBox(height: 20),
                        _buildSolutionEvidence(evidenciasSolucion),
                        const SizedBox(height: 20),
                        _buildProblemSolvedSection(problemaSolucionado),
                        const SizedBox(height: 20),
                        _buildSolutionDate(fechaSolucion),
                        const SizedBox(height: 20),
                        _buildSignatureSection(
                          nombreFirmante,
                          fechaFirma,
                          observacionesFirma,
                          imagenFirma,
                        ),
                        const SizedBox(height: 20),
                        _buildTicketClosureSummary(
                          problemaSolucionado,
                          nombreFirmante,
                          fechaFirma,
                        ),
                        const SizedBox(height: 20),
                        _buildSolvedBySection(solucionadoPor),
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

  Widget _buildSolutionHeader(
    BuildContext context,
    String folio,
    String titulo,
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4010B981)),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              color: Color(0xFF34D399),
              size: 23,
            ),
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
                  folio,
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
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

  Widget _buildSolutionIntro(String folio, String titulo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF064E3B).withValues(alpha: .35),
            const Color(0xFF0F1535),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: .18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF34D399),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket #$folio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Consulta la información registrada para la solución de este ticket.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionTicketInfo(
    String folio,
    String titulo,
    String tomadoPor,
    String correoTecnico,
  ) {
    return _solutionCard(
      title: 'Información del ticket',
      icon: Icons.confirmation_number_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Container(
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
              folio,
              style: const TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _solutionDetailRow('Tomado por', tomadoPor),
            _solutionDetailRow('Correo', correoTecnico, last: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionStatus(String estado) {
    final String estadoTexto = _textoEstado(estado);
    final bool solucionado = estado.toLowerCase().trim() == 'solucionado';
    return _solutionCard(
      title: 'Estado de la solución',
      icon: Icons.flag_outlined,
      iconColor: const Color(0xFF34D399),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: solucionado
              ? const Color(0xFF064E3B)
              : const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: solucionado
                ? const Color(0x4010B981)
                : const Color(0x403B82F6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              solucionado ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: solucionado
                  ? const Color(0xFF34D399)
                  : const Color(0xFF60A5FA),
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              estadoTexto,
              style: TextStyle(
                color: solucionado
                    ? const Color(0xFF34D399)
                    : const Color(0xFF60A5FA),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedSolution(String solucion) {
    return _solutionCard(
      title: 'Solución aplicada',
      icon: Icons.build_circle_outlined,
      iconColor: const Color(0xFF60A5FA),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1021),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          solucion,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionEvidence(List<Map<String, dynamic>> archivos) {
    return _solutionCard(
      title: 'Evidencias de la solución',
      subtitle: '${archivos.length} archivo${archivos.length == 1 ? '' : 's'}',
      icon: Icons.attach_file_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: archivos.isEmpty
          ? const Text(
              'No hay evidencias de solución registradas.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: archivos.map(_buildFileItem).toList(),
            ),
    );
  }

  Widget _buildProblemSolvedSection(bool solucionado) {
    return _solutionCard(
      title: '¿El problema fue solucionado?',
      icon: Icons.help_outline_rounded,
      iconColor: const Color(0xFF60A5FA),
      child: Column(
        children: [
          _solutionSelection(
            icon: Icons.check_circle_outline_rounded,
            title: 'Sí, fue solucionado',
            selected: solucionado,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _solutionSelection(
            icon: Icons.cancel_outlined,
            title: 'No fue solucionado',
            selected: !solucionado,
            color: const Color(0xFFF87171),
          ),
        ],
      ),
    );
  }

  Widget _solutionSelection({
    required IconData icon,
    required String title,
    required bool selected,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: .09)
            : const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? color.withValues(alpha: .40) : Colors.white10,
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
    );
  }

  Widget _buildSolutionDate(String fecha) {
    return _solutionCard(
      title: 'Fecha de solución',
      icon: Icons.calendar_month_outlined,
      iconColor: const Color(0xFFA78BFA),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Colors.grey, size: 17),
            const SizedBox(width: 9),
            Text(
              fecha == 'Sin fecha' ? 'Sin fecha registrada' : fecha,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection(
    String nombreFirmante,
    String fechaFirma,
    String observaciones,
    String imagenFirma,
  ) {
    return _solutionCard(
      title: 'Firma y cierre',
      icon: Icons.draw_outlined,
      iconColor: const Color(0xFFA78BFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _solutionDetailRow('Firmante', nombreFirmante),
          _solutionDetailRow(
            'Fecha de firma',
            fechaFirma == 'Sin fecha' ? 'Sin fecha registrada' : fechaFirma,
          ),
          _solutionDetailRow('Observaciones', observaciones, last: true),
          const SizedBox(height: 18),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.draw_outlined, color: Color(0xFFA78BFA), size: 18),
              SizedBox(width: 8),
              Text(
                'Imagen de la firma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSignatureImage(imagenFirma),
        ],
      ),
    );
  }

  Widget _buildSolvedBySection(String solucionadoPor) {
    return _solutionCard(
      title: 'Solucionado por',
      icon: Icons.person_pin_outlined,
      iconColor: const Color(0xFF34D399),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF34D399),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                solucionadoPor,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketClosureSummary(
    bool problemaSolucionado,
    String nombreFirmante,
    String fechaFirma,
  ) {
    final String estadoRespuesta = problemaSolucionado ? 'Sí' : 'No';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: .35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cierre del ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Información registrada al cerrar el caso.',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF060A17),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClosureRow(
                '¿Se solucionó?',
                estadoRespuesta,
                problemaSolucionado ? const Color(0xFF34D399) : const Color(0xFFF87171),
              ),
              const SizedBox(height: 12),
              _buildClosureRow('Nombre del firmante', nombreFirmante),
              const SizedBox(height: 12),
              _buildClosureRow(
                'Fecha de firma',
                fechaFirma == 'Sin fecha' ? 'Sin fecha registrada' : fechaFirma,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClosureRow(String label, String value, [Color? valueColor]) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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

  String _obtenerImagenFirma(
    Map<String, dynamic>? sMap,
    Map<String, dynamic> ticket,
  ) {
    final dynamic valor =
        sMap?['firma'] ??
        sMap?['firma_imagen'] ??
        sMap?['imagen_firma'] ??
        sMap?['firma_url'] ??
        sMap?['signature'] ??
        sMap?['signature_image'] ??
        ticket['firma'] ??
        ticket['firma_imagen'] ??
        ticket['imagen_firma'] ??
        ticket['firma_url'] ??
        ticket['signature'] ??
        ticket['signature_image'];
    if (valor is Map) {
      return _string(
        valor['ruta'],
        valor['path'] ?? valor['url'] ?? valor['archivo'] ?? valor['file'],
        fallback: '',
      );
    }
    return valor?.toString().trim() ?? '';
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

  String _resolverNombreFirmante(
    Object? primero,
    Object? segundo, [
    Object? tercero,
    Object? cuarto,
    Object? quinto,
    Object? sexto,
    Object? septimo,
    Object? octavo,
  ]) {
    final List<Object?> valores = [
      primero,
      segundo,
      tercero,
      cuarto,
      quinto,
      sexto,
      septimo,
      octavo,
    ];

    for (final valor in valores) {
      final String nombre = _normalizarNombreFirmante(
        valor?.toString() ?? '',
        '',
      );
      if (nombre.isNotEmpty && nombre != 'No especificado') {
        return nombre;
      }
    }

    return 'No especificado';
  }

  String _normalizarNombreFirmante(String valor, String fallback) {
    final String limpio = valor.trim();
    if (limpio.isEmpty) {
      return fallback.isNotEmpty ? fallback : 'No especificado';
    }

    final String normalizado = limpio.toLowerCase();
    final List<String> nombresNoValidos = [
      'administracion',
      'administración',
      'administrador',
      'departamento',
      'tecnologias',
      'tecnología',
      'soporte',
      'gerencia',
      'ventas',
      'recursos humanos',
      'no especificado',
      'sin especificar',
      'no especificada',
    ];

    final bool esValorNoValido = nombresNoValidos.any(
      (nombre) => normalizado == nombre || normalizado.contains(nombre),
    );

    if (esValorNoValido) {
      return fallback.isNotEmpty ? fallback : 'No especificado';
    }

    return limpio;
  }

  String _string(dynamic value, dynamic secondValue, {String fallback = ''}) {
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
    if (secondValue != null && secondValue.toString().trim().isNotEmpty) {
      return secondValue.toString();
    }
    return fallback;
  }

  int? _toNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value != null) return int.tryParse(value.toString().trim());
    return null;
  }

  int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
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

  bool _esProblemaSolucionado(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final String texto = value.toString().trim().toLowerCase();
    if (texto.isEmpty) return false;
    if (['1', 'true', 'si', 'sí', 'yes', 's', 'solucionado', 'resuelto']
        .contains(texto)) {
      return true;
    }
    if (['0', 'false', 'no', 'n', 'pendiente', 'sin resolver']
        .contains(texto)) {
      return false;
    }
    return texto.contains('solucion') || texto.contains('resuelto');
  }

  String _limpiarError(dynamic error) {
    final String texto = error.toString();
    if (texto.startsWith('Exception: ')) return texto.substring(11);
    return texto;
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
    home.showUserMessage(context, mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    if (_cargando) {
      return const LoadingScreen(mensaje: 'Cargando tus tickets...');
    }
    return Scaffold(
      backgroundColor: const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const TicketProAppLogo(fontSize: 20),
              actions: [
                home.UserHeaderActions(
                  onNotifications: () => home.showUserNotifications(context),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : const TicketProNavigationDrawer(activeRoute: 'Mis tickets'),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: TicketProNavigationDrawer(activeRoute: 'Mis tickets'),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(isDesktop),
                  const SizedBox(height: 24),
                  _buildMainContent(isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        if (isDesktop)
          home.UserHeaderActions(
            onNotifications: () => home.showUserNotifications(context),
          ),
      ],
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildContentTitle()),
                const SizedBox(width: 20),
                _buildSearchAndFilter(),
              ],
            )
          else ...[
            _buildContentTitle(),
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

  Widget _buildContentTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Text(
          '$_totalTickets ticket${_totalTickets == 1 ? '' : 's'}',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }
}

class TicketProAppLogo extends StatelessWidget {
  final double fontSize;
  const TicketProAppLogo({super.key, this.fontSize = 26});
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

class TicketProNavigationDrawer extends StatelessWidget {
  final String activeRoute;
  const TicketProNavigationDrawer({
    super.key,
    this.activeRoute = 'Mis tickets',
  });
  static const String defaultAvatar = 'assets/images/user.png';
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1021),
      child: SafeArea(
        child: Container(
          color: const Color(0xFF0B1021),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TicketProAppLogo(fontSize: 26),

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
                    child: const home.UserAvatar(radius: 20),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: SessionService.getUser(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;

                        final String nombre =
                            user?['name']?.toString().trim().isNotEmpty == true
                            ? user!['name'].toString()
                            : 'Usuario';

                        final String rol =
                            user?['role']?.toString().trim().isNotEmpty == true
                            ? user!['role'].toString()
                            : 'Sin rol';

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

                            const SizedBox(height: 2),

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
                isActive: activeRoute == 'Inicio',
                onTap: () {
                  if (activeRoute == 'Inicio') {
                    Navigator.pop(context);
                    return;
                  }

                  navigateWithLoading(
                    context,
                    const home.HomeScreen(),
                    mensaje: 'Cargando inicio...',
                  );
                },
              ),

              _drawerItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Mis tickets',
                isActive: activeRoute == 'Mis tickets',
                onTap: () {
                  if (activeRoute == 'Mis tickets') {
                    Navigator.pop(context);
                    return;
                  }

                  navigateWithLoading(
                    context,
                    const MisticketsScreen(),
                    mensaje: 'Cargando tus tickets...',
                  );
                },
              ),

              _drawerItem(
                icon: Icons.build_outlined,
                title: 'Crear ticket',
                isActive: activeRoute == 'Crear ticket',
                onTap: () {
                  if (activeRoute == 'Crear ticket') {
                    Navigator.pop(context);
                    return;
                  }

                  navigateWithLoading(
                    context,
                    const CrearticketsScreen(),
                    mensaje: 'Preparando crear ticket...',
                  );
                },
              ),

              _drawerItem(
                icon: Icons.warning_amber_rounded,
                title: 'Avisos',
                isActive: activeRoute == 'Avisos',
                onTap: () {
                  if (activeRoute == 'Avisos') {
                    Navigator.pop(context);
                    return;
                  }

                  navigateWithLoading(
                    context,
                    const AvisosScreen(),
                    mensaje: 'Cargando avisos...',
                  );
                },
              ),

              _drawerItem(
                icon: Icons.person_outline_rounded,
                title: 'Mi perfil',
                isActive: activeRoute == 'Mi perfil',
                onTap: () {
                  if (activeRoute == 'Mi perfil') {
                    Navigator.pop(context);
                    return;
                  }

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
                  Navigator.pop(context);

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
    final Color itemColor = color ?? (isActive ? Colors.white : Colors.grey);
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
