import 'dart:convert';
import 'package:http/http.dart' as http;

class IndexAdminService {
  final String baseUrl;
  final String token;

  IndexAdminService({
    required this.baseUrl,
    required this.token,
  });

  Future<AdminDashboardData> obtenerDashboard({
    String periodo = 'semana',
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final queryParameters = <String, String>{
      'periodo': periodo,
    };

    if (fechaInicio != null) {
      queryParameters['fecha_inicio'] = _formatearFecha(fechaInicio);
    }

    if (fechaFin != null) {
      queryParameters['fecha_fin'] = _formatearFecha(fechaFin);
    }

    final uri = Uri.parse(
      '$baseUrl/api/tecnologias',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _procesarRespuesta(response);
  }

  Future<EvolucionData> obtenerEvolucion({
    String periodo = 'semana',
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final queryParameters = <String, String>{
      'periodo': periodo,
    };

    if (fechaInicio != null) {
      queryParameters['fecha_inicio'] = _formatearFecha(fechaInicio);
    }

    if (fechaFin != null) {
      queryParameters['fecha_fin'] = _formatearFecha(fechaFin);
    }

    final uri = Uri.parse(
      '$baseUrl/api/tecnologias/evolucion',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_obtenerMensajeError(response));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw Exception(
        body is Map<String, dynamic>
            ? body['message']?.toString() ?? 'No se pudo obtener la evolución.'
            : 'Respuesta inválida del servidor.',
      );
    }

    return EvolucionData.fromJson(
      Map<String, dynamic>.from(body['data'] ?? {}),
    );
  }

  AdminDashboardData _procesarRespuesta(
    http.Response response,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_obtenerMensajeError(response));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida del servidor.');
    }

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ??
            'No se pudo obtener el dashboard.',
      );
    }

    final data = body['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('La respuesta no contiene datos válidos.');
    }

    return AdminDashboardData.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  String _obtenerMensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body['message']?.toString() ??
            'Error HTTP ${response.statusCode}.';
      }
    } catch (_) {}

    return 'Error HTTP ${response.statusCode}.';
  }

  String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class AdminDashboardData {
  final UsuarioAdmin usuario;
  final List<NotificacionAdmin> notificaciones;
  final int notificacionesNoLeidas;
  final int totalTickets;
  final int ticketsPendientes;
  final int ticketsResueltos;
  final int ticketsAbiertos;
  final int ticketsMes;
  final String textoMes;
  final String subtextoMes;
  final double? porcentajeMes;
  final int ticketsSemana;
  final String textoSemana;
  final String subtextoSemana;
  final double? porcentajeSemana;
  final String tiempoPromedio;
  final String textoTiempo;
  final String subtextoTiempo;
  final double? porcentajeTiempo;
  final List<QuejaRecurrente> quejasRecurrentes;
  final List<EquipoAdmin> equipos;
  final EquipoAdmin? equipoMayorRecurrencia;
  final List<UbicacionAdmin> ubicaciones;
  final List<EvolucionPunto> evolucionTickets;
  final double promedioEvolucion;
  final int maximoEvolucion;
  final int minimoEvolucion;
  final String periodo;
  final String? fechaInicio;
  final String? fechaFin;

  const AdminDashboardData({
    required this.usuario,
    required this.notificaciones,
    required this.notificacionesNoLeidas,
    required this.totalTickets,
    required this.ticketsPendientes,
    required this.ticketsResueltos,
    required this.ticketsAbiertos,
    required this.ticketsMes,
    required this.textoMes,
    required this.subtextoMes,
    required this.porcentajeMes,
    required this.ticketsSemana,
    required this.textoSemana,
    required this.subtextoSemana,
    required this.porcentajeSemana,
    required this.tiempoPromedio,
    required this.textoTiempo,
    required this.subtextoTiempo,
    required this.porcentajeTiempo,
    required this.quejasRecurrentes,
    required this.equipos,
    required this.equipoMayorRecurrencia,
    required this.ubicaciones,
    required this.evolucionTickets,
    required this.promedioEvolucion,
    required this.maximoEvolucion,
    required this.minimoEvolucion,
    required this.periodo,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory AdminDashboardData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminDashboardData(
      usuario: UsuarioAdmin.fromJson(
        Map<String, dynamic>.from(
          json['usuario'] ?? {},
        ),
      ),
      notificaciones: (json['notificaciones'] as List? ?? [])
          .map(
            (item) => NotificacionAdmin.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      notificacionesNoLeidas:
          _toInt(json['notificacionesNoLeidas']),
      totalTickets: _toInt(json['totalTickets']),
      ticketsPendientes: _toInt(json['ticketsPendientes']),
      ticketsResueltos: _toInt(json['ticketsResueltos']),
      ticketsAbiertos: _toInt(json['ticketsAbiertos']),
      ticketsMes: _toInt(json['ticketsMes']),
      textoMes: json['textoMes']?.toString() ?? '',
      subtextoMes: json['subtextoMes']?.toString() ?? '',
      porcentajeMes: _toDoubleNullable(
        json['porcentajeMes'],
      ),
      ticketsSemana: _toInt(json['ticketsSemana']),
      textoSemana: json['textoSemana']?.toString() ?? '',
      subtextoSemana:
          json['subtextoSemana']?.toString() ?? '',
      porcentajeSemana: _toDoubleNullable(
        json['porcentajeSemana'],
      ),
      tiempoPromedio:
          json['tiempoPromedio']?.toString() ?? 'Sin datos',
      textoTiempo: json['textoTiempo']?.toString() ?? '',
      subtextoTiempo:
          json['subtextoTiempo']?.toString() ?? '',
      porcentajeTiempo: _toDoubleNullable(
        json['porcentajeTiempo'],
      ),
      quejasRecurrentes:
          (json['quejasRecurrentes'] as List? ?? [])
              .map(
                (item) => QuejaRecurrente.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      equipos: (json['equipos'] as List? ?? [])
          .map(
            (item) => EquipoAdmin.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      equipoMayorRecurrencia:
          json['equipoMayorRecurrencia'] != null
              ? EquipoAdmin.fromJson(
                  Map<String, dynamic>.from(
                    json['equipoMayorRecurrencia'],
                  ),
                )
              : null,
      ubicaciones: (json['ubicaciones'] as List? ?? [])
          .map(
            (item) => UbicacionAdmin.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      evolucionTickets:
          (json['evolucionTickets'] as List? ?? [])
              .map(
                (item) => EvolucionPunto.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      promedioEvolucion:
          _toDouble(json['promedioEvolucion']),
      maximoEvolucion:
          _toInt(json['maximoEvolucion']),
      minimoEvolucion:
          _toInt(json['minimoEvolucion']),
      periodo: json['periodo']?.toString() ?? 'semana',
      fechaInicio: json['fechaInicio']?.toString(),
      fechaFin: json['fechaFin']?.toString(),
    );
  }
}

class UsuarioAdmin {
  final String login;
  final String? name;
  final String? email;

  const UsuarioAdmin({
    required this.login,
    required this.name,
    required this.email,
  });

  factory UsuarioAdmin.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsuarioAdmin(
      login: json['login']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class NotificacionAdmin {
  final Map<String, dynamic> data;

  const NotificacionAdmin({
    required this.data,
  });

  factory NotificacionAdmin.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificacionAdmin(
      data: json,
    );
  }

  dynamic operator [](String key) => data[key];
}

class QuejaRecurrente {
  final String tipoFalla;
  final int total;
  final double porcentaje;

  const QuejaRecurrente({
    required this.tipoFalla,
    required this.total,
    required this.porcentaje,
  });

  factory QuejaRecurrente.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuejaRecurrente(
      tipoFalla: json['tipo_falla']?.toString() ?? '',
      total: _toInt(json['total']),
      porcentaje: _toDouble(json['porcentaje']),
    );
  }
}

class EquipoAdmin {
  final String equipo;
  final int fallas;
  final String? primeraIncidencia;
  final String? ultimaIncidencia;
  final String tipo;
  final String icono;

  const EquipoAdmin({
    required this.equipo,
    required this.fallas,
    required this.primeraIncidencia,
    required this.ultimaIncidencia,
    required this.tipo,
    required this.icono,
  });

  factory EquipoAdmin.fromJson(
    Map<String, dynamic> json,
  ) {
    return EquipoAdmin(
      equipo: json['equipo']?.toString() ?? '',
      fallas: _toInt(json['fallas']),
      primeraIncidencia:
          json['primera_incidencia']?.toString(),
      ultimaIncidencia:
          json['ultima_incidencia']?.toString(),
      tipo: json['tipo']?.toString() ?? 'Equipo',
      icono: json['icono']?.toString() ?? 'monitor',
    );
  }
}

class UbicacionAdmin {
  final int id;
  final String nombre;
  final int total;
  final double porcentaje;

  const UbicacionAdmin({
    required this.id,
    required this.nombre,
    required this.total,
    required this.porcentaje,
  });

  factory UbicacionAdmin.fromJson(
    Map<String, dynamic> json,
  ) {
    return UbicacionAdmin(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      total: _toInt(json['total']),
      porcentaje: _toDouble(json['porcentaje']),
    );
  }
}

class EvolucionPunto {
  final String fecha;
  final String fechaCompleta;
  final int total;

  const EvolucionPunto({
    required this.fecha,
    required this.fechaCompleta,
    required this.total,
  });

  factory EvolucionPunto.fromJson(
    Map<String, dynamic> json,
  ) {
    return EvolucionPunto(
      fecha: json['fecha']?.toString() ?? '',
      fechaCompleta:
          json['fecha_completa']?.toString() ?? '',
      total: _toInt(json['total']),
    );
  }
}

class EvolucionData {
  final String periodo;
  final List<EvolucionPunto> evolucionTickets;
  final double promedioEvolucion;
  final int maximoEvolucion;
  final int minimoEvolucion;

  const EvolucionData({
    required this.periodo,
    required this.evolucionTickets,
    required this.promedioEvolucion,
    required this.maximoEvolucion,
    required this.minimoEvolucion,
  });

  factory EvolucionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return EvolucionData(
      periodo: json['periodo']?.toString() ?? 'semana',
      evolucionTickets:
          (json['evolucionTickets'] as List? ?? [])
              .map(
                (item) => EvolucionPunto.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      promedioEvolucion:
          _toDouble(json['promedioEvolucion']),
      maximoEvolucion:
          _toInt(json['maximoEvolucion']),
      minimoEvolucion:
          _toInt(json['minimoEvolucion']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

double? _toDoubleNullable(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value.toString(),
  );
}
