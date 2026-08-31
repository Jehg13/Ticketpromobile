import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'backup_screen.dart';
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

  final List<SolicitudCambio> solicitudes = [
    SolicitudCambio(
      folio: '4',
      solicitante: 'Fernando Reyes',
      email: 'fernando.reyes@gmail.com',
      puesto: 'Gerente Ti',
      campo: 'Numeroempleado',
      estado: 'En revisión',
      fecha: '29/08/2026 10:48 PM',
      fechaTabla: '29 Aug 2026\n10:48 PM',
      infoActual: '201478',
      infoSolicitada: '259012',
      motivo: 'Esta equivocado',
    ),
    SolicitudCambio(
      folio: '3',
      solicitante: 'Fernando Reyes',
      email: 'fernando.reyes@gmail.com',
      puesto: 'Gerente Ti',
      campo: 'Telefono',
      estado: 'Aprobada',
      fecha: '21/08/2026 03:06 PM',
      fechaTabla: '21 Aug 2026\n03:06 PM',
      infoActual: '8991234567',
      infoSolicitada: '8999876543',
      motivo: 'Cambio de línea telefónica',
    ),
    SolicitudCambio(
      folio: '2',
      solicitante: 'Fernando Reyes',
      email: 'fernando.reyes@gmail.com',
      puesto: 'Gerente Ti',
      campo: 'Telefono',
      estado: 'Rechazada',
      fecha: '21/08/2026 02:54 PM',
      fechaTabla: '21 Aug 2026\n02:54 PM',
      infoActual: '8991234567',
      infoSolicitada: '0000000000',
      motivo: 'Número inválido',
    ),
    SolicitudCambio(
      folio: '1',
      solicitante: 'Fernando Reyes',
      email: 'fernando.reyes@gmail.com',
      puesto: 'Gerente Ti',
      campo: 'Telefono',
      estado: 'En revisión',
      fecha: '21/08/2026 02:52 PM',
      fechaTabla: '21 Aug 2026\n02:52 PM',
      infoActual: '8991234567',
      infoSolicitada: '8991112233',
      motivo: 'Actualización personal',
    ),
  ];

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<SolicitudCambio> get solicitudesFiltradas {
    return solicitudes.where((solicitud) {
      final coincideFiltro =
          selectedFilter == 'Todos' ||
          solicitud.estado == selectedFilter;

      final coincideBusqueda =
          searchQuery.isEmpty ||
          solicitud.folio.toLowerCase().contains(searchQuery) ||
          solicitud.solicitante.toLowerCase().contains(searchQuery) ||
          solicitud.email.toLowerCase().contains(searchQuery) ||
          solicitud.campo.toLowerCase().contains(searchQuery);

      return coincideFiltro && coincideBusqueda;
    }).toList();
  }

  int get totalSolicitudes => solicitudes.length;

  int get solicitudesRevision =>
      solicitudes.where((item) => item.estado == 'En revisión').length;

  int get solicitudesAprobadas =>
      solicitudes.where((item) => item.estado == 'Aprobada').length;

  int get solicitudesRechazadas =>
      solicitudes.where((item) => item.estado == 'Rechazada').length;

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
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: primaryBlue,
            child: Text(
              'JH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(activeMenu: 'Cambios'),
      body: SingleChildScrollView(
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
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  KPIStatCard(
                    title: 'Total de solicitudes',
                    count: '$totalSolicitudes',
                    icon: Icons.folder_open_outlined,
                    iconColor: accentBlue,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'En revisión',
                    count: '$solicitudesRevision',
                    icon: Icons.access_time,
                    iconColor: Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Aprobadas',
                    count: '$solicitudesAprobadas',
                    icon: Icons.check_circle_outline,
                    iconColor: greenAccent,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Rechazadas',
                    count: '$solicitudesRechazadas',
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
                  _buildFilterChip(
                    'En revisión',
                    dotColor: Colors.amber,
                  ),
                  _buildFilterChip(
                    'Aprobada',
                    dotColor: greenAccent,
                  ),
                  _buildFilterChip(
                    'Rechazada',
                    dotColor: redAccent,
                  ),
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
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar solicitud...',
                        hintStyle: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                      },
                      child: const Icon(
                        Icons.close,
                        color: textMuted,
                        size: 17,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (filtradas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      color: textMuted,
                      size: 40,
                    ),
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
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
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
                      _mostrarDetalleSolicitud(
                        context,
                        item,
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mostrando ${filtradas.length} de ${solicitudes.length} solicitudes',
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
                        disabled: true,
                      ),
                      const SizedBox(width: 4),
                      _buildPageBtn(
                        text: '1',
                        selected: true,
                      ),
                      const SizedBox(width: 4),
                      _buildPageBtn(
                        icon: Icons.chevron_right,
                        disabled: true,
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

  Widget _buildFilterChip(
    String label, {
    Color? dotColor,
  }) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue
              : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryBlue
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? textWhite
                    : textMuted,
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
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
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected
            ? primaryBlue
            : disabled
                ? Colors.white.withValues(alpha: 0.02)
                : cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected
              ? primaryBlue
              : Colors.white10,
        ),
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: disabled
                    ? Colors.white24
                    : textWhite,
                size: 16,
              )
            : Text(
                text!,
                style: TextStyle(
                  color: selected
                      ? textWhite
                      : textMuted,
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
      ),
    );
  }

  void _mostrarDetalleSolicitud(
    BuildContext context,
    SolicitudCambio item,
  ) {
    final comentarioAprobacionController =
        TextEditingController();

    final comentarioRechazoController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryBlue,
                        child: Text(
                          'FR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.solicitante,
                              style: const TextStyle(
                                color: textWhite,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.email,
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 11,
                              ),
                            ),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              fontWeight:
                                  FontWeight.bold,
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
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),

                _buildInfoContainer(
                  item.infoActual,
                ),

                const SizedBox(height: 14),

                const Text(
                  'Información solicitada',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color: accentBlue.withValues(
                        alpha: 0.3,
                      ),
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
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  item.motivo,
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(
                  color: Colors.white10,
                ),
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
                  controller:
                      comentarioAprobacionController,
                  hint:
                      'Comentario opcional al aprobar...',
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          greenAccent,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        item.estado = 'Aprobada';
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solicitud aprobada correctamente',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Aprobar solicitud',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _buildCommentField(
                  controller:
                      comentarioRechazoController,
                  hint: 'Motivo del rechazo...',
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          redAccent,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        item.estado = 'Rechazada';
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solicitud rechazada',
                          ),
                        ),
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
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      comentarioAprobacionController.dispose();
      comentarioRechazoController.dispose();
    });
  }

  Widget _buildInfoContainer(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: textWhite,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCommentField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: textWhite,
          fontSize: 12,
        ),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: textMuted,
            fontSize: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg =
        Colors.amber.withValues(alpha: 0.15);
    Color text = Colors.amber;

    if (status == 'Aprobada') {
      bg = greenAccent.withValues(alpha: 0.15);
      text = greenAccent;
    } else if (status == 'Rechazada') {
      bg = redAccent.withValues(alpha: 0.15);
      text = redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
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
}

