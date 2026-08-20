import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'mistickets_screen.dart';
import 'avisos_screen.dart';

class CrearticketsScreen extends StatefulWidget {
  const CrearticketsScreen({super.key});

  @override
  State<CrearticketsScreen> createState() => _CrearticketsScreenState();
}

class _CrearticketsScreenState extends State<CrearticketsScreen> {
  String selectedPriority = 'Media';
  String? selectedFailureType;

  bool afectaOtros = false;
  bool esRecurrente = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),

      // ============================================================
      // APP BAR MOBILE
      // ============================================================
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

      // ============================================================
      // DRAWER MOBILE
      // ============================================================
      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(
              activeRoute: 'Crear ticket',
            ),

      // ============================================================
      // BODY
      // ============================================================
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),

                  const SizedBox(height: 24),

                  _buildUserInfoCard(isDesktop),

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

  // ================================================================
  // HEADER
  // ================================================================

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
                onPressed: () {},
              ),

              const SizedBox(width: 16),

              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(
                    radius: 18,
                  ),

                  SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Perez',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'administracion',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 4),

                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  // ================================================================
  // INFORMACIÓN DEL USUARIO
  // ================================================================

  Widget _buildUserInfoCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
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
          color: Colors.white.withOpacity(0.05),
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

  // ================================================================
  // FORMULARIO + EVIDENCIA
  // ================================================================

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

  // ================================================================
  // FORMULARIO
  // ================================================================

  Widget _buildTicketFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
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

          // ========================================================
          // TÍTULO
          // ========================================================

          _formLabel('Título del ticket'),

          const SizedBox(height: 8),

          TextField(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Ej. Impresora de administración sin conexión',
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // TIPO DE FALLA + PRIORIDAD
          // ========================================================

          LayoutBuilder(
            builder: (context, constraints) {
              // En espacios pequeños los ponemos uno debajo del otro.
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFailureType(),

                    const SizedBox(height: 20),

                    _buildPriority(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildFailureType(),
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

          // ========================================================
          // DESCRIPCIÓN
          // ========================================================

          _formLabel('Descripción del problema'),

          const SizedBox(height: 8),

          TextField(
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

          // ========================================================
          // AFECTA / RECURRENTE
          // ========================================================

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildYesNoSection(
                      '¿Afecta a otros usuarios?',
                      afectaOtros,
                      (value) {
                        setState(() {
                          afectaOtros = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildYesNoSection(
                      '¿Es una falla recurrente?',
                      esRecurrente,
                      (value) {
                        setState(() {
                          esRecurrente = value;
                        });
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
                        setState(() {
                          afectaOtros = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildYesNoSection(
                      '¿Es una falla recurrente?',
                      esRecurrente,
                      (value) {
                        setState(() {
                          esRecurrente = value;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // ========================================================
          // COMENTARIOS
          // ========================================================

          _formLabel('Comentarios adicionales'),

          const SizedBox(height: 8),

          TextField(
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

  // ================================================================
  // TIPO DE FALLA
  // ================================================================

  Widget _buildFailureType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel('Tipo de falla'),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: selectedFailureType,

          // ESTA ES LA CORRECCIÓN PRINCIPAL DEL OVERFLOW
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

          onChanged: (value) {
            setState(() {
              selectedFailureType = value;
            });
          },
        ),
      ],
    );
  }

  // ================================================================
  // PRIORIDAD
  // ================================================================

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
                Icons.warning_amber_rounded,
                const Color(0xFFEF4444),
              ),

              const SizedBox(width: 6),

              _priorityBtn(
                'Alta',
                Icons.arrow_upward_rounded,
                const Color(0xFFF97316),
              ),

              const SizedBox(width: 6),

              _priorityBtn(
                'Media',
                Icons.remove_rounded,
                const Color(0xFFEAB308),
              ),

              const SizedBox(width: 6),

              _priorityBtn(
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

  // ================================================================
  // SECCIÓN SI / NO
  // ================================================================

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

  // ================================================================
  // EVIDENCIA
  // ================================================================

  Widget _buildEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
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

          // ========================================================
          // ÁREA DE ARCHIVOS
          // ========================================================

          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
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
                  color: Colors.blue.withOpacity(0.3),
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

          const SizedBox(height: 40),

          // ========================================================
          // BOTONES
          // ========================================================

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 350) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
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

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Enviar ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
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

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Enviar ticket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LABEL
  // ================================================================

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

  // ================================================================
  // INPUT DECORATION
  // ================================================================

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

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  // ================================================================
  // BOTÓN PRIORIDAD
  // ================================================================

  Widget _priorityBtn(
    String label,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = selectedPriority == label;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPriority = label;
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
              ? color.withOpacity(0.15)
              : const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.white12,
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

  // ================================================================
  // TOGGLE SI / NO
  // ================================================================

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
                onTap: () {
                  onChanged(true);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value
                        ? const Color(0xFF1E3A8A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Sí',
                    style: TextStyle(
                      color: value
                          ? Colors.white
                          : Colors.grey,
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
                onTap: () {
                  onChanged(false);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !value
                        ? const Color(0xFF1E3A8A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: !value
                          ? Colors.white
                          : Colors.grey,
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

// ==================================================================
// AVATAR SIN NETWORKIMAGE
// ==================================================================
//
// Quitamos:
// https://i.pravatar.cc/150?img=12
//
// porque Flutter Web estaba devolviendo:
// net::ERR_FAILED 200 (OK)
//
// Así no tendrás ese error.
// ==================================================================

class UserAvatar extends StatelessWidget {
  final double radius;

  const UserAvatar({
    super.key,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: radius,
        ),
      ),
    );
  }
}

// ==================================================================
// LOGO
// ==================================================================

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

// ==================================================================
// DRAWER
// ==================================================================

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({
    super.key,
    this.activeRoute = 'Inicio',
  });

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
              const AppLogo(
                fontSize: 26,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const UserAvatar(
                    radius: 20,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
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

              // ====================================================
              // INICIO
              // ====================================================

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
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
              ),

              // ====================================================
              // MIS TICKETS
              // ====================================================

              _drawerItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Mis tickets',
                isActive: activeRoute == 'Mis tickets',
                onTap: () {
                  if (activeRoute == 'Mis tickets') {
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MisticketsScreen(),
                    ),
                  );
                },
              ),

              // ====================================================
              // CREAR TICKET
              // ====================================================

              _drawerItem(
                icon: Icons.build_outlined,
                title: 'Crear ticket',
                isActive: activeRoute == 'Crear ticket',
                onTap: () {
                  if (activeRoute == 'Crear ticket') {
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CrearticketsScreen(),
                    ),
                  );
                },
              ),

              // ====================================================
              // AVISOS
              // ====================================================

               _drawerItem(
                icon: Icons.warning_amber_rounded,
                title: 'Avisos',
                isActive: activeRoute == 'Avisos',
                onTap: () {
                  if (activeRoute == 'Crear ticket') {
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AvisosScreen(),
                    ),
                  );
                },
              ),

              // ====================================================
              // PERFIL
              // ====================================================

              _drawerItem(
                icon: Icons.person_outline_rounded,
                title: 'Mi perfil',
                isActive: activeRoute == 'Mi perfil',
                onTap: () {},
              ),

              const Spacer(),

              // ====================================================
              // CERRAR SESIÓN
              // ====================================================

              _drawerItem(
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión',
                color: Colors.white70,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================================
  // ITEM DEL DRAWER
  // =================================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final Color itemColor =
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

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
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

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          onTap: onTap,
        ),
      ),
    );
  }
}