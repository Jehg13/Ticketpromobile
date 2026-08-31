import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/admin/avisosadmin_services.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class AvisosadminScreen extends StatefulWidget {
  const AvisosadminScreen({super.key});

  @override
  State<AvisosadminScreen> createState() => _AvisosadminScreenState();
}

class _AvisosadminScreenState extends State<AvisosadminScreen> {
  final Color bgDark = const Color(0xFF0B0F19);
  final Color cardDark = const Color(0xFF121826);
  final Color inputBg = const Color(0xFF172033);
  final Color primaryGradientStart = const Color(0xFF2563EB);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _aplicarAController = TextEditingController();

  String _selectedFiltroEstado = 'Todos';
  String _prioridadSeleccionada = 'Alta';
  String _tipoAvisoSeleccionado = 'informativo';
  String _aplicarASeleccionado = 'todos';
  bool _mostrarNotificacion = true;
  bool _fijarAviso = false;
  PlatformFile? _archivoAdjunto;
  Uint8List? _archivoPreviewBytes;
  String activeMenu = 'Avisos';

  List<Map<String, dynamic>> avisos = [];
  List<Map<String, dynamic>> notificaciones = [];
  List<Map<String, dynamic>> _departamentos = [];
  List<Map<String, dynamic>> _oficinas = [];
  List<Map<String, dynamic>> _usuarios = [];
  final Set<int> _departamentosSeleccionados = <int>{};
  final Set<int> _oficinasSeleccionadas = <int>{};
  final Set<String> _usuariosSeleccionados = <String>{};
  int notificacionesNoLeidas = 0;
  bool _cargando = true;
  bool _cargandoNotificaciones = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tituloController.dispose();
    _contenidoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _aplicarAController.dispose();
    super.dispose();
  }

  String _tipoAvisoLabel(String value) {
    switch (value) {
      case 'mantenimiento':
        return 'Mantenimiento';
      case 'incidente':
        return 'Falla/Incidente';
      case 'informativo':
        return 'Informativo';
      case 'general':
      default:
        return 'Normal';
    }
  }

  String _tipoAvisoApi(String value) {
    switch (value) {
      case 'mantenimiento':
        return 'mantenimiento';
      case 'incidente':
        return 'incidente';
      case 'informativo':
        return 'informativo';
      case 'general':
      default:
        return 'general';
    }
  }

  IconData _iconoTipoAviso(String value) {
    switch (value) {
      case 'mantenimiento':
        return Icons.build_rounded;
      case 'incidente':
        return Icons.warning_amber_rounded;
      case 'informativo':
        return Icons.info_outline_rounded;
      case 'general':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _colorTipoAviso(String value) {
    switch (value) {
      case 'mantenimiento':
        return const Color(0xFFFF8A00);
      case 'incidente':
        return const Color(0xFFEF4444);
      case 'informativo':
        return const Color(0xFF3B82F6);
      case 'general':
      default:
        return Colors.white70;
    }
  }

  String _importanciaApi(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'critica':
        return 'critica';
      case 'alta':
        return 'alta';
      case 'media':
        return 'media';
      case 'normal':
      default:
        return 'normal';
    }
  }

  IconData _iconoImportancia(String value) {
    switch (value.toLowerCase()) {
      case 'critica':
        return Icons.priority_high_rounded;
      case 'alta':
        return Icons.warning_amber_rounded;
      case 'media':
        return Icons.flag_rounded;
      case 'normal':
      default:
        return Icons.check_circle_rounded;
    }
  }

  Color _colorImportancia(String value) {
    switch (value.toLowerCase()) {
      case 'critica':
        return const Color(0xFFDC2626);
      case 'alta':
        return const Color(0xFFF97316);
      case 'media':
        return const Color(0xFFFACC15);
      case 'normal':
      default:
        return const Color(0xFF22C55E);
    }
  }

  bool _esArchivoImagen(String nombre) {
    final extension = nombre.split('.').last.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(extension);
  }

  String _obtenerNombreArchivo(dynamic value) {
    if (value == null) return '';
    final texto = _textoSeguro(value);
    if (texto.isEmpty) return '';

    final normalized = texto.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final name = parts.isNotEmpty ? parts.last : normalized;
    return name.split('?').first;
  }

  Future<void> _seleccionarArchivo() async {
    try {
      final archivo = await FilePicker.pickFile(type: FileType.any);
      if (archivo == null) return;

      final bytes = await archivo.readAsBytes();

      if (!mounted) return;
      setState(() {
        _archivoAdjunto = archivo;
        _archivoPreviewBytes = bytes;
      });
    } catch (_) {
      _mostrarMensaje('No se pudo adjuntar el archivo.', isError: true);
    }
  }

  File? _archivoAdjuntoFile() {
    if (_archivoAdjunto == null) return null;
    final path = _archivoAdjunto!.path;
    if (path == null || path.isEmpty) return null;
    return File(path);
  }

  List<String> _parseAfectaA(String text) {
    final clean = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return clean;
  }

  void _reiniciarSelecciones() {
    _departamentosSeleccionados.clear();
    _oficinasSeleccionadas.clear();
    _usuariosSeleccionados.clear();
  }

  void _aplicarSeleccionDesdeAfectaA(dynamic afectaA) {
    _reiniciarSelecciones();

    if (afectaA is! Map) {
      return;
    }

    final tipo = _textoSeguro(afectaA['tipo']);

    if (tipo == 'departamentos' || tipo == 'departamento') {
      final ids = afectaA['ids'];
      if (ids is List) {
        for (final elemento in ids) {
          final id = int.tryParse(elemento.toString());
          if (id != null) {
            _departamentosSeleccionados.add(id);
          }
        }
      }
      return;
    }

    if (tipo == 'oficinas' || tipo == 'oficina') {
      final ids = afectaA['ids'];
      if (ids is List) {
        for (final elemento in ids) {
          final id = int.tryParse(elemento.toString());
          if (id != null) {
            _oficinasSeleccionadas.add(id);
          }
        }
      }
      return;
    }

    if (tipo == 'usuarios') {
      final logins = afectaA['logins'];
      if (logins is List) {
        for (final elemento in logins) {
          final login = elemento.toString().trim();
          if (login.isNotEmpty) {
            _usuariosSeleccionados.add(login);
          }
        }
      }
    }
  }

  List<dynamic> _obtenerAfectadosSeleccionados() {
    switch (_aplicarASeleccionado) {
      case 'oficina':
        return _oficinasSeleccionadas.toList()..sort();
      case 'departamento':
        return _departamentosSeleccionados.toList()..sort();
      case 'usuarios':
        return _usuariosSeleccionados.toList()..sort();
      case 'todos':
      default:
        return const [];
    }
  }

  Widget _buildDestinatariosSelector({
    required String aplicaA,
    required StateSetter setStateModal,
  }) {
    switch (aplicaA) {
      case 'oficina':
        if (_oficinas.isEmpty) {
          return const Text(
            'No hay oficinas disponibles.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        return Column(
          children: _oficinas.map((oficina) {
            final id = int.tryParse(_textoSeguro(oficina['id'])) ?? 0;
            final nombre = _textoSeguro(oficina['nombre']);
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                nombre,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              activeColor: Colors.blueAccent,
              value: _oficinasSeleccionadas.contains(id),
              onChanged: id == 0
                  ? null
                  : (value) {
                      setStateModal(() {
                        if (value == true) {
                          _oficinasSeleccionadas.add(id);
                        } else {
                          _oficinasSeleccionadas.remove(id);
                        }
                      });
                    },
            );
          }).toList(),
        );
      case 'departamento':
        if (_departamentos.isEmpty) {
          return const Text(
            'No hay departamentos disponibles.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        return Column(
          children: _departamentos.map((departamento) {
            final id = int.tryParse(_textoSeguro(departamento['id'])) ?? 0;
            final nombre = _textoSeguro(departamento['nombre']);
            final oficina = _textoSeguro(departamento['oficina']?['nombre']);
            final label = oficina.isNotEmpty ? '$nombre · $oficina' : nombre;
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              activeColor: Colors.blueAccent,
              value: _departamentosSeleccionados.contains(id),
              onChanged: id == 0
                  ? null
                  : (value) {
                      setStateModal(() {
                        if (value == true) {
                          _departamentosSeleccionados.add(id);
                        } else {
                          _departamentosSeleccionados.remove(id);
                        }
                      });
                    },
            );
          }).toList(),
        );
      case 'usuarios':
        if (_usuarios.isEmpty) {
          return const Text(
            'No hay usuarios disponibles.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        return Column(
          children: _usuarios.map((usuario) {
            final login = _textoSeguro(usuario['login']);
            final nombre = _textoSeguro(usuario['name']);
            final texto = nombre.isNotEmpty ? '$nombre ($login)' : login;
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                texto,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              activeColor: Colors.blueAccent,
              value: _usuariosSeleccionados.contains(login),
              onChanged: login.isEmpty
                  ? null
                  : (value) {
                      setStateModal(() {
                        if (value == true) {
                          _usuariosSeleccionados.add(login);
                        } else {
                          _usuariosSeleccionados.remove(login);
                        }
                      });
                    },
            );
          }).toList(),
        );
      case 'todos':
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _cargarDatos() async {
    try {
      final avisosCargados = await AvisosAdminService.obtenerAvisos();
      final notificacionesCargadas =
          await AvisosAdminService.obtenerNotificaciones();
      final noLeidas = await AvisosAdminService.obtenerNotificacionesNoLeidas();
      final departamentos = await AvisosAdminService.obtenerDepartamentos();
      final oficinas = await AvisosAdminService.obtenerOficinas();
      final usuarios = await AvisosAdminService.obtenerUsuarios();

      if (!mounted) return;

      setState(() {
        avisos = avisosCargados;
        notificaciones = notificacionesCargadas;
        _departamentos = departamentos;
        _oficinas = oficinas;
        _usuarios = usuarios;
        notificacionesNoLeidas = noLeidas;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        avisos = [];
        notificaciones = [];
        _departamentos = [];
        _oficinas = [];
        _usuarios = [];
        notificacionesNoLeidas = 0;
        _cargando = false;
        _error = _limpiarError(e);
      });
    }
  }

  Future<void> _crearAviso() async {
    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje('Debes ingresar un título para el aviso.', isError: true);
      return;
    }

    try {
      final fecha = _fechaController.text.trim();
      final hora = _horaController.text.trim();
      final aplicaA = _aplicarASeleccionado;
      final afectaA = aplicaA == 'todos'
          ? const []
          : _obtenerAfectadosSeleccionados();

      if ((aplicaA == 'oficina' && _oficinasSeleccionadas.isEmpty) ||
          (aplicaA == 'departamento' && _departamentosSeleccionados.isEmpty) ||
          (aplicaA == 'usuarios' && _usuariosSeleccionados.isEmpty)) {
        _mostrarMensaje(
          'Debes seleccionar al menos un destinatario.',
          isError: true,
        );
        return;
      }

      await AvisosAdminService.crearAviso(
        titulo: titulo,
        tipo: _tipoAvisoApi(_tipoAvisoSeleccionado),
        importancia: _importanciaApi(_prioridadSeleccionada),
        fechaInicio: fecha.isNotEmpty
            ? fecha
            : AvisosAdminService.formatearFecha(DateTime.now()),
        horaInicio: hora.isNotEmpty
            ? hora
            : AvisosAdminService.formatearHora(TimeOfDay.now()),
        aplicaA: aplicaA,
        afectaA: afectaA,
        descripcion: contenido.isEmpty ? 'Sin descripción.' : contenido,
        mostrarNotificaciones: _mostrarNotificacion,
        fijado: _fijarAviso,
        archivo: _archivoAdjunto,
      );

      if (!mounted) return;
      _tituloController.clear();
      _contenidoController.clear();
      await _cargarDatos();
      if (!mounted) return;
      Navigator.of(context).pop();
      _mostrarMensaje('Aviso publicado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  Future<void> _eliminarAviso(Map<String, dynamic> item) async {
    final id = int.tryParse(_textoSeguro(item['id'])) ?? 0;
    if (id == 0) {
      _mostrarMensaje('No se pudo identificar el aviso.', isError: true);
      return;
    }

    try {
      final navigator = Navigator.of(context);
      await AvisosAdminService.eliminarAviso(id);
      if (!mounted) return;
      await _cargarDatos();
      if (!mounted) return;
      navigator.pop();
      _mostrarMensaje('Aviso eliminado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  Future<void> _actualizarAvisoDesdeFormulario(
    Map<String, dynamic> item,
    TextEditingController editTitulo,
    TextEditingController editContenido,
    String editPrioridad,
  ) async {
    final titulo = editTitulo.text.trim();
    if (titulo.isEmpty) {
      _mostrarMensaje('El título del aviso es obligatorio.', isError: true);
      return;
    }

    final id = int.tryParse(_textoSeguro(item['id'])) ?? 0;
    if (id == 0) {
      _mostrarMensaje('No se pudo identificar el aviso.', isError: true);
      return;
    }

    try {
      final navigator = Navigator.of(context);
      final nuevaFecha = _fechaController.text.trim();
      final nuevaHora = _horaController.text.trim();
      final aplicaA = _aplicarASeleccionado;
      final afectaA = aplicaA == 'todos'
          ? const []
          : _obtenerAfectadosSeleccionados();

      if ((aplicaA == 'oficina' && _oficinasSeleccionadas.isEmpty) ||
          (aplicaA == 'departamento' && _departamentosSeleccionados.isEmpty) ||
          (aplicaA == 'usuarios' && _usuariosSeleccionados.isEmpty)) {
        _mostrarMensaje(
          'Debes seleccionar al menos un destinatario.',
          isError: true,
        );
        return;
      }

      await AvisosAdminService.actualizarAviso(
        id: id,
        titulo: titulo,
        tipo: _tipoAvisoApi(_tipoAvisoSeleccionado),
        importancia: _importanciaApi(editPrioridad),
        fechaInicio: nuevaFecha.isNotEmpty ? nuevaFecha : _fechaInicio(item),
        horaInicio: nuevaHora.isNotEmpty ? nuevaHora : _horaInicio(item),
        aplicaA: aplicaA,
        afectaA: afectaA,
        descripcion: editContenido.text.trim().isEmpty
            ? 'Sin descripción.'
            : editContenido.text.trim(),
        mostrarNotificaciones: _mostrarNotificacion,
        fijado: _fijarAviso,
        estado: _normalizarEstado(_estadoAviso(item)),
        archivo: _archivoAdjunto,
      );

      if (!mounted) return;
      await _cargarDatos();
      if (!mounted) return;
      navigator.pop();
      _mostrarMensaje('Aviso actualizado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  Future<void> _abrirNotificaciones() async {
    setState(() => _cargandoNotificaciones = true);

    try {
      final items = await AvisosAdminService.obtenerNotificaciones();
      final unread = await AvisosAdminService.obtenerNotificacionesNoLeidas();

      if (!mounted) return;
      setState(() {
        notificaciones = items;
        notificacionesNoLeidas = unread;
        _cargandoNotificaciones = false;
      });

      await showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.75),
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final itemsActuales = notificaciones;
            final unreadActual = itemsActuales.where((item) {
              final leida = item['leida'];
              return leida != true &&
                  leida != 1 &&
                  leida != '1' &&
                  leida != 'true';
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
                constraints: const BoxConstraints(
                  maxWidth: 560,
                  maxHeight: 650,
                ),
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
                          if (unreadActual > 0)
                            TextButton.icon(
                              onPressed: () async {
                                final ok =
                                    await AvisosAdminService.marcarTodasNotificacionesLeidas();
                                if (!mounted) return;
                                if (ok) {
                                  final refreshed =
                                      await AvisosAdminService.obtenerNotificaciones();
                                  final unreadAfter =
                                      await AvisosAdminService.obtenerNotificacionesNoLeidas();
                                  setState(() {
                                    notificaciones = refreshed;
                                    notificacionesNoLeidas = unreadAfter;
                                  });
                                  setDialogState(() {
                                    notificaciones = refreshed;
                                    notificacionesNoLeidas = unreadAfter;
                                  });
                                  _mostrarMensaje(
                                    'Notificaciones marcadas como leídas.',
                                  );
                                } else {
                                  _mostrarMensaje(
                                    'No se pudieron actualizar las notificaciones.',
                                    isError: true,
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
                              icon: const Icon(
                                Icons.done_all_rounded,
                                size: 18,
                              ),
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
                      child: _cargandoNotificaciones
                          ? const Center(child: CircularProgressIndicator())
                          : itemsActuales.isEmpty
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
                              itemCount: itemsActuales.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final item = itemsActuales[index];
                                final leida =
                                    item['leida'] == true ||
                                    item['leida'] == 1 ||
                                    item['leida'] == '1' ||
                                    item['leida'] == 'true';
                                final itemId = int.tryParse(
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
                                        _iconoNotificacion(item),
                                        color: _colorNotificacion(item),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _tituloNotificacion(item),
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
                                        _mensajeNotificacion(item),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                      onTap: () async {
                                        if (itemId != null) {
                                          await AvisosAdminService.marcarNotificacionComoLeida(
                                            itemId,
                                          );
                                          final refreshed =
                                              await AvisosAdminService.obtenerNotificaciones();
                                          final unreadAfter =
                                              await AvisosAdminService.obtenerNotificacionesNoLeidas();
                                          if (mounted) {
                                            setState(() {
                                              notificaciones = refreshed;
                                              notificacionesNoLeidas =
                                                  unreadAfter;
                                            });
                                          }
                                          setDialogState(() {
                                            notificaciones = refreshed;
                                            notificacionesNoLeidas =
                                                unreadAfter;
                                          });
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
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoNotificaciones = false);
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  void _mostrarMensaje(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String _limpiarError(Object error) {
    final text = error.toString();
    return text.replaceFirst('Exception: ', '').trim();
  }

  String _textoSeguro(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      for (final key in [
        'titulo',
        'title',
        'nombre',
        'name',
        'descripcion',
        'description',
        'mensaje',
        'message',
        'texto',
        'text',
        'contenido',
        'body',
        'value',
        'valor',
      ]) {
        final texto = _textoSeguro(value[key]);
        if (texto.isNotEmpty) return texto;
      }
    }
    return value.toString();
  }

  String _tituloAviso(Map<String, dynamic> item) {
    for (final key in ['titulo', 'title', 'nombre', 'name']) {
      final value = _textoSeguro(item[key]);
      if (value.isNotEmpty) return value;
    }
    return 'Aviso';
  }

  String _contenidoAviso(Map<String, dynamic> item) {
    for (final key in [
      'descripcion',
      'description',
      'mensaje',
      'message',
      'texto',
      'text',
      'contenido',
      'body',
    ]) {
      final value = _textoSeguro(item[key]);
      if (value.isNotEmpty) return value;
    }
    return 'Sin descripción.';
  }

  String _normalizarImportancia(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'critica':
      case 'alta':
        return 'alta';
      case 'media':
      case 'normal':
        return 'media';
      case 'baja':
        return 'baja';
      default:
        return 'media';
    }
  }

  String _normalizarEstado(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('inactivo') ||
        normalized == '0' ||
        normalized == 'false') {
      return 'inactivo';
    }
    return 'activo';
  }

  String _prioridadAviso(Map<String, dynamic> item) {
    for (final key in ['importancia', 'prioridad', 'importance', 'priority']) {
      final value = _textoSeguro(item[key]);
      if (value.isNotEmpty) {
        switch (value.trim().toLowerCase()) {
          case 'critica':
          case 'alta':
            return 'Alta';
          case 'media':
          case 'normal':
            return 'Media';
          case 'baja':
            return 'Baja';
          default:
            return value[0].toUpperCase() + value.substring(1);
        }
      }
    }
    return 'Media';
  }

  String _estadoAviso(Map<String, dynamic> item) {
    final value = _textoSeguro(
      item['estado'] ?? item['status'] ?? item['activo'],
    );
    if (value.isEmpty) return 'Activo';
    final lower = value.toLowerCase();
    if (lower.contains('inactivo') || lower == '0' || lower == 'false')
      return 'Inactivo';
    return 'Activo';
  }

  bool _isActivo(Map<String, dynamic> item) => _estadoAviso(item) == 'Activo';

  String _fechaAviso(Map<String, dynamic> item) {
    for (final key in [
      'fecha_inicio',
      'fecha',
      'date',
      'created_at',
      'updated_at',
    ]) {
      final raw = _textoSeguro(item[key]);
      if (raw.isEmpty) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      }
      return raw;
    }
    return 'Sin fecha';
  }

  String _fechaInicio(Map<String, dynamic> item) {
    final raw = _textoSeguro(
      item['fecha_inicio'] ?? item['fecha'] ?? item['date'],
    );
    if (raw.isEmpty) return AvisosAdminService.formatearFecha(DateTime.now());
    final parsed = DateTime.tryParse(raw);
    return parsed != null ? AvisosAdminService.formatearFecha(parsed) : raw;
  }

  String _horaInicio(Map<String, dynamic> item) {
    final raw = _textoSeguro(
      item['hora_inicio'] ?? item['hora'] ?? item['time'],
    );
    if (raw.isEmpty) return AvisosAdminService.formatearHora(TimeOfDay.now());
    final parts = raw.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
      final minute = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return raw;
  }

  bool _mostrarNotificaciones(Map<String, dynamic> item) {
    final raw = _textoSeguro(
      item['mostrar_notificaciones'] ?? item['notificaciones'],
    );
    if (raw.isEmpty) return true;
    final lower = raw.toLowerCase();
    return lower == '1' || lower == 'true' || lower == 'si' || lower == 'yes';
  }

  bool _fijado(Map<String, dynamic> item) {
    final raw = _textoSeguro(item['fijado'] ?? item['fijo'] ?? item['pinned']);
    if (raw.isEmpty) return false;
    final lower = raw.toLowerCase();
    return lower == '1' || lower == 'true' || lower == 'si' || lower == 'yes';
  }

  String _tituloNotificacion(Map<String, dynamic> item) {
    for (final key in [
      'titulo',
      'title',
      'nombre',
      'name',
      'asunto',
      'subject',
      'tipo',
    ]) {
      final value = _textoSeguro(item[key]);
      if (value.isNotEmpty) return value;
    }
    return 'Notificación';
  }

  String _mensajeNotificacion(Map<String, dynamic> item) {
    for (final key in [
      'mensaje',
      'message',
      'descripcion',
      'description',
      'texto',
      'text',
      'contenido',
      'body',
    ]) {
      final value = _textoSeguro(item[key]);
      if (value.isNotEmpty) return value;
    }
    return 'Sin descripción.';
  }

  IconData _iconoNotificacion(Map<String, dynamic> item) {
    final tipo = _textoSeguro(item['tipo'] ?? item['type'] ?? '').toLowerCase();
    if (tipo.contains('aviso') ||
        tipo.contains('warning') ||
        tipo.contains('advertencia'))
      return Icons.warning_amber_rounded;
    if (tipo.contains('error') || tipo.contains('cancel'))
      return Icons.error_outline;
    if (tipo.contains('success') || tipo.contains('solucion'))
      return Icons.check_circle_outline;
    if (tipo.contains('coment')) return Icons.comment_outlined;
    if (tipo.contains('ticket')) return Icons.confirmation_number_outlined;
    return Icons.notifications_none_rounded;
  }

  Color _colorNotificacion(Map<String, dynamic> item) {
    final tipo = _textoSeguro(item['tipo'] ?? item['type'] ?? '').toLowerCase();
    if (tipo.contains('aviso') ||
        tipo.contains('warning') ||
        tipo.contains('advertencia'))
      return Colors.amber;
    if (tipo.contains('error') || tipo.contains('cancel'))
      return Colors.redAccent;
    if (tipo.contains('success') || tipo.contains('solucion'))
      return Colors.green;
    return Colors.blueAccent;
  }

  List<Map<String, dynamic>> get listaFiltrada {
    final query = _searchController.text.toLowerCase().trim();
    return avisos.where((item) {
      final titulo = _tituloAviso(item).toLowerCase();
      final contenido = _contenidoAviso(item).toLowerCase();
      final matchesQuery =
          query.isEmpty || titulo.contains(query) || contenido.contains(query);
      if (!matchesQuery) return false;
      if (_selectedFiltroEstado == 'Activos') return _isActivo(item);
      if (_selectedFiltroEstado == 'Inactivos') return !_isActivo(item);
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = avisos.length;
    final activos = avisos.where(_isActivo).length;
    final inactivos = total - activos;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: AdminScreen.sidebarBg,
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
                  color: AdminScreen.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (notificacionesNoLeidas > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AdminScreen.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        notificacionesNoLeidas > 99
                            ? '99+'
                            : '$notificacionesNoLeidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _abrirNotificaciones,
          ),
          const SizedBox(width: 8),
          const AdminAvatar(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _cargarDatos,
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _buildSectionHeader(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestión de Avisos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Crea, edita y administra los avisos para los usuarios',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCounterChip(
                                  Icons.campaign_outlined,
                                  '$total Total',
                                  Colors.blue,
                                ),
                                const SizedBox(width: 6),
                                _buildCounterDotChip(
                                  Colors.green,
                                  '$activos Activos',
                                ),
                                const SizedBox(width: 6),
                                _buildCounterDotChip(
                                  Colors.grey,
                                  '$inactivos Inactivos',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration(
                              Icons.search,
                              'Buscar avisos...',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFiltroEstado,
                            dropdownColor: cardDark,
                            isExpanded: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: _inputDecoration(
                              Icons.filter_alt_outlined,
                              '',
                            ),
                            items: ['Todos', 'Activos', 'Inactivos']
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => _selectedFiltroEstado = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (listaFiltrada.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listaFiltrada.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = listaFiltrada[index];
                                return _buildAvisoCardMobile(item);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: AdminScreen.sidebarBg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: AdminScreen.accentBlue,
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
                                color: AdminScreen.textMuted,
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
              Icons.dashboard_rounded,
              'Inicio',
              selected: activeMenu == 'Inicio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicketsScreen(),
                  ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CambiosScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              Icons.people_outline,
              'Usuarios',
              selected: activeMenu == 'Usuarios',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UserScreen()),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DispositivosScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              Icons.campaign_outlined,
              'Avisos',
              selected: activeMenu == 'Avisos',
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              context,
              Icons.person_outline,
              'Mi perfil',
              selected: activeMenu == 'Mi perfil',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerfiladminScreen(),
                  ),
                );
              },
            ),
            const Divider(color: Colors.white10),
            _drawerItem(
              context,
              Icons.logout_rounded,
              'Cerrar sesión',
              selected: false,
              isDestructive: true,
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    required bool selected,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final itemColor = isDestructive
        ? Colors.redAccent
        : selected
        ? Colors.white
        : AdminScreen.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AdminScreen.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: itemColor, size: 20),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    Navigator.pop(context);
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avisos',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Publica y administra avisos para la organización',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: _showModalCrearAviso,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text(
              'Nuevo aviso',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoCardMobile(Map<String, dynamic> item) {
    final isActivo = _isActivo(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrioridadBadge(_prioridadAviso(item)),
              Row(
                children: [
                  Switch(
                    value: isActivo,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (val) async {
                      final id = int.tryParse(_textoSeguro(item['id'])) ?? 0;
                      if (id == 0) return;

                      try {
                        await AvisosAdminService.actualizarAviso(
                          id: id,
                          titulo: _tituloAviso(item),
                          tipo: _textoSeguro(item['tipo']).isNotEmpty
                              ? _textoSeguro(item['tipo'])
                              : 'informativo',
                          importancia: _prioridadAviso(item),
                          fechaInicio: _fechaInicio(item),
                          horaInicio: _horaInicio(item),
                          aplicaA: _textoSeguro(item['aplica_a']).isNotEmpty
                              ? _textoSeguro(item['aplica_a'])
                              : 'todos',
                          afectaA: item['afecta_a'] ?? const [],
                          descripcion: _contenidoAviso(item),
                          mostrarNotificaciones: _mostrarNotificaciones(item),
                          fijado: _fijado(item),
                          estado: val ? 'activo' : 'inactivo',
                        );
                        if (!mounted) return;
                        await _cargarDatos();
                      } catch (e) {
                        if (!mounted) return;
                        _mostrarMensaje(_limpiarError(e), isError: true);
                      }
                    },
                  ),
                  Text(
                    _estadoAviso(item),
                    style: TextStyle(
                      color: isActivo ? Colors.greenAccent : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _tituloAviso(item),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _contenidoAviso(item),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _fechaAviso(item),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showModalVerAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showModalEditarAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showModalEliminarAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: const Column(
        children: [
          Icon(Icons.campaign_outlined, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text(
            'No se encontraron avisos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Intenta cambiar los filtros de búsqueda.',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioridadBadge(String prioridad) {
    Color bg;
    Color text;

    switch (prioridad.toLowerCase()) {
      case 'alta':
        bg = Colors.red.withValues(alpha: 0.15);
        text = Colors.redAccent;
        break;
      case 'media':
        bg = Colors.orange.withValues(alpha: 0.15);
        text = Colors.orangeAccent;
        break;
      default:
        bg = Colors.blue.withValues(alpha: 0.15);
        text = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        prioridad,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showModalCrearAviso() {
    _tituloController.clear();
    _contenidoController.clear();
    _fechaController.text = AvisosAdminService.formatearFecha(DateTime.now());
    _horaController.text = AvisosAdminService.formatearHora(TimeOfDay.now());
    _aplicarAController.clear();
    _prioridadSeleccionada = 'Alta';
    _tipoAvisoSeleccionado = 'informativo';
    _aplicarASeleccionado = 'todos';
    _reiniciarSelecciones();
    _mostrarNotificacion = true;
    _fijarAviso = false;
    _archivoAdjunto = null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF60A5FA),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nuevo aviso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        content: StatefulBuilder(
          builder: (context, setStateModal) {
            return SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModalSectionCard(
                      'Información del aviso',
                      children: [
                        _buildLabelModal('Título del aviso'),
                        TextField(
                          controller: _tituloController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.title,
                            'Ej. Mantenimiento de servidores',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Tipo de aviso'),
                        DropdownButtonFormField<String>(
                          initialValue: _tipoAvisoSeleccionado,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.category_outlined,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'mantenimiento',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.build_rounded,
                                    color: Color(0xFFFF8A00),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Mantenimiento'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'incidente',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Falla/Incidente'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'informativo',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Informativo'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'general',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Normal'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() => _tipoAvisoSeleccionado = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Nivel de importancia'),
                        DropdownButtonFormField<String>(
                          initialValue: _prioridadSeleccionada,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.priority_high_rounded,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Critica',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.priority_high_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Critica'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Alta',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFF97316),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Alta'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Media',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFFFACC15),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Media'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Normal',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF22C55E),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Normal'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() => _prioridadSeleccionada = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelModal('Fecha'),
                                  TextField(
                                    controller: _fechaController,
                                    readOnly: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: _inputDecoration(
                                      Icons.calendar_today_outlined,
                                      'YYYY-MM-DD',
                                    ),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2024),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setStateModal(
                                          () => _fechaController.text =
                                              AvisosAdminService.formatearFecha(
                                                picked,
                                              ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelModal('Hora'),
                                  TextField(
                                    controller: _horaController,
                                    readOnly: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: _inputDecoration(
                                      Icons.access_time_outlined,
                                      'HH:MM',
                                    ),
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (picked != null) {
                                        setStateModal(
                                          () => _horaController.text =
                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Aplicar a'),
                        DropdownButtonFormField<String>(
                          initialValue: _aplicarASeleccionado,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.group_outlined,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos los usuarios'),
                            ),
                            DropdownMenuItem(
                              value: 'oficina',
                              child: Text('Por oficina'),
                            ),
                            DropdownMenuItem(
                              value: 'departamento',
                              child: Text('Por departamento'),
                            ),
                            DropdownMenuItem(
                              value: 'usuarios',
                              child: Text('Usuarios independientes'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() {
                              _aplicarASeleccionado = val;
                              _reiniciarSelecciones();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Destinatarios'),
                        _buildDestinatariosSelector(
                          aplicaA: _aplicarASeleccionado,
                          setStateModal: setStateModal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModalSectionCard(
                      'Contenido del aviso',
                      children: [
                        TextField(
                          controller: _contenidoController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.description_outlined,
                            'Escribe la descripción del aviso...',
                          ),
                        ),
                      ],
                    ),
                    _buildModalSectionCard(
                      'Configuración',
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Mostrar como notificación',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          value: _mostrarNotificacion,
                          activeThumbColor: Color(0xFF60A5FA),
                          onChanged: (val) =>
                              setStateModal(() => _mostrarNotificacion = val),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Fijar notificación',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          value: _fijarAviso,
                          activeThumbColor: Color(0xFFF59E0B),
                          onChanged: (val) =>
                              setStateModal(() => _fijarAviso = val),
                        ),
                      ],
                    ),
                    _buildModalSectionCard(
                      'Adjuntar archivo',
                      children: [
                        GestureDetector(
                          onTap: _seleccionarArchivo,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attach_file_rounded,
                                  color: Colors.blueAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _archivoAdjunto?.name ??
                                        'Adjuntar un archivo para tu aviso',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_archivoAdjunto != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101A2E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vista previa',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_archivoAdjunto != null &&
                                    _esArchivoImagen(_archivoAdjunto!.name) &&
                                    _archivoPreviewBytes != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _archivoPreviewBytes!,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_file_rounded,
                                        color: Colors.blueAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _archivoAdjunto?.name ?? '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
            ),
            onPressed: _crearAviso,
            child: const Text('Publicar aviso'),
          ),
        ],
      ),
    );
  }

  void _showModalVerAviso(Map<String, dynamic> item) {
    final aplicaA = _textoSeguro(item['aplica_a']).isNotEmpty
        ? _textoSeguro(item['aplica_a'])
        : 'todos';
    final afectaA = item['afecta_a'];
    final destinatarios = <String>[];

    if (aplicaA == 'oficina' && afectaA is Map) {
      final ids = afectaA['ids'];
      if (ids is List) {
        for (final id in ids) {
          final match = _oficinas.firstWhere(
            (oficina) => _textoSeguro(oficina['id']) == id.toString(),
            orElse: () => <String, dynamic>{},
          );
          final nombre = _textoSeguro(match['nombre']);
          if (nombre.isNotEmpty) {
            destinatarios.add(nombre);
          }
        }
      }
    } else if (aplicaA == 'departamento' && afectaA is Map) {
      final ids = afectaA['ids'];
      if (ids is List) {
        for (final id in ids) {
          final match = _departamentos.firstWhere(
            (departamento) => _textoSeguro(departamento['id']) == id.toString(),
            orElse: () => <String, dynamic>{},
          );
          final nombre = _textoSeguro(match['nombre']);
          if (nombre.isNotEmpty) {
            destinatarios.add(nombre);
          }
        }
      }
    } else if (aplicaA == 'usuarios' && afectaA is Map) {
      final logins = afectaA['logins'];
      if (logins is List) {
        for (final login in logins) {
          final value = login.toString().trim();
          if (value.isNotEmpty) {
            destinatarios.add(value);
          }
        }
      }
    }

    final archivoUrl = ApiService.storageFileUrl(
      _textoSeguro(item['archivo_url']),
    );
    final archivoNombre = _obtenerNombreArchivo(item['archivo']);
    final extension = archivoUrl.split('?').first.split('.').last.toLowerCase();
    final esImagen = [
      'png',
      'jpg',
      'jpeg',
      'gif',
      'webp',
      'bmp',
    ].contains(extension);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.visibility_rounded,
                    color: Color(0xFF60A5FA),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Detalle del aviso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalSectionCard(
                  'Resumen',
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPrioridadBadge(_prioridadAviso(item)),
                        Text(
                          _fechaAviso(item),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _tituloAviso(item),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _buildModalSectionCard(
                  'Información',
                  children: [
                    _buildInfoDetallada(
                      'Tipo',
                      _tipoAvisoLabel(_textoSeguro(item['tipo'])),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoDetallada('Importancia', _prioridadAviso(item)),
                    const SizedBox(height: 8),
                    _buildInfoDetallada('Fecha', _fechaInicio(item)),
                    const SizedBox(height: 8),
                    _buildInfoDetallada('Hora', _horaInicio(item)),
                    const SizedBox(height: 8),
                    _buildInfoDetallada(
                      'Aplicar a',
                      aplicaA == 'todos'
                          ? 'Todos los usuarios'
                          : aplicaA == 'oficina'
                          ? 'Por oficina'
                          : aplicaA == 'departamento'
                          ? 'Por departamento'
                          : 'Usuarios independientes',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoDetallada(
                      'Destinatarios',
                      destinatarios.isEmpty
                          ? 'Sin destinatarios especificados'
                          : destinatarios.join(', '),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoDetallada('Estado', _estadoAviso(item)),
                    const SizedBox(height: 8),
                    _buildInfoDetallada(
                      'Mostrar notificación',
                      _mostrarNotificaciones(item) ? 'Sí' : 'No',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoDetallada('Fijado', _fijado(item) ? 'Sí' : 'No'),
                  ],
                ),
                _buildModalSectionCard(
                  'Descripción',
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _contenidoAviso(item),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (archivoUrl.isNotEmpty)
                  _buildModalSectionCard(
                    'Archivo adjunto',
                    children: [
                      if (esImagen)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            archivoUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220,
                            errorBuilder: (_, _, _) => Container(
                              height: 150,
                              color: inputBg,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_file_rounded,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  archivoNombre.isNotEmpty
                                      ? archivoNombre
                                      : 'Archivo adjunto',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final uri = Uri.tryParse(archivoUrl);
                                  if (uri != null && await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: const Text('Abrir'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: inputBg),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showModalEditarAviso(Map<String, dynamic> item) {
    final editTitulo = TextEditingController(text: _tituloAviso(item));
    final editContenido = TextEditingController(text: _contenidoAviso(item));
    String editPrioridad = _prioridadAviso(item);
    final editFecha = TextEditingController(text: _fechaInicio(item));
    final editHora = TextEditingController(text: _horaInicio(item));
    final editAplicaA = TextEditingController(
      text: _textoSeguro(item['aplica_a']),
    );
    final tipoActual = _textoSeguro(item['tipo']).isNotEmpty
        ? _textoSeguro(item['tipo']).toLowerCase()
        : 'informativo';
    final prioridadActual = _prioridadAviso(item);
    final mostrarNotif = _mostrarNotificaciones(item);
    final fijado = _fijado(item);

    _tipoAvisoSeleccionado = tipoActual.contains('mantenimiento')
        ? 'mantenimiento'
        : tipoActual.contains('incidente')
        ? 'incidente'
        : tipoActual.contains('informativo')
        ? 'informativo'
        : 'general';
    _prioridadSeleccionada = prioridadActual;
    _aplicarASeleccionado = _textoSeguro(item['aplica_a']).isNotEmpty
        ? _textoSeguro(item['aplica_a'])
        : 'todos';
    _reiniciarSelecciones();
    _aplicarSeleccionDesdeAfectaA(item['afecta_a']);
    _mostrarNotificacion = mostrarNotif;
    _fijarAviso = fijado;
    _aplicarAController.text = (item['afecta_a'] is List)
        ? (item['afecta_a'] as List).map((e) => e.toString()).join(', ')
        : '';
    _fechaController.text = editFecha.text;
    _horaController.text = editHora.text;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF60A5FA),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Editar aviso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        content: StatefulBuilder(
          builder: (context, setStateModal) {
            return SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModalSectionCard(
                      'Información del aviso',
                      children: [
                        _buildLabelModal('Título del aviso'),
                        TextField(
                          controller: editTitulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(Icons.title, ''),
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Tipo de aviso'),
                        DropdownButtonFormField<String>(
                          initialValue: _tipoAvisoSeleccionado,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.category_outlined,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'mantenimiento',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.build_rounded,
                                    color: Color(0xFFFF8A00),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Mantenimiento'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'incidente',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Falla/Incidente'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'informativo',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Informativo'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'general',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Normal'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() => _tipoAvisoSeleccionado = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Nivel de importancia'),
                        DropdownButtonFormField<String>(
                          initialValue: editPrioridad,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.priority_high_rounded,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Critica',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.priority_high_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Critica'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Alta',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFF97316),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Alta'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Media',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFFFACC15),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Media'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Normal',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF22C55E),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Normal'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() => editPrioridad = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelModal('Fecha'),
                                  TextField(
                                    controller: editFecha,
                                    readOnly: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: _inputDecoration(
                                      Icons.calendar_today_outlined,
                                      'YYYY-MM-DD',
                                    ),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            DateTime.tryParse(editFecha.text) ??
                                            DateTime.now(),
                                        firstDate: DateTime(2024),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setStateModal(
                                          () => editFecha.text =
                                              AvisosAdminService.formatearFecha(
                                                picked,
                                              ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelModal('Hora'),
                                  TextField(
                                    controller: editHora,
                                    readOnly: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: _inputDecoration(
                                      Icons.access_time_outlined,
                                      'HH:MM',
                                    ),
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (picked != null) {
                                        setStateModal(
                                          () => editHora.text =
                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Aplicar a'),
                        DropdownButtonFormField<String>(
                          initialValue: _aplicarASeleccionado,
                          dropdownColor: cardDark,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.group_outlined,
                            '',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos los usuarios'),
                            ),
                            DropdownMenuItem(
                              value: 'oficina',
                              child: Text('Por oficina'),
                            ),
                            DropdownMenuItem(
                              value: 'departamento',
                              child: Text('Por departamento'),
                            ),
                            DropdownMenuItem(
                              value: 'usuarios',
                              child: Text('Usuarios independientes'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setStateModal(() {
                              _aplicarASeleccionado = val;
                              _reiniciarSelecciones();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabelModal('Destinatarios'),
                        _buildDestinatariosSelector(
                          aplicaA: _aplicarASeleccionado,
                          setStateModal: setStateModal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModalSectionCard(
                      'Contenido del aviso',
                      children: [
                        TextField(
                          controller: editContenido,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            Icons.notes,
                            'Escribe la descripción del aviso...',
                          ),
                        ),
                      ],
                    ),
                    _buildModalSectionCard(
                      'Configuración',
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Mostrar como notificación',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          value: _mostrarNotificacion,
                          activeThumbColor: Color(0xFF60A5FA),
                          onChanged: (val) =>
                              setStateModal(() => _mostrarNotificacion = val),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Fijar notificación',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          value: _fijarAviso,
                          activeThumbColor: Color(0xFFF59E0B),
                          onChanged: (val) =>
                              setStateModal(() => _fijarAviso = val),
                        ),
                      ],
                    ),
                    _buildModalSectionCard(
                      'Adjuntar archivo',
                      children: [
                        GestureDetector(
                          onTap: _seleccionarArchivo,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attach_file_rounded,
                                  color: Colors.blueAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _archivoAdjunto?.name ??
                                        'Adjuntar un archivo para tu aviso',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_archivoAdjunto != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101A2E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vista previa',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_archivoAdjunto != null &&
                                    _esArchivoImagen(_archivoAdjunto!.name) &&
                                    _archivoPreviewBytes != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _archivoPreviewBytes!,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_file_rounded,
                                        color: Colors.blueAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _archivoAdjunto?.name ?? '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
            ),
            onPressed: () async {
              await _actualizarAvisoDesdeFormulario(
                item,
                editTitulo,
                editContenido,
                editPrioridad,
              );
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  void _showModalEliminarAviso(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.25)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Eliminar aviso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
                ),
                child: const Text(
                  'Esta acción eliminará el aviso de forma permanente y no podrá recuperarse.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aviso a eliminar',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tituloAviso(item),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _eliminarAviso(item);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildModalSectionCard(
    String title, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF111C31),
            const Color(0xFF0D1729).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF60A5FA),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoDetallada(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1324),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelModal(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0B1324),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  Widget _buildCounterChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCounterDotChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
