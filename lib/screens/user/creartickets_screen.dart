import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/crear_ticket_service.dart';
import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
import 'avisos_screen.dart';
import 'home_screen.dart';
import 'mistickets_screen.dart';
import 'perfil_screen.dart';

class CrearticketsScreen extends StatefulWidget {
  const CrearticketsScreen({super.key});

  @override
  State<CrearticketsScreen> createState() => _CrearticketsScreenState();
}

class _CrearticketsScreenState extends State<CrearticketsScreen> {
  String selectedPriority = 'Media';
  String? selectedFailureType;
  String? selectedEquipo;

  bool afectaOtros = false;
  bool esRecurrente = false;
  bool enviandoTicket = false;
  bool cargandoEquipos = false;

  List<Map<String, dynamic>> equipos = [];

  final List<PlatformFile> evidencias = [];

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController =
      TextEditingController();
  final TextEditingController comentariosController =
      TextEditingController();

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    comentariosController.dispose();
    super.dispose();
  }

  Future<void> _cargarEquipos() async {
    if (cargandoEquipos || enviandoTicket) {
      return;
    }

    setState(() {
      cargandoEquipos = true;
      selectedEquipo = null;
    });

    try {
      final resultado = await CrearTicketService.obtenerEquipos();

      if (!mounted) {
        return;
      }

      setState(() {
        equipos = resultado;
        cargandoEquipos = false;
      });

      if (equipos.isEmpty) {
        _mostrarMensaje(
          'No tienes equipos vinculados disponibles',
          esError: true,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        equipos = [];
        cargandoEquipos = false;
        selectedEquipo = null;
      });

      var mensaje = e.toString();

      if (mensaje.startsWith('Exception: ')) {
        mensaje = mensaje.substring('Exception: '.length);
      }

      if (mensaje.trim().isEmpty) {
        mensaje = 'No se pudieron cargar los equipos';
      }

      _mostrarMensaje(
        mensaje,
        esError: true,
        duracion: const Duration(seconds: 5),
      );
    }
  }

