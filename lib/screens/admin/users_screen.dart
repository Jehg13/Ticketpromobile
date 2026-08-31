import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'backup_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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

  final List<UsuarioItem> usuarios = [
    UsuarioItem(
      nombre: 'Alejandro Vargas',
      email: 'alejandro.vargas@gmail.com',
      login: 'avargas',
      numEmpleado: '134658',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Recursos Humanos',
      rol: 'usuario',
      estado: 'Inactiva',
      telefono: 'Sin teléfono',
      permisos: ['Tickets', 'Comentarios'],
    ),
    UsuarioItem(
      nombre: 'Ana Garcia',
      email: 'ana.garcia@gmail.com',
      login: 'agarcia',
      numEmpleado: '134659',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Sin departamento',
      rol: 'Soporte Tecnico',
      estado: 'Activa',
      telefono: '8991234567',
      permisos: ['Tickets'],
    ),
    UsuarioItem(
      nombre: 'Andrea Navarro',
      email: 'andrea.navarro@gmail.com',
      login: 'anavarro',
      numEmpleado: '134660',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Tecnologias',
      rol: 'Soporte Tecnico',
      estado: 'Activa',
      telefono: '8999876543',
      permisos: ['Tickets', 'Comentarios'],
    ),
    UsuarioItem(
      nombre: 'Daniela Silva',
      email: 'daniela.silva@gmail.com',
      login: 'dsilva',
      numEmpleado: '134661',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Ventas',
      rol: 'Recursos Humanos',
      estado: 'Inactiva',
      telefono: 'Sin teléfono',
      permisos: [],
    ),
    UsuarioItem(
      nombre: 'Diego Flores',
      email: 'diego.flores@gmail.com',
      login: 'dflores',
      numEmpleado: '134662',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Sin departamento',
      rol: 'usuario',
      estado: 'Activa',
      telefono: 'Sin teléfono',
      permisos: ['Tickets'],
    ),
    UsuarioItem(
      nombre: 'Fernando Reyes',
      email: 'fernando.reyes@gmail.com',
      login: 'freyes',
      numEmpleado: '134663',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Administracion',
      rol: 'usuario',
      estado: 'Activa',
      telefono: '8991112233',
      permisos: ['Tickets'],
    ),
    UsuarioItem(
      nombre: 'Gabriela Mendoza',
      email: 'gabriela.mendoza@gmail.com',
      login: 'gmendoza',
      numEmpleado: '134664',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Sin departamento',
      rol: 'usuario',
      estado: 'Activa',
      telefono: 'Sin teléfono',
      permisos: ['Tickets'],
    ),
    UsuarioItem(
      nombre: 'Jesus Hinojosa',
      email: 'jefehi13@gmail.com',
      login: 'jhinojosa',
      numEmpleado: '134665',
      empresa: 'Cymez',
      oficina: 'Reynosa',
      departamento: 'Tecnologias',
      rol: 'Gerente TI',
      estado: 'Activa',
      telefono: '8995554433',
      permisos: ['Tickets', 'Comentarios', 'Admin'],
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<UsuarioItem> get usuariosFiltrados {
    return usuarios.where((user) {
      final coincideEstado = selectedFilter == 'Todos' ||
          (selectedFilter == 'Activos' && user.estado == 'Activa') ||
          (selectedFilter == 'Inactivos' && user.estado == 'Inactiva');

      final query = searchQuery.toLowerCase();

      final coincideBusqueda = query.isEmpty ||
          user.nombre.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.login.toLowerCase().contains(query) ||
          user.departamento.toLowerCase().contains(query);

      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosMostrados = usuariosFiltrados;

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
                  color: textWhite,
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
      drawer: const CustomSidebar(activeMenu: 'Usuarios'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuarios',
              style: TextStyle(
                color: textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta y administra la información de los usuarios del sistema',
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
                children: const [
                  KPIStatCard(
                    title: 'Total de usuarios',
                    count: '18',
                    icon: Icons.people_outline,
                    iconColor: accentBlue,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cuentas activas',
                    count: '16',
                    icon: Icons.person_add_alt_1_outlined,
                    iconColor: greenAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cuentas inactivas',
                    count: '2',
                    icon: Icons.person_off_outlined,
                    iconColor: redAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Administradores',
                    count: '2',
                    icon: Icons.security,
                    iconColor: primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip(
                  'Activos',
                  dotColor: greenAccent,
                ),
                _buildFilterChip(
                  'Inactivos',
                  dotColor: redAccent,
                ),
              ],
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
                  const Icon(
                    Icons.search,
                    color: textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar usuario...',
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
                    IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: textMuted,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (usuariosMostrados.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: textMuted,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No se encontraron usuarios',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Intenta cambiar el filtro o la búsqueda.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usuariosMostrados.length,
                itemBuilder: (context, index) {
                  final user = usuariosMostrados[index];

                  return UserCard(
                    item: user,
                    onView: () => _mostrarDetalleUsuario(
                      context,
                      user,
                    ),
                    onEdit: () => _mostrarEditarUsuario(
                      context,
                      user,
                    ),
                    onDelete: () => _mostrarEliminarUsuario(
                      context,
                      user,
                    ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mostrando ${usuariosMostrados.length} de 18 usuarios',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 11,
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
                      _buildPageBtn(text: '2'),
                      const SizedBox(width: 4),
                      _buildPageBtn(
                        icon: Icons.chevron_right,
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
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? textWhite : textMuted,
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
          color: selected ? primaryBlue : Colors.white10,
        ),
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
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
      ),
    );
  }

  void _mostrarDetalleUsuario(
    BuildContext context,
    UsuarioItem user,
  ) {
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Información del usuario',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(user.estado),
                  ],
                ),
                const Text(
                  'Detalle completo de la cuenta',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentBlue,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: primaryBlue,
                              child: Text(
                                user.getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: user.estado == 'Activa'
                                    ? greenAccent
                                    : redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: background,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.nombre,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildRoleBadge(user.rol),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Información general',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  Icons.alternate_email,
                  'Login',
                  user.login,
                ),
                _buildInfoTile(
                  Icons.badge_outlined,
                  'Número de empleado',
                  user.numEmpleado,
                ),
                _buildInfoTile(
                  Icons.domain,
                  'Empresa',
                  user.empresa,
                ),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  'Oficina',
                  user.oficina,
                ),
                _buildInfoTile(
                  Icons.business_outlined,
                  'Departamento',
                  user.departamento,
                ),
                _buildInfoTile(
                  Icons.shield_outlined,
                  'Rol',
                  user.rol,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Información de contacto',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Correo electrónico',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: textWhite,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.white10,
                        height: 16,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Teléfono',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                user.telefono,
                                style: const TextStyle(
                                  color: textWhite,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Permisos',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.permisos.isEmpty
                      ? [
                          const Text(
                            'Sin permisos asignados',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ]
                      : user.permisos.map((permission) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius:
                                  BorderRadius.circular(6),
                              border: Border.all(
                                color: primaryBlue.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              permission,
                              style: const TextStyle(
                                color: accentBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarEditarUsuario(
    BuildContext context,
    UsuarioItem user,
  ) {
    final nombreCtrl =
        TextEditingController(text: user.nombre);
    final numEmpCtrl =
        TextEditingController(text: user.numEmpleado);
    final loginCtrl =
        TextEditingController(text: user.login);
    final emailCtrl =
        TextEditingController(text: user.email);
    final telCtrl = TextEditingController(
      text: user.telefono == 'Sin teléfono'
          ? ''
          : user.telefono,
    );
    final deptoCtrl =
        TextEditingController(text: user.departamento);

    String selectedOficina = user.oficina;
    String selectedRol = user.rol;
    String selectedEstado = user.estado;
    String selectedAdmin =
        user.permisos.contains('Admin') ? 'Sí' : 'No';

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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 20,
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar usuario',
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Modifica la información de la cuenta.',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Información personal',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Nombre',
                      nombreCtrl,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Número de empleado',
                      numEmpCtrl,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Login',
                      loginCtrl,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Correo electrónico',
                      emailCtrl,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Teléfono',
                      telCtrl,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white10,
                        ),
                      ),
                      child: const TextField(
                        obscureText: true,
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.lock_outline,
                            color: textMuted,
                            size: 16,
                          ),
                          hintText:
                              'Nueva contraseña',
                          hintStyle: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      'Déjala vacía si no deseas cambiarla.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Ubicación / Oficina',
                      value: selectedOficina,
                      items: const [
                        'Reynosa',
                        'Monterrey',
                        'CDMX',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedOficina = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Departamento',
                      deptoCtrl,
                    ),
                    const Text(
                      'El departamento se guarda directamente como texto.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Configuración de cuenta',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Rol',
                      value: selectedRol,
                      items: const [
                        'usuario',
                        'Soporte Tecnico',
                        'Recursos Humanos',
                        'Gerente TI',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedRol = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Estado',
                      value: selectedEstado,
                      items: const [
                        'Activa',
                        'Inactiva',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedEstado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Permiso administrador',
                      value: selectedAdmin,
                      items: const [
                        'No',
                        'Sí',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedAdmin = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: cardBg,
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
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: textWhite,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                accentBlue,
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
                            setState(() {
                              user.nombre =
                                  nombreCtrl.text;
                              user.numEmpleado =
                                  numEmpCtrl.text;
                              user.login =
                                  loginCtrl.text;
                              user.email =
                                  emailCtrl.text;
                              user.telefono =
                                  telCtrl.text.isEmpty
                                      ? 'Sin teléfono'
                                      : telCtrl.text;
                              user.departamento =
                                  deptoCtrl.text;
                              user.oficina =
                                  selectedOficina;
                              user.rol = selectedRol;
                              user.estado =
                                  selectedEstado;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(
                              this.context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Usuario actualizado correctamente',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarEliminarUsuario(
    BuildContext context,
    UsuarioItem user,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardBg,
          title: const Text(
            'Eliminar usuario',
            style: TextStyle(
              color: textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Seguro que deseas eliminar a ${user.nombre}?',
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: redAccent,
              ),
              onPressed: () {
                setState(() {
                  usuarios.remove(user);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Usuario eliminado correctamente',
                    ),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: textWhite,
              fontSize: 12,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value)
                  ? value
                  : items.first,
              dropdownColor: cardBg,
              isExpanded: true,
              style: const TextStyle(
                color: textWhite,
                fontSize: 12,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accentBlue,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
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
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActiva = status == 'Activa';
    final Color bg = isActiva
        ? greenAccent.withValues(alpha: 0.15)
        : redAccent.withValues(alpha: 0.15);
    final Color text =
        isActiva ? greenAccent : redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
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

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: accentBlue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class UsuarioItem {
  String nombre;
  String email;
  String login;
  String numEmpleado;
  String empresa;
  String oficina;
  String departamento;
  String rol;
  String estado;
  String telefono;
  List<String> permisos;

  UsuarioItem({
    required this.nombre,
    required this.email,
    required this.login,
    required this.numEmpleado,
    required this.empresa,
    required this.oficina,
    required this.departamento,
    required this.rol,
    required this.estado,
    required this.telefono,
    required this.permisos,
  });

  String getInitials() {
    final parts = nombre.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }
}

class UserCard extends StatelessWidget {
  final UsuarioItem item;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.item,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  item.getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.email,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item.estado),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.white10,
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRoleBadge(item.rol),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  item.departamento,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE11D48),
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

  Widget _buildStatusBadge(String status) {
    final bool isActiva = status == 'Activa';

    final Color bg = isActiva
        ? const Color(0xFF00A86B).withValues(alpha: 0.15)
        : const Color(0xFFE11D48).withValues(alpha: 0.15);

    final Color text = isActiva
        ? const Color(0xFF00A86B)
        : const Color(0xFFE11D48);

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

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5)
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontSize: 10,
          fontWeight: FontWeight.w500,
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
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

  const CustomSidebar({
    super.key,
    this.activeMenu = 'Inicio',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1630),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0D1630),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.04),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            Color(0xFF4F46E5),
                        child: Text(
                          'JH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                            'Gerente Ti',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
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
                MaterialPageRoute(
                  builder: (_) =>
                      const AdminScreen(),
                ),
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
                  builder: (_) =>
                      const TicketsScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.published_with_changes_rounded,
            'Cambios',
            selected: activeMenu == 'Cambios',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CambiosScreen(),
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
                  builder: (_) =>
                      const DispositivosScreen(),
                ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AvisosadminScreen(),
                ),
              );
            },
          ),
                    _drawerItem(
            context,
            Icons.backup_outlined,
            'Backups',
            selected: activeMenu == 'Backups',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupScreen(),
                ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
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
            Icons.logout,
            'Cerrar sesión',
            isExit: true,
            onTap: () async {
              Navigator.pop(context);

              await SessionService.clearSession();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF4F46E5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isExit
              ? Colors.redAccent
              : selected
                  ? Colors.white
                  : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : selected
                    ? Colors.white
                    : const Color(0xFF94A3B8),
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
