import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/loading_screen.dart';
import 'home_screen.dart' as home;

class DetallesScreen extends StatefulWidget {
  const DetallesScreen({
    super.key,
    this.ticket,
  });

  final Map<String, dynamic>? ticket;

  @override
  State<DetallesScreen> createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _ticket;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final id = _toInt(widget.ticket?['id']);

      Map<String, dynamic> data = {};

      if (id != null) {
        final respuesta = await TicketService.obtenerTicket(id);
        final raw = respuesta['ticket'] ?? respuesta['data'];
        if (raw is Map) {
          data = Map<String, dynamic>.from(raw);
        }
      }

      if (data.isEmpty && widget.ticket != null) {
        data = Map<String, dynamic>.from(widget.ticket!);
      }

      if (!mounted) return;

      setState(() {
        _ticket = data;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  String _asText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      final parts = <String>[];
      for (final item in value) {
        final text = _asText(item);
        if (text.isNotEmpty) parts.add(text);
      }
      return parts.join('\n');
    }
    if (value is Map) {
      final candidates = [
        value['valor'],
        value['value'],
        value['texto'],
        value['text'],
        value['descripcion'],
        value['description'],
        value['mensaje'],
        value['message'],
        value['titulo'],
        value['title'],
        value['nombre'],
        value['name'],
        value['email'],
        value['correo'],
        value['telefono'],
        value['phone'],
        value['solucion'],
        value['resultado'],
        value['comentario'],
        value['firma'],
        value['signature'],
        value['url'],
        value['path'],
        value['archivo'],
        value['file'],
      ];

      for (final candidate in candidates) {
        final text = _asText(candidate);
        if (text.isNotEmpty) return text;
      }

      final nested = <String>[];
      for (final entry in value.entries) {
        final text = _asText(entry.value);
        if (text.isNotEmpty) nested.add(text);
      }
      if (nested.isNotEmpty) return nested.join('\n');
    }
    return '';
  }

  String _field(Map<String, dynamic> source, List<String> keys, {String fallback = 'No disponible'}) {
    final stack = <Map<String, dynamic>>[source];
    final seen = <String>{};

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      final id = current.hashCode.toString();
      if (!seen.add(id)) continue;

      for (final key in keys) {
        final value = current[key];
        final text = _asText(value);
        if (text.isNotEmpty) return text;
      }

      for (final value in current.values) {
        if (value is Map && value is! List) {
          stack.add(Map<String, dynamic>.from(value));
        }
      }
    }

