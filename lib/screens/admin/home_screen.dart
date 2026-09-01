import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/admin/indexadmin_services.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _dashboard = <String, dynamic>{};
  String _selectedChartRange = 'Semana';
  DateTimeRange? _selectedDateRange;
  String _dateFilterLabel = 'Sin filtro';
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await SessionService.getToken();
      _token = token ?? '';
      final data = await _service.obtenerDashboard(
        periodo: 'semana',
        fechaInicio: _selectedDateRange?.start,
        fechaFin: _selectedDateRange?.end,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = _dashboardMap(data);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  IndexAdminService get _service {
    return IndexAdminService(
      baseUrl: ApiService.serverUrl,
      token: _token,
    );
  }

  Future<void> _loadEvolution() async {
    try {
      final evolution = await _service.obtenerEvolucion(
        periodo: _selectedChartRange.toLowerCase(),
        fechaInicio: _selectedDateRange?.start,
        fechaFin: _selectedDateRange?.end,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = {
          ..._dashboard,
          'chart': {
            'series': evolution.evolucionTickets
                .map((item) => item.total)
                .toList(),
            'labels': evolution.evolucionTickets
                .map((item) => item.fecha)
                .toList(),
          },
        };
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AdminScreen.primaryBlue,
            surface: AdminScreen.cardBg,
          ),
        ),
        child: child!,
      ),
    );

    if (!mounted || selectedRange == null) {
      return;
    }

    setState(() {
      _selectedDateRange = selectedRange;
      _dateFilterLabel = 'Personalizado';
    });
    await _loadDashboard();
  }

  Future<void> _applyQuickDateFilter(String label) async {
    final now = DateTime.now();
    DateTimeRange? range;

    switch (label) {
      case 'Hoy':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
        break;
      case 'Esta semana':
        final start = now.subtract(Duration(days: now.weekday - 1));
        range = DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: now,
        );
        break;
      case 'Este mes':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
        break;
      case 'Sin filtro':
        break;
    }

    setState(() {
      _selectedDateRange = range;
      _dateFilterLabel = label;
    });
    await _loadDashboard();
  }

  Future<void> _clearDateFilter() async {
    setState(() {
      _selectedDateRange = null;
      _dateFilterLabel = 'Sin filtro';
    });
    await _loadDashboard();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Map<String, dynamic> _dashboardMap(AdminDashboardData data) {
    return {
      'stats': {
        'tickets_abiertos': data.ticketsAbiertos,
        'tickets_pendientes': data.ticketsPendientes,
        'tickets_resueltos': data.ticketsResueltos,
        'tickets_del_mes': data.ticketsMes,
        'tiempo_promedio': data.tiempoPromedio,
        'tiempo_promedio_minutos': _minutesFromText(data.tiempoPromedio),
      },
      'notificacionesNoLeidas': data.notificacionesNoLeidas,
      'textoMes': data.textoMes,
      'subtextoMes': data.subtextoMes,
      'textoSemana': data.textoSemana,
      'subtextoSemana': data.subtextoSemana,
      'textoTiempo': data.textoTiempo,
      'subtextoTiempo': data.subtextoTiempo,
      'quejas': data.quejasRecurrentes
          .map((item) => {
                'label': item.tipoFalla,
                'valor': item.total,
                'total': item.total,
              })
          .toList(),
      'equipos': data.equipos
          .map((item) => {
                'nombre': item.equipo,
                'tipo': item.tipo,
                'fallas': item.fallas,
                'fecha': item.ultimaIncidencia ?? '',
              })
          .toList(),
      'ubicaciones': data.ubicaciones
          .map((item) => {
                'label': item.nombre,
                'valor': item.total,
                'total': item.total,
              })
          .toList(),
      'chart': {
        'series': data.evolucionTickets.map((item) => item.total).toList(),
        'labels': data.evolucionTickets.map((item) => item.fecha).toList(),
      },
    };
  }

  int? _minutesFromText(String value) {
    final match = RegExp(r'(\d+)\s*m').firstMatch(value.toLowerCase());
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  Map<String, dynamic> get _stats =>
      _dashboard['stats'] is Map ? Map<String, dynamic>.from(_dashboard['stats']) : <String, dynamic>{};

  List<Map<String, dynamic>> _lista(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int _intValue(List<dynamic> values, {int fallback = 0}) {
    for (final value in values) {
      if (value == null) {
        continue;
      }

      if (value is int) {
        return value;
      }

      if (value is double) {
        return value.round();
      }

      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }

    return fallback;
  }

  String _formatAverageMinutes(dynamic minutesValue) {
    if (minutesValue is String && minutesValue.trim().isNotEmpty) {
      return minutesValue;
    }

    final minutes = _intValue([
      minutesValue,
      _stats['tiempo_promedio_minutos'],
      _stats['tiempo_promedio'],
    ], fallback: 0);

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    }

    if (hours > 0) {
      return '${hours}h';
    }

    if (minutes > 0) {
      return '${minutes}m';
    }

    return '0m';
  }

  List<String> _chartLabelsForRange() {
    final rawChart = _dashboard['chart'];
    if (rawChart is Map && rawChart['labels'] is List) {
      final labels = (rawChart['labels'] as List)
          .map((label) => label.toString())
          .toList();
      if (labels.isNotEmpty) {
        return labels;
      }
    }

    switch (_selectedChartRange) {
      case 'Hoy':
        return ['08h', '10h', '12h', '14h', '16h', '18h', '20h', '22h'];
      case 'Mes':
        return ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];
      case 'Año':
        return ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      case 'Semana':
      default:
        return ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    }
  }

  List<double> _chartSeriesForRange() {
    final rawChart = _dashboard['chart'] is Map ? Map<String, dynamic>.from(_dashboard['chart']) : <String, dynamic>{};
    final currentSeries = rawChart['series'];
    final seriesByRange = <String, List<double>>{
      'Hoy': _parseNumericList(
        rawChart['series_hoy'] ?? rawChart['data_hoy'] ?? rawChart['today'] ?? currentSeries,
      ),
      'Semana': _parseNumericList(
        rawChart['series_semana'] ?? rawChart['data_semana'] ?? rawChart['week'] ?? currentSeries,
      ),
      'Mes': _parseNumericList(
        rawChart['series_mes'] ?? rawChart['data_mes'] ?? rawChart['month'] ?? currentSeries,
      ),
      'Año': _parseNumericList(
        rawChart['series_anio'] ?? rawChart['data_anio'] ?? rawChart['year'] ?? currentSeries,
      ),
    };

    final selectedSeries = seriesByRange[_selectedChartRange];
    if (selectedSeries != null && selectedSeries.isNotEmpty) {
      return selectedSeries;
    }

    return const <double>[];
  }

  List<double> _parseNumericList(dynamic value) {
    if (value is! List) {
      return <double>[];
    }

    final numbers = <double>[];
    for (final item in value) {
      if (item is num) {
        numbers.add(item.toDouble());
      }
    }
    return numbers;
  }

  List<FlSpot> _chartSpots() {
    final values = _chartSeriesForRange();
    final spots = <FlSpot>[];

    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    if (spots.isNotEmpty) {
      return spots;
    }

    return const [
      FlSpot(0, 7),
      FlSpot(1, 2.2),
      FlSpot(2, 1),
      FlSpot(3, 1),
      FlSpot(4, 1),
      FlSpot(5, 1.8),
      FlSpot(6, 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final openTickets = _intValue([
      _stats['tickets_abiertos'],
      _dashboard['tickets_abiertos'],
    ], fallback: 0);
    final pendingTickets = _intValue([
      _stats['tickets_pendientes'],
      _dashboard['tickets_pendientes'],
    ], fallback: 0);
    final resolvedTickets = _intValue([
      _stats['tickets_resueltos'],
      _dashboard['tickets_resueltos'],
    ], fallback: 0);
    final monthlyTickets = _intValue([
      _stats['tickets_del_mes'],
      _dashboard['tickets_del_mes'],
    ], fallback: 0);
    final complaints = _lista(
      _dashboard['quejas'] ?? _dashboard['complaints'] ?? _dashboard['quejas_recurrentes'],
    );
    final equipments = _lista(
      _dashboard['equipos'] ?? _dashboard['equipment'] ?? _dashboard['equipos_mas_fallas'],
    );
    final locations = _lista(
      _dashboard['ubicaciones'] ?? _dashboard['locations'] ?? _dashboard['sucursales'],
    );
    final maxComplaintValue = complaints.fold<int>(0, (prev, item) {
      final value = item['valor'] ?? item['value'] ?? item['cantidad'] ?? item['count'];
      final parsed = int.tryParse(value?.toString() ?? '') ?? 0;
      return parsed > prev ? parsed : prev;
    });
    final mainEquipment = equipments.isNotEmpty ? equipments.first : null;
    final chartValues = _chartSeriesForRange();
    final chartAverage = chartValues.isEmpty
        ? 0.0
        : chartValues.reduce((a, b) => a + b) / chartValues.length;
    final chartMax = chartValues.isEmpty ? 0.0 : chartValues.reduce((a, b) => a > b ? a : b);
    final chartMin = chartValues.isEmpty ? 0.0 : chartValues.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: AdminScreen.background,
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
                      _intValue([
                        _dashboard['notificacionesNoLeidas'],
                      ]).toString(),
                      style: TextStyle(color: Colors.white, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              navigateWithLoading(
                context,
                const AvisosadminScreen(),
                mensaje: 'Cargando avisos del admin...',
              );
            },
          ),
          const SizedBox(width: 8),
          const AdminProfileMenu(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AdminScreen.accentBlue),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: AdminScreen.accentBlue,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadDashboard,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    'Tecnologías / Soporte',
                    style: TextStyle(
                      color: AdminScreen.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dashboard de estadísticas y métricas del soporte técnico.',
                    style: TextStyle(color: AdminScreen.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminScreen.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AdminScreen.textMuted,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filtrar por fechas',
                              style: TextStyle(
                                color: AdminScreen.textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final label in [
                                'Hoy',
                                'Esta semana',
                                'Este mes',
                                'Sin filtro',
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(label),
                                    selected: _dateFilterLabel == label,
                                    onSelected: (_) => _applyQuickDateFilter(label),
                                    selectedColor: AdminScreen.primaryBlue,
                                    backgroundColor: AdminScreen.background,
                                    labelStyle: TextStyle(
                                      color: _dateFilterLabel == label
                                          ? Colors.white
                                          : AdminScreen.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.tune,
                                  size: 15,
                                  color: AdminScreen.textMuted,
                                ),
                                label: const Text('Personalizado'),
                                onPressed: _selectDateRange,
                                backgroundColor: AdminScreen.background,
                                labelStyle: const TextStyle(
                                  color: AdminScreen.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.clear,
                                  size: 15,
                                  color: AdminScreen.textMuted,
                                ),
                                label: const Text('Limpiar filtros'),
                                onPressed: _clearDateFilter,
                                backgroundColor: AdminScreen.background,
                                labelStyle: const TextStyle(
                                  color: AdminScreen.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDateRange != null &&
                            _dateFilterLabel == 'Personalizado')
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${_formatDate(_selectedDateRange!.start)} - '
                              '${_formatDate(_selectedDateRange!.end)}',
                              style: const TextStyle(
                                color: AdminScreen.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      KPICard(
                        icon: Icons.confirmation_number_outlined,
                        iconColor: AdminScreen.accentBlue,
                        title: 'Tickets abiertos',
                        value: openTickets.toString(),
                        badgeText: '${_dashboard['textoSemana'] ?? ''} ${_dashboard['subtextoSemana'] ?? ''}',
                        badgeColor: AdminScreen.greenAccent,
                      ),
                      KPICard(
                        icon: Icons.access_time_rounded,
                        iconColor: Colors.purpleAccent,
                        title: 'Tickets pendientes',
                        value: pendingTickets.toString(),
                        badgeText: 'Pendientes',
                        badgeColor: AdminScreen.greenAccent,
                      ),
                      KPICard(
                        icon: Icons.check_circle_outline,
                        iconColor: AdminScreen.greenAccent,
                        title: 'Tickets resueltos',
                        value: resolvedTickets.toString(),
                        badgeText: _dashboard['textoMes']?.toString() ?? 'Este mes',
                        badgeColor: AdminScreen.greenAccent,
                      ),
                      KPICard(
                        icon: Icons.timer_outlined,
                        iconColor: Colors.amber,
                        title: 'Tiempo promedio',
                        subtitle: 'de atención',
                        value: _formatAverageMinutes(_stats['tiempo_promedio']),
                        badgeText: _dashboard['textoTiempo']?.toString() ?? 'Promedio actual',
                        badgeColor: AdminScreen.cyanAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  KPICard(
                    icon: Icons.bar_chart_rounded,
                    iconColor: AdminScreen.accentBlue,
                    title: 'Tickets del mes',
                    value: monthlyTickets.toString(),
                    badgeText: 'Este mes',
                    badgeColor: AdminScreen.cyanAccent,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 20),
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Quejas recurrentes',
                              style: TextStyle(
                                color: AdminScreen.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Problemas más reportados por los usuarios.',
                          style: TextStyle(color: AdminScreen.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ...complaints.map((item) {
                          final label = item['label'] ?? item['nombre'] ?? item['categoria'] ?? 'Sin nombre';
                          final value = _intValue([
                            item['valor'],
                            item['value'],
                            item['cantidad'],
                            item['count'],
                          ], fallback: 0);
                          final total = _intValue([
                            item['total'],
                            item['maximo'],
                            item['max'],
                            maxComplaintValue == 0 ? 1 : maxComplaintValue,
                          ], fallback: 1);

                          return ProgressBarRow(
                            label: label.toString(),
                            value: value,
                            total: total,
                            barColor: AdminScreen.accentBlue,
                          );
                        }),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${complaints.length} quejas recurrentes cargadas.',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Ver todas las quejas >',
                              style: TextStyle(
                                color: AdminScreen.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.laptop_chromebook,
                              color: AdminScreen.accentBlue,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Equipo con más fallas',
                              style: TextStyle(
                                color: AdminScreen.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Equipos con mayor número de incidencias.',
                          style: TextStyle(color: AdminScreen.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Equipo',
                                  style: TextStyle(color: AdminScreen.textMuted, fontSize: 11),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Tipo',
                                  style: TextStyle(color: AdminScreen.textMuted, fontSize: 11),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Fallas',
                                  style: TextStyle(color: AdminScreen.textMuted, fontSize: 11),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Última incidencia',
                                  style: TextStyle(color: AdminScreen.textMuted, fontSize: 11),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white10),
                        ...equipments.take(4).map((item) {
                          final name = item['nombre'] ?? item['equipo'] ?? item['label'] ?? 'Equipo';
                          final type = item['tipo'] ?? item['type'] ?? 'Equipo';
                          final count = _intValue([
                            item['fallas'],
                            item['count'],
                            item['cantidad'],
                            item['total'],
                          ], fallback: 0).toString();
                          final date = item['fecha'] ?? item['date'] ?? item['ultima_incidencia'] ?? item['updated_at'] ?? '';

                          return EquipmentRow(
                            name: name.toString(),
                            type: type.toString(),
                            count: count,
                            date: date.toString(),
                          );
                        }),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.amber,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Equipo con mayor recurrencia: ',
                                      ),
                                      TextSpan(
                                        text: mainEquipment != null
                                            ? (mainEquipment['nombre'] ?? mainEquipment['equipo'] ?? 'Sin datos').toString()
                                            : 'Sin datos',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AdminScreen.accentBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AdminScreen.accentBlue,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '¿Dónde hay más tickets?',
                              style: TextStyle(
                                color: AdminScreen.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tickets generados por ubicación / sucursal.',
                          style: TextStyle(color: AdminScreen.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ...locations.map((item) {
                          final label = item['label'] ?? item['nombre'] ?? item['ubicacion'] ?? item['oficina'] ?? 'Ubicación';
                          final value = _intValue([
                            item['valor'],
                            item['value'],
                            item['cantidad'],
                            item['count'],
                          ], fallback: 0);
                          final total = _intValue([
                            item['total'],
                            item['maximo'],
                            item['max'],
                            value > 0 ? value : 1,
                          ], fallback: 1);

                          return ProgressBarRow(
                            label: label.toString(),
                            value: value,
                            total: total,
                            barColor: AdminScreen.cyanAccent,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.show_chart, color: AdminScreen.accentBlue, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Evolución de tickets',
                              style: TextStyle(
                                color: AdminScreen.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Comportamiento de tickets en el periodo seleccionado.',
                          style: TextStyle(color: AdminScreen.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AdminScreen.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: ['Hoy', 'Semana', 'Mes', 'Año']
                                .map(
                                  (range) => _buildFilterTab(
                                    range,
                                    _selectedChartRange == range,
                                    onTap: () async {
                                      setState(() {
                                        _selectedChartRange = range;
                                      });
                                      await _loadEvolution();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 20,
                                    getTitlesWidget: (value, meta) => Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(
                                        color: AdminScreen.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final labels = _chartLabelsForRange();
                                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                        return Text(
                                          labels[value.toInt()],
                                          style: const TextStyle(
                                            color: AdminScreen.textMuted,
                                            fontSize: 9,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _chartSpots(),
                                  isCurved: true,
                                  color: AdminScreen.accentBlue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MiniStat(
                              title: 'Promedio',
                              value: chartAverage.toStringAsFixed(1),
                              icon: Icons.center_focus_weak,
                            ),
                            MiniStat(
                              title: 'Máximo',
                              value: chartMax.toStringAsFixed(0),
                              icon: Icons.trending_up,
                            ),
                            MiniStat(
                              title: 'Mínimo',
                              value: chartMin.toStringAsFixed(0),
                              icon: Icons.trending_down,
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

  Widget _buildFilterTab(
    String text,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AdminScreen.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AdminScreen.textWhite : AdminScreen.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminScreen.sidebarBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AdminScreen.sidebarBg),
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
          _drawerItem(Icons.dashboard_rounded, 'Inicio', selected: true),
          _drawerItem(
            Icons.confirmation_number_outlined,
            'Tickets',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const TicketsScreen(),
                mensaje: 'Cargando tickets...',
              );
            },
          ),
          _drawerItem(
            Icons.sync_alt_rounded,
            'Cambios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const CambiosScreen(),
                mensaje: 'Cargando cambios...',
              );
            },
          ),
          _drawerItem(
            Icons.people_outline,
            'Usuarios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const UserScreen(),
                mensaje: 'Cargando usuarios...',
              );
            },
          ),
          _drawerItem(
            Icons.devices_other,
            'Dispositivos',
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
            Icons.campaign_outlined,
            'Avisos',
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
            Icons.person_outline,
            'Mi perfil',
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
            Icons.logout_rounded,
            'Cerrar sesión',
            onTap: () async {
              await SessionService.clearSession();
              if (!context.mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    bool selected = false,
    bool isExit = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? AdminScreen.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isExit
                ? Colors.redAccent
                : (selected ? Colors.white : AdminScreen.textMuted),
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isExit
                  ? Colors.redAccent
                  : (selected ? Colors.white : AdminScreen.textMuted),
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

class AdminAvatar extends StatelessWidget {
  const AdminAvatar({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final picture = snapshot.data?['picture']?.toString().trim() ?? '';
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
}

class AdminProfileMenu extends StatelessWidget {
  const AdminProfileMenu({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Abrir menú del administrador',
      offset: const Offset(0, 46),
      padding: EdgeInsets.zero,
      color: const Color(0xFF0F172A),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      onSelected: (value) async {
        if (value == 'perfil') {
          await navigateWithLoading(
            context,
            const PerfiladminScreen(),
            mensaje: 'Cargando perfil...',
          );
          return;
        }

        if (value == 'logout') {
          await SessionService.clearSession();
          if (!context.mounted) {
            return;
          }
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'perfil',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Mi perfil', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      child: AdminAvatar(radius: radius),
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}

class KPICard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final bool fullWidth;
  const KPICard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    this.fullWidth = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdminScreen.textMuted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AdminScreen.textMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color barColor;
  const ProgressBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.barColor,
  });
  @override
  Widget build(BuildContext context) {
    double factor = (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: constraints.maxWidth * factor,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
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
}

class EquipmentRow extends StatelessWidget {
  final String name;
  final String type;
  final String count;
  final String date;
  const EquipmentRow({
    super.key,
    required this.name,
    required this.type,
    required this.count,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.computer,
                  color: AdminScreen.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: const TextStyle(
                color: AdminScreen.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              count,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                color: AdminScreen.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const MiniStat({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AdminScreen.accentBlue, size: 18),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: AdminScreen.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
