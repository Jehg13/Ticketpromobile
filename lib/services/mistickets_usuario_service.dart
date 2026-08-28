import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'session_service.dart';
class MisTicketsUsuarioService {
  static Future<Map<String,dynamic>> obtenerTickets({String buscar='',String estado='todos',int pagina=1,int perPage=10}) async {
    final token=await SessionService.getToken();
    if(token==null||token.isEmpty) throw Exception('Sesión no válida');
    final queryParameters=<String,String>{'page':pagina.toString(),'per_page':perPage.toString(),'estado':estado.trim().toLowerCase()};
    if(buscar.trim().isNotEmpty) queryParameters['buscar']=buscar.trim();
    final uri=Uri.parse('${ApiService.baseUrl}/mis-tickets').replace(queryParameters:queryParameters);
    debugPrint('🎫 GET $uri');
    try {
      final response=await http.get(uri,headers:{'Accept':'application/json','Authorization':'Bearer $token'});
      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');
      final decoded=_decodificarRespuesta(response.body);
      if(response.statusCode>=200&&response.statusCode<300) {
        if(decoded['success']!=true) throw Exception(decoded['message']?.toString()??'No se pudieron obtener los tickets');
        return decoded;
      }
      await _manejarError(response.statusCode,decoded);
      throw Exception('No se pudieron obtener los tickets');
    } on Exception {
      rethrow;
    } catch(e) {
      debugPrint('❌ Error obteniendo mis tickets: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }
  static Future<Map<String,dynamic>> obtenerTicket(int id) async {
    final token=await SessionService.getToken();
    if(token==null||token.isEmpty) throw Exception('Sesión no válida');
    final uri=Uri.parse('${ApiService.baseUrl}/mis-tickets/$id');
    debugPrint('🎫 GET $uri');
    try {
      final response=await http.get(uri,headers:{'Accept':'application/json','Authorization':'Bearer $token'});
      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');
      final decoded=_decodificarRespuesta(response.body);
      if(response.statusCode>=200&&response.statusCode<300) {
        if(decoded['success']!=true) throw Exception(decoded['message']?.toString()??'No se pudo obtener el ticket');
        return decoded;
      }
      await _manejarError(response.statusCode,decoded);
      throw Exception('No se pudo obtener el ticket');
    } on Exception {
      rethrow;
    } catch(e) {
      debugPrint('❌ Error obteniendo ticket: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }
  static Future<Map<String,dynamic>> obtenerResumen() async {
    final token=await SessionService.getToken();
    if(token==null||token.isEmpty) throw Exception('Sesión no válida');
    final uri=Uri.parse('${ApiService.baseUrl}/mis-tickets-resumen');
    debugPrint('📊 GET $uri');
    try {
      final response=await http.get(uri,headers:{'Accept':'application/json','Authorization':'Bearer $token'});
      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');
      final decoded=_decodificarRespuesta(response.body);
      if(response.statusCode>=200&&response.statusCode<300) {
        if(decoded['success']!=true) throw Exception(decoded['message']?.toString()??'No se pudo obtener el resumen');
        return decoded;
      }
      await _manejarError(response.statusCode,decoded);
      throw Exception('No se pudo obtener el resumen');
    } on Exception {
      rethrow;
    } catch(e) {
      debugPrint('❌ Error obteniendo resumen: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }
  static Future<void> _manejarError(int statusCode,Map<String,dynamic> decoded) async {
    if(statusCode==401) {
      await SessionService.clearSession();
      throw Exception(decoded['message']?.toString()??'Sesión expirada');
    }
    if(statusCode==403) throw Exception(decoded['message']?.toString()??'No tienes permiso para realizar esta acción');
    if(statusCode==404) throw Exception(decoded['message']?.toString()??'Recurso no encontrado');
    if(statusCode>=500) throw Exception(decoded['message']?.toString()??'Error interno del servidor');
    throw Exception(decoded['message']?.toString()??'No se pudo completar la solicitud');
  }
  static Map<String,dynamic> _decodificarRespuesta(String body) {
    try {
      final decoded=jsonDecode(body);
      if(decoded is Map<String,dynamic>) return decoded;
      if(decoded is Map) return Map<String,dynamic>.from(decoded);
      throw Exception('Respuesta inválida del servidor');
    } on FormatException {
      throw Exception('Respuesta inválida del servidor');
    }
  }
}