    return fallback;
  }

  String _date(dynamic value) {
    if (value == null) return 'No disponible';
    final text = value.toString().trim();
    if (text.isEmpty) return 'No disponible';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    final mes = _mesNombre(parsed.month);
    return '${parsed.day.toString().padLeft(2, '0')} $mes ${parsed.year}';
  }

  String _mesNombre(int mes) {
    const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return mes >= 1 && mes <= 12 ? meses[mes] : '';
  }

  Color _statusColor(String estado) {
    final value = estado.toLowerCase();
    if (value.contains('abierto')) return const Color(0xFFFBBF24);
    if (value.contains('proceso')) return const Color(0xFF60A5FA);
    if (value.contains('solucion')) return const Color(0xFF34D399);
    if (value.contains('cancel')) return const Color(0xFFF87171);
    return const Color(0xFF93C5FD);
  }

  String _signatureUrl(Map<String, dynamic> source) {
    final raw = _field(
      source,
      [
        'firma',
        'firma_url',
        'firmaUsuario',
        'firma_usuario',
        'signature',
        'signature_url',
        'firma_path',
      ],
      fallback: '',
    );

    if (raw.isEmpty || raw == 'No disponible') return '';
    final url = raw.startsWith('http') ? raw : ApiService.firmaUrl(raw);
    return url;
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const home.HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    if (_cargando) {
      return const LoadingScreen(mensaje: 'Cargando detalle del ticket...');
    }

    if (_error != null || _ticket == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF060A17),
        appBar: isDesktop
            ? null
            : AppBar(
                backgroundColor: const Color(0xFF0B1021),
                elevation: 0,
                title: const home.AppLogo(fontSize: 20),
                leading: IconButton(
                  onPressed: _goToHome,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                actions: [
                  home.UserHeaderActions(
                    onNotifications: () => home.showUserNotifications(context),
                    unreadCount: 0,
                  ),
                ],
              ),
        drawer: isDesktop ? null : const home.AppNavigationDrawer(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No se pudo cargar la información del ticket.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _goToHome,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Regresar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ticket = _ticket!;
    final folio = _field(ticket, ['folio', 'folio_ticket', 'ticket', 'numero'], fallback: 'Sin folio');
    final titulo = _field(ticket, ['titulo', 'title', 'nombre', 'name'], fallback: 'Sin título');
    final descripcion = _field(ticket, ['descripcion', 'description', 'detalle', 'problema', 'motivo', 'issue'], fallback: 'Sin descripción');
    final estado = _field(ticket, ['estado', 'status'], fallback: 'Sin estado');
    final prioridad = _field(ticket, ['prioridad', 'priority'], fallback: 'Sin prioridad');
    final tipoFalla = _field(ticket, ['tipo_falla', 'tipo', 'categoria', 'tipo_ticket'], fallback: 'Sin tipo');
    final departamento = _field(ticket, ['departamento', 'departamento_nombre', 'nombre_departamento'], fallback: 'No especificado');
    final oficina = _field(ticket, ['oficina', 'oficina_nombre', 'nombre_oficina'], fallback: 'No especificada');
    final equipo = _field(ticket, ['equipo', 'equipo_nombre', 'nombre_equipo', 'team', 'team_name'], fallback: 'No especificado');
    final fecha = _date(ticket['created_at'] ?? ticket['fecha_creacion']);
    final fechaActualizacion = _date(ticket['updated_at'] ?? ticket['fecha_actualizacion'] ?? ticket['fecha_ultimo_cambio']);
    final tecnico = _field(ticket, ['tecnico', 'tecnico_nombre', 'nombre_tecnico', 'asignado_a', 'asignado_a_usuario'], fallback: 'No asignado');
    final solucion = _field(ticket, ['solucion', 'resultado', 'comentario_solucion', 'seguimiento', 'respuesta', 'detalle_solucion'], fallback: 'Pendiente');
    final nombreUsuario = _field(ticket, ['nombre_usuario', 'usuario_nombre', 'nombre', 'user_name', 'login', 'usuario'], fallback: 'No disponible');
    final emailUsuario = _field(ticket, ['email', 'correo', 'email_usuario', 'correo_usuario'], fallback: 'No disponible');
    final telefonoUsuario = _field(ticket, ['telefono', 'phone', 'telefono_usuario', 'celular'], fallback: 'No disponible');
    final firmaUrl = _signatureUrl(ticket);
    final mostrarEquipo = tipoFalla.toLowerCase().contains('equipo') || equipo.toLowerCase() != 'no especificado';

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const home.AppLogo(fontSize: 20),
              leading: IconButton(
                onPressed: _goToHome,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                home.UserHeaderActions(
                  onNotifications: () => home.showUserNotifications(context),
                  unreadCount: 0,
                ),
              ],
            ),
      drawer: isDesktop ? null : const home.AppNavigationDrawer(),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(width: 260, child: home.AppNavigationDrawer()),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _goToHome,
                                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF111B2F)),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detalle del ticket',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0E1A30), Color(0xFF0F172A)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final available = constraints.maxWidth;
                                  final hasSpace = available > 300;
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: const Color(0xFF93C5FD).withValues(alpha: 0.28)),
                                          ),
                                          child: Text(
                                            folio,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFDBEAFE),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        constraints: hasSpace ? const BoxConstraints(maxWidth: 140) : const BoxConstraints(maxWidth: 110),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _statusColor(estado).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: _statusColor(estado).withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          estado,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: _statusColor(estado),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Text(
                                titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _infoChip('Tipo', tipoFalla, Colors.blue),
                                  _infoChip('Prioridad', prioridad, _prioridadColor(prioridad)),
                                  if (mostrarEquipo) _infoChip('Equipo', equipo, Colors.tealAccent),
                                  _infoChip('Fecha', fecha, Colors.purpleAccent),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = isDesktop ? 4 : (constraints.maxWidth < 420 ? 2 : 3);
                            final gap = 14.0;
                            final totalGap = gap * (columns - 1);
                            final tileWidth = (constraints.maxWidth - totalGap) / columns;

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                SizedBox(width: tileWidth, child: _summaryTile('Tipo de falla', tipoFalla, Icons.build_circle_outlined, Colors.blue)),
                                SizedBox(width: tileWidth, child: _summaryTile('Prioridad', prioridad, Icons.flag_outlined, _prioridadColor(prioridad))),
                                SizedBox(width: tileWidth, child: _summaryTile('Departamento', departamento, Icons.business_center_outlined, Colors.indigo)),
                                if (mostrarEquipo) SizedBox(width: tileWidth, child: _summaryTile('Equipo', equipo, Icons.devices_outlined, Colors.teal)),
                                SizedBox(width: tileWidth, child: _summaryTile('Oficina', oficina, Icons.location_city_outlined, Colors.cyan)),
                                SizedBox(width: tileWidth, child: _summaryTile('Técnico', tecnico, Icons.person_outline_rounded, Colors.purple)),
                                SizedBox(width: tileWidth, child: _summaryTile('Actualización', fechaActualizacion, Icons.event_available_outlined, Colors.orange)),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _sectionCard(
                          title: 'Información reportada por el usuario',
                          icon: Icons.person_search_outlined,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = isDesktop ? 3 : (constraints.maxWidth < 520 ? 1 : 2);
                              final gap = 12.0;
                              final totalGap = gap * (columns - 1);
                              final tileWidth = (constraints.maxWidth - totalGap) / columns;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  SizedBox(width: tileWidth, child: _detailTile('Nombre', nombreUsuario)),
                                  SizedBox(width: tileWidth, child: _detailTile('Correo', emailUsuario)),
                                  SizedBox(width: tileWidth, child: _detailTile('Teléfono', telefonoUsuario)),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sectionCard(
                          title: 'Descripción del problema',
                          icon: Icons.report_problem_outlined,
                          child: Text(
                            descripcion,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sectionCard(
                          title: 'Solución / seguimiento',
                          icon: Icons.task_alt_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                solucion,
                                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                              ),
                              if (firmaUrl.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                const Text(
                                  'Firma',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1324),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      firmaUrl,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Container(
                                        height: 220,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF101A2E),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.draw_rounded, color: Colors.white38, size: 38),
                                            SizedBox(height: 8),
                                            Text(
                                              'No se encontró la firma',
                                              style: TextStyle(color: Colors.white38),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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

  Widget _infoChip(String label, String value, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: value,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: const Color(0xFF93C5FD), size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Color _prioridadColor(String prioridad) {
    final value = prioridad.toLowerCase();
    if (value.contains('crítica') || value.contains('critica')) return Colors.redAccent;
    if (value.contains('alta')) return Colors.orangeAccent;
    if (value.contains('media')) return const Color(0xFFFBBF24);
    return Colors.greenAccent;
  }
}
