import 'package:flutter/material.dart';

import '../../services/session_service.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
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

  String _datoUsuario(
    String campo, {
    String defecto = 'No disponible',
  }) {
    final valor = usuario?[campo];

    if (valor == null) {
      return defecto;
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty || texto == 'null') {
      return defecto;
    }

    return texto;
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
    return _datoUsuario('empresa');
  }

  String get departamentoUsuario {
    return _datoUsuario('departamento');
  }

  String get oficinaUsuario {
    return _datoUsuario('oficina');
  }

  String get ubicacionUsuario {
    return _datoUsuario('ubicacion');
  }

  String get empleadoUsuario {
    return _datoUsuario('numero_empleado');
  }

  String get fechaIngresoUsuario {
    return _datoUsuario('fecha_ingreso');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    isDesktop,
                  ),
                  const SizedBox(height: 20),
                  _buildLayout(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 500;

        if (compact) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Column(
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
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2563EB),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CrearticketsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Nuevo ticket',
                    style: TextStyle(
                      color: Colors.white,
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CrearticketsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: const Text(
                'Nuevo ticket',
                style: TextStyle(
                  color: Colors.white,
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
                child: _buildTicketSummary(),
              ),
            ],
          )
        else ...[
          _buildTicketSummary(),
          const SizedBox(height: 16),
          _buildUserInfo(),
        ],

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
                    const SizedBox(height: 16),
                    _buildActivity(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildRecentTickets(
                      isDesktop,
                    ),
                    const SizedBox(height: 16),
                    _buildNotices(),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildLastTicket(),
          const SizedBox(height: 16),
          _buildRecentTickets(isDesktop),
          const SizedBox(height: 16),
          _buildActivity(),
          const SizedBox(height: 16),
          _buildNotices(),
        ],
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
      child: Column(
        children: [
          const Center(
            child: UserAvatar(
              radius: 36,
            ),
          ),

          const SizedBox(height: 16),

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
            Icons.place_outlined,
            'Ubicación:',
            ubicacionUsuario,
          ),

          _infoRow(
            Icons.badge_outlined,
            'Empleado:',
            empleadoUsuario,
          ),

          _infoRow(
            Icons.calendar_today_outlined,
            'Fecha ingreso:',
            fechaIngresoUsuario,
          ),

          _infoRow(
            Icons.work_outline,
            'Rol:',
            rolUsuario,
          ),
        ],
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
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
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
    return _buildCard(
      title: 'Resumen de mis tickets',
      trailing: const Text(
        'Total: 18',
        style: TextStyle(
          color: Colors.purpleAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _metricBadge(
            '3',
            'Abiertos',
            Colors.yellow,
          ),
          _metricBadge(
            '4',
            'En proceso',
            Colors.blue,
          ),
          _metricBadge(
            '8',
            'Solucionados',
            Colors.green,
          ),
          _metricBadge(
            '1',
            'Cancelados',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(
    String count,
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
        color:
            color.withOpacity(0.1),
        border: Border.all(
          color: color,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count,
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
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLastTicket() {
    return _buildCard(
      title: 'Último ticket',
      trailing: TextButton(
        onPressed: () {},
        child: const Text(
          'Ver detalles',
        ),
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141C33),
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'TKT-2026-0015',
              style: TextStyle(
                color: Colors.blue,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Tipo: Equipo de cómputo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(width: 8),

                Text(
                  'Alta',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4),

            Text(
              'Asignado: Carlos Mtz',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTickets(
    bool isDesktop,
  ) {
    final tickets = [
      {
        'folio': 'TKT-2026-0015',
        'tipo': 'Equipo de computo',
        'estado': 'En proceso',
        'color': Colors.blue,
      },
      {
        'folio': 'TKT-2026-0016',
        'tipo': 'Impresora',
        'estado': 'Solucionado',
        'color': Colors.green,
      },
      {
        'folio': 'TKT-2026-0017',
        'tipo': 'VPN / Red',
        'estado': 'Solucionado',
        'color': Colors.green,
      },
      {
        'folio': 'TKT-2026-0018',
        'tipo': 'Correo outlook',
        'estado': 'En proceso',
        'color': Colors.blue,
      },
      {
        'folio': 'TKT-2026-0019',
        'tipo': 'Acceso a sistema',
        'estado': 'Cancelado',
        'color': Colors.red,
      },
    ];

    return _buildCard(
      title: 'Mis tickets recientes',
      trailing: TextButton(
        onPressed: () {},
        child: const Text(
          'Ver todos',
        ),
      ),
      child: isDesktop
          ? SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
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
                rows: tickets.map((t) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          t['folio'] as String,
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
                          t['tipo'] as String,
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
                          t['estado'] as String,
                          style: TextStyle(
                            color:
                                t['color']
                                    as Color,
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
                          onPressed: () {},
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          : Column(
              children:
                  tickets.map((t) {
                return Container(
                  width:
                      double.infinity,
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
                        const Color(
                      0xFF141C33,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(6),
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
                              t['folio']
                                  as String,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 12,
                                color:
                                    Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              t['tipo']
                                  as String,
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
                              t['estado']
                                  as String,
                              style:
                                  TextStyle(
                                color:
                                    t['color']
                                        as Color,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w600,
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
                        onPressed: () {},
                        tooltip:
                            'Ver ticket',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildActivity() {
    return _buildCard(
      title: 'Actividad reciente',
      child: Column(
        children: [
          _activityItem(
            'Carlos Martínez tomó tu ticket',
            '05 Ago - 10:30 AM',
            Colors.green,
          ),
          _activityItem(
            'Se agregó un comentario',
            '05 Ago - 10:15 AM',
            Colors.blue,
          ),
          _activityItem(
            'Tu ticket se creó correctamente',
            '05 Ago - 10:00 AM',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _activityItem(
    String text,
    String time,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
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
                  ),
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
    );
  }

  Widget _buildNotices() {
    return _buildCard(
      title: 'Avisos importantes',
      trailing: TextButton(
        onPressed: () {},
        child: const Text(
          'Ver todos',
        ),
      ),
      child: Column(
        children: [
          _noticeItem(
            'Mantenimiento programado',
            '05 de agosto',
            Icons.warning_amber_rounded,
            Colors.amber,
          ),
          _noticeItem(
            'Actualización del sistema',
            '03 de agosto',
            Icons.info_outline,
            Colors.blue,
          ),
          _noticeItem(
            'Política de seguridad',
            '01 de agosto',
            Icons.shield_outlined,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _noticeItem(
    String title,
    String date,
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
                    color:
                        Colors.white,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                Text(
                  date,
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

          IconButton(
            icon:
                const Icon(
              Icons
                  .chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
            onPressed: () {},
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
        padding:
            const EdgeInsets.symmetric(
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
                  padding:
                      const EdgeInsets.all(2),
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    border: Border.all(
                      color:
                          const Color(
                        0xFF2563EB,
                      ),
                      width: 2,
                    ),
                  ),
                  child:
                      const UserAvatar(
                    radius: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FutureBuilder<
                      Map<String, dynamic>?>(
                    future:
                        SessionService.getUser(),
                    builder:
                        (context, snapshot) {
                      final user =
                          snapshot.data;

                      final nombre =
                          user?['name']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ==
                                  true
                              ? user!['name']
                                  .toString()
                              : user?['login']
                                      ?.toString() ??
                                  'Usuario';

                      final rol =
                          user?['role']
                                  ?.toString() ??
                              '';

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Colors.white,
                            ),
                          ),
                          Text(
                            rol,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey,
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

            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              isActive: true,
              onTap: () {},
            ),

            _drawerItem(
              icon:
                  Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MisticketsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon:
                  Icons.build_outlined,
              title: 'Crear ticket',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CrearticketsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon:
                  Icons.warning_amber_rounded,
              title: 'Avisos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AvisosScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon:
                  Icons.person_outline_rounded,
              title: 'Mi perfil',
              onTap: () {},
            ),

            const Spacer(),

            _drawerItem(
              icon:
                  Icons.logout_rounded,
              title: 'Cerrar sesión',
              color: Colors.white70,
              onTap: () async {
                // Ya no usamos ApiService.logout().
                // La sesión local se elimina desde
                // SessionService.
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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final Color itemColor =
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
                BorderRadius.circular(10),
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