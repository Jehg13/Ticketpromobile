import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color cardDark = Color(0xFF121826);
  static const Color inputBg = Color(0xFF172033);
  static const Color primaryGradientStart = Color(0xFF2563EB);
  static const Color primaryGradientEnd = Color(0xFF4F46E5);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);

  bool _backupsAutomaticos = true;
  String _frecuenciaSeleccionada = 'Diario';
  TimeOfDay _horaEjecucion = const TimeOfDay(hour: 10, minute: 39);

  List<Map<String, dynamic>> historialBackups = [
    {
      'nombre': 'backup_2026_08_27.sql',
      'tipo': 'Automático',
      'tamano': '45.2 MB',
      'estado': 'Completado',
      'fecha': '27/08/2026 10:39 AM',
    },
    {
      'nombre': 'backup_manual_2026_08_20.sql',
      'tipo': 'Manual',
      'tamano': '42.8 MB',
      'estado': 'Completado',
      'fecha': '20/08/2026 03:15 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Text(
              'Ticket',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Pro',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(
              right: 16,
              left: 8,
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0x332563EB),
              child: Text(
                'JH',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 16),
            _buildManualBackupCard(),
            const SizedBox(height: 16),
            _buildAutoConfigCard(),
            const SizedBox(height: 16),
            _buildHistorialCard(),
            const SizedBox(height: 16),
            _buildSecurityBanner(),
          ],
        ),
      ),
    );
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
                Icons.backup_outlined,
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
                    'Backups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Administra y programa copias de seguridad',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: successGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Sistema protegido',
                style: TextStyle(
                  color: successGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                Icons.sd_storage_outlined,
                'ALMACENAMIENTO',
                '88.0 MB',
                'Espacio utilizado',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                Icons.verified_user_outlined,
                'ÚLTIMO BACKUP',
                '27/08/2026',
                'Última copia realizada',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                Icons.update_outlined,
                'PRÓXIMO BACKUP',
                '28/08/2026 10:39',
                'Ejecución automática',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                Icons.inventory_2_outlined,
                'COPIAS',
                '${historialBackups.length}',
                'Backups almacenados',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    IconData icon,
    String label,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.transparent,
                size: 16,
              ),
              Icon(
                icon,
                color: Colors.blueAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualBackupCard() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup manual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Crea una copia de seguridad inmediatamente.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: successGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _generarBackupManual,
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Crear backup ahora',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoConfigCard() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración automática',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Define cuándo se ejecutarán los backups.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.power_settings_new_rounded,
                        color: _backupsAutomaticos
                            ? successGreen
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backups automáticos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _backupsAutomaticos
                                  ? 'Actualmente activados'
                                  : 'Actualmente desactivados',
                              style: TextStyle(
                                color: _backupsAutomaticos
                                    ? successGreen
                                    : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _backupsAutomaticos,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.blueAccent,
                  onChanged: (val) {
                    setState(() {
                      _backupsAutomaticos = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Frecuencia',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _frecuenciaSeleccionada,
            dropdownColor: cardDark,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              Icons.repeat_rounded,
              '',
            ),
            items: ['Diario', 'Semanal', 'Mensual']
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: _backupsAutomaticos
                ? (val) {
                    if (val != null) {
                      setState(() {
                        _frecuenciaSeleccionada = val;
                      });
                    }
                  }
                : null,
          ),
          const SizedBox(height: 12),
          const Text(
            'Hora de ejecución',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _backupsAutomaticos
                ? _seleccionarHora
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _horaEjecucion.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'La hora corresponde al horario del servidor.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los backups automáticos almacenarán una copia de la información según la frecuencia configurada.',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGradientStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Configuración de backups guardada correctamente',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.save_outlined,
                size: 18,
              ),
              label: const Text(
                'Guardar configuración',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialCard() {
    return Container(
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de backups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.history,
                color: Colors.grey,
                size: 18,
              ),
            ],
          ),
          const Text(
            'Copias de seguridad generadas por el sistema.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          if (historialBackups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay backups registrados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Los backups generados aparecerán aquí.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historialBackups.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = historialBackups[index];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['nombre'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['tipo'].toString(),
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tamaño: ${item['tamano']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              item['fecha'].toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.white10,
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: successGreen,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['estado'].toString(),
                                style: const TextStyle(
                                  color: successGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                constraints:
                                    const BoxConstraints(),
                                padding:
                                    const EdgeInsets.all(4),
                                icon: const Icon(
                                  Icons.download_rounded,
                                  color: Colors.blueAccent,
                                  size: 18,
                                ),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints:
                                    const BoxConstraints(),
                                padding:
                                    const EdgeInsets.all(4),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    historialBackups
                                        .removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecurityIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguridad de los backups',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Las copias de seguridad contienen información importante del sistema. Se recomienda conservarlas en una ubicación protegida y limitar el acceso únicamente al personal autorizado.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generarBackupManual() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
              SizedBox(height: 16),
              Text(
                'Generando copia de seguridad...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();

    setState(() {
      historialBackups.insert(
        0,
        {
          'nombre':
              'backup_manual_${DateTime.now().millisecondsSinceEpoch}.sql',
          'tipo': 'Manual',
          'tamano': '46.1 MB',
          'estado': 'Completado',
          'fecha': 'Ahora mismo',
        },
      );
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backup manual completado con éxito',
        ),
      ),
    );
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaEjecucion,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryGradientStart,
              surface: cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (picked != null && picked != _horaEjecucion) {
      setState(() {
        _horaEjecucion = picked;
      });
    }
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: cardDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: cardDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TicketPro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryGradientStart,
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
                            'Administrador',
                            style: TextStyle(
                              color: textMuted,
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
  selected: false,
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
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.devices_other,
            'Dispositivos',
            selected: false,
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
            selected: false,
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
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _drawerItem(
            context,
            Icons.person_outline,
            'Mi perfil',
            selected: false,
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
            onTap: _cerrarSesion,
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
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? primaryGradientEnd
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
                  : textMuted,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : selected
                    ? Colors.white
                    : textMuted,
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

  Future<void> _cerrarSesion() async {
    await SessionService.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  InputDecoration _inputDecoration(
    IconData icon,
    String hint,
  ) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.grey,
        size: 18,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SecurityIcon extends StatelessWidget {
  const _SecurityIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.security,
        color: Colors.amber,
        size: 20,
      ),
    );
  }
}