Future<void> _seleccionarEvidencias() async {
  if (enviandoTicket) {
    return;
  }

  try {
    final archivos = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'mp4',
      ],
    );

    if (!mounted || archivos.isEmpty) {
      return;
    }

    final nuevasEvidencias = <PlatformFile>[];

    for (final archivo in archivos) {
      try {
        final bytes = await archivo.readAsBytes();

        if (bytes.isEmpty) {
          debugPrint(
            'No se pudieron leer los bytes de: ${archivo.name}',
          );
          continue;
        }

        nuevasEvidencias.add(archivo);

        debugPrint(
          'Archivo seleccionado: ${archivo.name}',
        );

        debugPrint(
          'Bytes: ${bytes.length}',
        );
      } catch (e) {
        debugPrint(
          'Error leyendo ${archivo.name}: $e',
        );
      }
    }

    if (nuevasEvidencias.isEmpty) {
      _mostrarMensaje(
        'No se pudieron leer los archivos seleccionados',
        esError: true,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      evidencias.addAll(nuevasEvidencias);
    });

    debugPrint(
      'Total de evidencias: ${evidencias.length}',
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    debugPrint(
      'Error seleccionando evidencias: $e',
    );

    _mostrarMensaje(
      'No se pudieron seleccionar los archivos',
      esError: true,
    );
  }
}

  void _eliminarEvidencia(int index) {
    if (enviandoTicket) {
      return;
    }

    if (index < 0 || index >= evidencias.length) {
      return;
    }

    setState(() {
      evidencias.removeAt(index);
    });
  }

  Future<void> _crearTicket() async {
    if (enviandoTicket) {
      return;
    }

    FocusScope.of(context).unfocus();

    final titulo = tituloController.text.trim();
    final descripcion = descripcionController.text.trim();
    final comentarios = comentariosController.text.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje(
        'Ingresa el título del ticket',
        esError: true,
      );
      return;
    }

    final tipoFalla = selectedFailureType?.trim();

    if (tipoFalla == null || tipoFalla.isEmpty) {
      _mostrarMensaje(
        'Selecciona el tipo de falla',
        esError: true,
      );
      return;
    }

    if (tipoFalla.toLowerCase() == 'hardware' &&
        (selectedEquipo == null || selectedEquipo!.trim().isEmpty)) {
      _mostrarMensaje(
        'Selecciona el equipo',
        esError: true,
      );
      return;
    }

    if (descripcion.isEmpty) {
      _mostrarMensaje(
        'Ingresa una descripción del problema',
        esError: true,
      );
      return;
    }

    setState(() {
      enviandoTicket = true;
    });

    try {
      final response = await CrearTicketService.crearTicket(
        titulo: titulo,
        tipoFalla: tipoFalla,
        equipo: tipoFalla.toLowerCase() == 'hardware'
            ? selectedEquipo
            : null,
        prioridad: selectedPriority,
        descripcion: descripcion,
        afectaOtros: afectaOtros,
        esRecurrente: esRecurrente,
        comentarios: comentarios.isEmpty ? null : comentarios,
        evidencias: evidencias.isEmpty
            ? null
            : List<PlatformFile>.from(evidencias),
      );

      if (!mounted) {
        return;
      }

      final mensajeBackend = response['message']?.toString().trim();

      final mensaje =
          mensajeBackend != null && mensajeBackend.isNotEmpty
              ? mensajeBackend
              : 'El ticket fue creado correctamente';

      _limpiarFormulario();

      await _mostrarDialogoExito(mensaje);
    } catch (e) {
      if (!mounted) {
        return;
      }

      var mensaje = e.toString();

      if (mensaje.startsWith('Exception: ')) {
        mensaje = mensaje.substring('Exception: '.length);
      }

      if (mensaje.trim().isEmpty) {
        mensaje = 'No se pudo crear el ticket';
      }

      _mostrarMensaje(
        mensaje,
        esError: true,
        duracion: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviandoTicket = false;
        });
      }
    }
  }

  void _limpiarFormulario() {
    tituloController.clear();
    descripcionController.clear();
    comentariosController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      selectedPriority = 'Media';
      selectedFailureType = null;
      selectedEquipo = null;
      afectaOtros = false;
      esRecurrente = false;
      cargandoEquipos = false;
      equipos = [];
      evidencias.clear();
    });
  }

  Future<void> _mostrarDialogoExito(String mensaje) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1021),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ticket creado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    navigateWithLoading(context, const MisticketsScreen(), mensaje: 'Cargando tus tickets...');
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
    Duration duracion = const Duration(seconds: 3),
  }) {
    if (!mounted) {
      return;
    }

    showUserMessage(context, mensaje, isError: esError);
  }

  void _irAInicio() {
    if (enviandoTicket) {
      return;
    }

    navigateWithLoading(context, const HomeScreen(), mensaje: 'Cargando inicio...');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;

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
              actions: [
                UserHeaderActions(onNotifications: () => showUserNotifications(context)),
              ],
            ),
      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(
              activeRoute: 'Crear ticket',
            ),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(
                activeRoute: 'Crear ticket',
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? 24 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),
                  const SizedBox(height: 24),
                  _buildUserInfoCard(),
                  const SizedBox(height: 20),
                  _buildFormAndEvidenceLayout(isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear nuevo ticket',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Nuevo ticket / Dashboard',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (isDesktop)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1427),
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _mostrarNotificaciones,
              ),
              const SizedBox(width: 16),
              UserHeaderActions(onNotifications: () => showUserNotifications(context)),
            ],
          ),
      ],
    );
  }

  void _mostrarNotificaciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1021),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 40),
              SizedBox(height: 10),
              Text(
                'No hay notificaciones disponibles.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Información del usuario',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                final cardWidth =
                    (constraints.maxWidth - 36) / 4;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _userFieldCard(
                      'Nombre',
                      'Juan Perez',
                      Icons.person_outline,
                      cardWidth,
                    ),
                    _userFieldCard(
                      'Departamento',
                      'administracion',
                      Icons.apartment_outlined,
                      cardWidth,
                    ),
                    _userFieldCard(
                      'Oficina / Sucursal',
                      'Reynosa',
                      Icons.location_on_outlined,
                      cardWidth,
                    ),
                    _userFieldCard(
                      'Empresa',
                      'Cymez',
                      Icons.account_balance_outlined,
                      cardWidth,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _userFieldCard(
                    'Nombre',
                    'Juan Perez',
                    Icons.person_outline,
                    constraints.maxWidth,
                  ),
                  const SizedBox(height: 12),
                  _userFieldCard(
                    'Departamento',
                    'administracion',
                    Icons.apartment_outlined,
                    constraints.maxWidth,
                  ),
                  const SizedBox(height: 12),
                  _userFieldCard(
                    'Oficina / Sucursal',
                    'Reynosa',
                    Icons.location_on_outlined,
                    constraints.maxWidth,
                  ),
                  const SizedBox(height: 12),
                  _userFieldCard(
                    'Empresa',
                    'Cymez',
                    Icons.account_balance_outlined,
                    constraints.maxWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _userFieldCard(
    String label,
    String value,
    IconData icon,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormAndEvidenceLayout(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: _buildTicketFormCard(),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: _buildEvidenceCard(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTicketFormCard(),
        const SizedBox(height: 20),
        _buildEvidenceCard(),
      ],
    );
  }

  Widget _buildTicketFormCard() {
    final isHardware =
        selectedFailureType?.toLowerCase() == 'hardware';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Información del ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _formLabel('Título del ticket'),
          const SizedBox(height: 8),
          TextField(
            controller: tituloController,
            enabled: !enviandoTicket,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Ej. Impresora de administración sin conexión',
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildFailureType(),
                    if (isHardware) ...[
                      const SizedBox(height: 20),
                      _buildEquipo(),
                    ],
                    const SizedBox(height: 20),
                    _buildPriority(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildFailureType(),
                        if (isHardware) ...[
                          const SizedBox(height: 20),
                          _buildEquipo(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: _buildPriority(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _formLabel('Descripción del problema'),
          const SizedBox(height: 8),
          TextField(
            controller: descripcionController,
            enabled: !enviandoTicket,
            maxLines: 4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Describe detalladamente el problema que estás experimentando...',
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildYesNoSection(
                      '¿Afecta a otros usuarios?',
                      afectaOtros,
                      (value) {
                        if (!enviandoTicket) {
                          setState(() {
                            afectaOtros = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildYesNoSection(
                      '¿Es una falla recurrente?',
                      esRecurrente,
                      (value) {
                        if (!enviandoTicket) {
                          setState(() {
                            esRecurrente = value;
                          });
                        }
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildYesNoSection(
                      '¿Afecta a otros usuarios?',
                      afectaOtros,
                      (value) {
                        if (!enviandoTicket) {
                          setState(() {
                            afectaOtros = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildYesNoSection(
                      '¿Es una falla recurrente?',
                      esRecurrente,
                      (value) {
                        if (!enviandoTicket) {
                          setState(() {
                            esRecurrente = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _formLabel('Comentarios adicionales'),
          const SizedBox(height: 8),
          TextField(
            controller: comentariosController,
            enabled: !enviandoTicket,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Información adicional que pueda ayudar a resolver el problema (opcional)...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel('Tipo de falla'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedFailureType,
          isExpanded: true,
          dropdownColor: const Color(0xFF0B1021),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          decoration: _inputDecoration(
            'Selecciona el tipo de falla',
          ),
          items: const [
            DropdownMenuItem(
              value: 'hardware',
              child: Text(
                'Hardware / Equipo',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'redes',
              child: Text(
                'Redes / Internet',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'software',
              child: Text(
                'Sistemas / Software',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: enviandoTicket
              ? null
              : (value) async {
                  setState(() {
                    selectedFailureType = value;
                    selectedEquipo = null;
                    equipos = [];
                  });

                  if (value?.toLowerCase() == 'hardware') {
                    await _cargarEquipos();
                  }
                },
        ),
      ],
    );
  }

  Widget _buildEquipo() {
    final valoresValidos = equipos
        .map(
          (equipo) =>
              equipo['nombre_equipo']?.toString().trim() ?? '',
        )
        .where(
          (nombre) => nombre.isNotEmpty,
        )
        .toSet()
        .toList();

    final valorSeleccionado =
        valoresValidos.contains(selectedEquipo)
            ? selectedEquipo
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel('Equipo'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: valorSeleccionado,
          isExpanded: true,
          dropdownColor: const Color(0xFF0B1021),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          decoration: _inputDecoration(
            cargandoEquipos
                ? 'Cargando equipos...'
                : valoresValidos.isEmpty
                    ? 'No hay equipos disponibles'
                    : 'Selecciona el equipo',
          ),
          items: equipos
              .map<DropdownMenuItem<String>?>(
                (equipo) {
                  final nombre =
                      equipo['nombre_equipo']
                              ?.toString()
                              .trim() ??
                          '';

                  final idEquipo =
                      equipo['id_equipo']
                              ?.toString()
                              .trim() ??
                          '';

                  if (nombre.isEmpty) {
                    return null;
                  }

                  final texto = idEquipo.isNotEmpty
                      ? '$nombre ($idEquipo)'
                      : nombre;

                  return DropdownMenuItem<String>(
                    value: nombre,
                    child: Text(
                      texto,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              )
              .whereType<DropdownMenuItem<String>>()
              .toList(),
          onChanged: enviandoTicket ||
                  cargandoEquipos ||
                  valoresValidos.isEmpty
              ? null
              : (value) {
                  setState(() {
                    selectedEquipo = value;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildPriority() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel('Prioridad'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _priorityBtn(
                'Crítica',
                'Critica',
                Icons.warning_amber_rounded,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 6),
              _priorityBtn(
                'Alta',
                'Alta',
                Icons.arrow_upward_rounded,
                const Color(0xFFF97316),
              ),
              const SizedBox(width: 6),
              _priorityBtn(
                'Media',
                'Media',
                Icons.remove_rounded,
                const Color(0xFFEAB308),
              ),
              const SizedBox(width: 6),
              _priorityBtn(
                'Normal',
                'Normal',
                Icons.check_circle_outline_rounded,
                const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoSection(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(title),
        const SizedBox(height: 8),
        _yesNoToggle(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Evidencia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Adjunta evidencia de la falla',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                enviandoTicket ? null : _seleccionarEvidencias,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 36,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF060A17),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_outlined,
                    size: 36,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Haz click para seleccionar archivos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG, JPEG, PNG, PDF o MP4',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (evidencias.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(
              evidencias.length,
              (index) {
                final archivo = evidencias[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060A17),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          archivo.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity:
                            VisualDensity.compact,
                        onPressed: enviandoTicket
                            ? null
                            : () =>
                                _eliminarEvidencia(index),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 350) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white12,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          enviandoTicket ? null : _irAInicio,
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSendButton(),
                  ],
                );
              }

              return Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white12,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        enviandoTicket ? null : _irAInicio,
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSendButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        disabledBackgroundColor:
            const Color(0xFF1E3A8A),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: enviandoTicket ? null : _crearTicket,
      icon: enviandoTicket
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
          : const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
      label: Text(
        enviandoTicket ? 'Enviando...' : 'Enviar ticket',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _formLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      filled: true,
      fillColor: const Color(0xFF060A17),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.white12,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.white12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _priorityBtn(
    String label,
    String valorBackend,
    IconData icon,
    Color color,
  ) {
    final isSelected =
        selectedPriority == valorBackend;

    return InkWell(
      onTap: enviandoTicket
          ? null
          : () {
              setState(() {
                selectedPriority = valorBackend;
              });
            },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yesNoToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: enviandoTicket
                    ? null
                    : () => onChanged(true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value
                        ? const Color(0xFF1E3A8A)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Sí',
                    style: TextStyle(
                      color:
                          value ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: enviandoTicket
                    ? null
                    : () => onChanged(false),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !value
                        ? const Color(0xFF1E3A8A)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color:
                          !value ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final picture = snapshot.data?['picture']?.toString() ?? '';
        final imageUrl = ApiService.profileImageUrl(picture);
        return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2563EB),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF1E3A8A),
        backgroundImage: imageUrl.isEmpty
            ? const AssetImage('assets/images/user.png')
            : NetworkImage('$imageUrl?profile_refresh=${picture.hashCode}'),
        child: null,
      ),
    );
      },
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
    this.activeRoute = 'Inicio',
  });

  void _navegar(
    BuildContext context,
    String route,
    Widget screen,
  ) {
    if (activeRoute == route) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return;
    }

    navigateWithLoading(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
  backgroundColor: const Color(0xFF0B1021),
  child: SafeArea(
    child: Container(
      color: const Color(0xFF0B1021),
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // LOGO
          // ============================================================

          const AppLogo(
            fontSize: 26,
          ),

          const SizedBox(height: 24),

          // ============================================================
          // USUARIO
          // ============================================================

          const Row(
            children: [
              UserAvatar(
                radius: 20,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juan Pérez',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      'Administración',
                      overflow: TextOverflow.ellipsis,
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

          // ============================================================
          // INICIO
          // ============================================================

          _drawerItem(
            icon: Icons.home_rounded,
            title: 'Inicio',
            isActive: activeRoute == 'Inicio',
            onTap: () {
              _navegar(
                context,
                'Inicio',
                const HomeScreen(),
              );
            },
          ),

          // ============================================================
          // MIS TICKETS
          // ============================================================

          _drawerItem(
            icon: Icons.confirmation_number_outlined,
            title: 'Mis tickets',
            isActive: activeRoute == 'Mis tickets',
            onTap: () {
              _navegar(
                context,
                'Mis tickets',
                const MisticketsScreen(),
              );
            },
          ),

          // ============================================================
          // CREAR TICKET
          // ============================================================

          _drawerItem(
            icon: Icons.build_outlined,
            title: 'Crear ticket',
            isActive: activeRoute == 'Crear ticket',
            onTap: () {
              _navegar(
                context,
                'Crear ticket',
                const CrearticketsScreen(),
              );
            },
          ),

          // ============================================================
          // AVISOS
          // ============================================================

          _drawerItem(
            icon: Icons.warning_amber_rounded,
            title: 'Avisos',
            isActive: activeRoute == 'Avisos',
            onTap: () {
              _navegar(
                context,
                'Avisos',
                const AvisosScreen(),
              );
            },
          ),

          // ============================================================
          // MI PERFIL
          // ============================================================

          _drawerItem(
            icon: Icons.person_outline_rounded,
            title: 'Mi perfil',
            isActive: activeRoute == 'Mi perfil',
            onTap: () {
              _navegar(
                context,
                'Mi perfil',
                const MiPerfilScreen(),
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 1,
          ),

          // ============================================================
          // CERRAR SESIÓN
          // ============================================================

          _drawerItem(
            icon: Icons.logout_rounded,
            title: 'Cerrar sesión',
            color: Colors.white70,
            onTap: () async {
              // Cerrar Drawer
              Navigator.pop(context);

              // Limpiar sesión
              await SessionService.clearSession();

              if (!context.mounted) {
                return;
              }

              // Regresar al inicio
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
    final itemColor =
        color ?? (isActive ? Colors.white : Colors.grey);

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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}