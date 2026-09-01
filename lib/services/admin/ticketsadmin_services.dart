import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';

class TicketsAdminServices {
  Future<Map<String, dynamic>> obtenerTickets({
    String filtro = 'todos',
    String buscar = '',
    int pagina = 1,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/tickets').replace(
        queryParameters: {
          'filtro': filtro,
          'buscar': buscar,
          'page': pagina.toString(),
        },
      ),
      headers: await _headers(),
    );
    return _decode(response, 'No se pudieron obtener los tickets.');
  }

  Future<Map<String, dynamic>> obtenerTicket(int id) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/tickets/$id'),
      headers: await _headers(),
    );
    return _decode(response, 'No se pudo obtener el ticket.');
  }

  Future<Map<String, dynamic>> tomarTicket(int ticketId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/admin/tickets/$ticketId/tomar'),
      headers: await _headers(),
    );
    return _decode(response, 'No se pudo tomar el ticket.');
  }

  Future<Map<String, dynamic>> guardarSolucion({
    required int ticketId,
    required String solucion,
    required String nombreFirmante,
    required String fechaSolucion,
    required String fechaFirma,
    required String firma,
    required bool problemaSolucionado,
    List<PlatformFile> evidencias = const <PlatformFile>[],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/admin/tickets/$ticketId/solucion'),
    );
    request.headers.addAll(await _headers());
    request.fields.addAll({
      'solucion': solucion,
      'problema_solucionado': problemaSolucionado ? '1' : '0',
      'fecha_solucion': fechaSolucion,
      'nombre_firmante': nombreFirmante,
      'fecha_firma': fechaFirma,
      'firma': firma,
    });
    for (final file in evidencias) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'evidencias[]',
          bytes,
          filename: file.name,
        ),
      );
    }

    final response = await http.Response.fromStream(await request.send());
    return _decode(response, 'No se pudo guardar la solución.');
  }

  Future<Map<String, dynamic>> agregarComentario({
    required int ticketId,
    required String mensaje,
    String? archivoPath,
    Uint8List? archivoBytes,
    String? archivoNombre,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/admin/tickets/$ticketId/comentarios'),
    );
    request.headers.addAll(await _headers());
    request.fields['mensaje'] = mensaje.trim();
    if (archivoBytes != null && archivoBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          archivoBytes,
          filename: archivoNombre ?? 'archivo',
        ),
      );
    } else if (archivoPath != null && archivoPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          archivoPath,
          filename: archivoNombre,
        ),
      );
    }
    final response = await http.Response.fromStream(await request.send());
    return _decode(response, 'No se pudo enviar el mensaje.');
  }

  Future<Map<String, String>> _headers() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida.');
    }
    return {
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response, String fallback) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Respuesta inválida del servidor.');
    }
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (data.containsKey('success') && data['success'] != true)) {
      throw Exception(data['message']?.toString() ?? fallback);
    }
    return data;
  }

  Future<Map<String, dynamic>> buscarTickets(
    String buscar, {
    String filtro = 'todos',
    int pagina = 1,
  }) => obtenerTickets(filtro: filtro, buscar: buscar, pagina: pagina);

  Future<Map<String, dynamic>> obtenerMisTickets({
    String buscar = '',
    int pagina = 1,
  }) => obtenerTickets(filtro: 'mis tickets', buscar: buscar, pagina: pagina);

  Future<Map<String, dynamic>> obtenerTicketsPendientes({
    String buscar = '',
    int pagina = 1,
  }) => obtenerTickets(filtro: 'pendiente', buscar: buscar, pagina: pagina);

  Future<Map<String, dynamic>> obtenerTicketsEnProceso({
    String buscar = '',
    int pagina = 1,
  }) => obtenerTickets(filtro: 'en proceso', buscar: buscar, pagina: pagina);

  Future<Map<String, dynamic>> obtenerTicketsSolucionados({
    String buscar = '',
    int pagina = 1,
  }) => obtenerTickets(filtro: 'solucionado', buscar: buscar, pagina: pagina);

  Future<Map<String, dynamic>> obtenerTicketsCancelados({
    String buscar = '',
    int pagina = 1,
  }) => obtenerTickets(filtro: 'cancelado', buscar: buscar, pagina: pagina);
}