class SolicitudCard extends StatelessWidget {
  final SolicitudCambio item;
  final VoidCallback onTap;

  const SolicitudCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Text(
              item.folio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.solicitante,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  item.email,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Campo: ',
                      style: TextStyle(
                        color:
                            Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.campo,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w500,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(
                item.estado,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onTap,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.all(6),
                  child: const Icon(
                    Icons
                        .remove_red_eye_outlined,
                    color:
                        Color(0xFF94A3B8),
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

  Widget _buildStatusBadge(
    String status,
  ) {
    Color bg =
        Colors.amber.withValues(
      alpha: 0.15,
    );
    Color text = Colors.amber;

    if (status == 'Aprobada') {
      bg = const Color(0xFF00A86B)
          .withValues(alpha: 0.15);
      text = const Color(0xFF00A86B);
    } else if (status == 'Rechazada') {
      bg = const Color(0xFFE11D48)
          .withValues(alpha: 0.15);
      text = const Color(0xFFE11D48);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(12),
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
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  final String activeMenu;

  const CustomSidebar({
    super.key,
    this.activeMenu = 'Inicio',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          _CambiosScreenState.sidebarBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                const BoxDecoration(
              color:
                  _CambiosScreenState.sidebarBg,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                RichText(
                  text:
                      const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ticket',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      TextSpan(
                        text: 'Pro',
                        style:
                            TextStyle(
                          color:
                              _CambiosScreenState
                                  .accentBlue,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  padding:
                      const EdgeInsets.all(
                    8,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.04,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            _CambiosScreenState
                                .primaryBlue,
                        child: Text(
                          'JH',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Jesus Hinojosa',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Administrador',
                            style:
                                TextStyle(
                              color:
                                  _CambiosScreenState
                                      .textMuted,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminScreen(),
      ),
    );
  },
),

          _drawerItem(
            context,
            Icons.confirmation_number_outlined,
            'Tickets',
            selected:
                activeMenu == 'Tickets',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TicketsScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            Icons.sync_alt_rounded,
            'Cambios',
            selected:
                activeMenu == 'Cambios',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _drawerItem(
            context,
            Icons.people_outline,
            'Usuarios',
            selected:
                activeMenu == 'Usuarios',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const UserScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            Icons.devices_other,
            'Dispositivos',
            selected:
                activeMenu ==
                    'Dispositivos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DispositivosScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            Icons.campaign_outlined,
            'Avisos',
            selected:
                activeMenu == 'Avisos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AvisosadminScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            Icons.backup_outlined,
            'Backups',
            selected:
                activeMenu == 'Backups',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BackupScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            context,
            Icons.person_outline,
            'Mi perfil',
            selected:
                activeMenu ==
                    'Mi perfil',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PerfiladminScreen(),
                ),
              );
            },
          ),

          const Divider(
            color: Colors.white10,
          ),

          _drawerItem(
            context,
            Icons.logout_rounded,
            'Cerrar sesión',
            isExit: true,
            onTap: () async {
              await SessionService
                  .clearSession();

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
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? _CambiosScreenState
                .primaryBlue
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isExit
              ? Colors.redAccent
              : selected
                  ? Colors.white
                  : _CambiosScreenState
                      .textMuted,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : selected
                    ? Colors.white
                    : _CambiosScreenState
                        .textMuted,
            fontSize: 14,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
