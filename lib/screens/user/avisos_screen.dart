import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/avisosusuario_service.dart';
import 'home_screen.dart' as home;
import 'mistickets_screen.dart';
import 'perfil_screen.dart';
import 'creartickets_screen.dart';
import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});
  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}
class _AvisosScreenState extends State<AvisosScreen> {
  String selectedFilter = 'Todos';
  int currentPage = 1;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchTimer;
  bool cargando = true;
  bool _buscando = false;
  String? error;
  List<Map<String, dynamic>> avisos = [];
  int totalAvisos = 0;
  static const int porPagina = 5;
  @override
  void initState() {
    super.initState();
    _cargarAvisos();
    searchController.addListener(_onSearchChanged);
  }
  @override
  void dispose() {
    _searchTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
  Future<void> _cargarAvisos({bool mostrarCarga = true}) async {
    if (!mounted) return;
    if (mostrarCarga) {
      setState(() {
        cargando = true;
        error = null;
      });
    } else {
      setState(() {
        _buscando = true;
        error = null;
      });
    }
    try {
      final tipo = _tipoFiltroBackend(selectedFilter);
      final respuesta = await AvisosusuarioService.obtenerAvisos(buscar: searchController.text.trim(), tipo: tipo);
      if (!mounted) return;
      if (respuesta['success'] == false) {
        final mensaje = _textoSeguro(respuesta['message']);
        throw Exception(mensaje.isNotEmpty ? mensaje : 'No se pudieron obtener los avisos.');
      }
      final lista = _convertirListaMap(respuesta['avisos']);
      final totalRespuesta = respuesta['total'];
      final total = totalRespuesta != null ? _enteroSeguro(totalRespuesta) : lista.length;
      setState(() {
        avisos = lista;
        totalAvisos = total;
        cargando = false;
        _buscando = false;
        error = null;
        final paginas = _totalPaginas;
        if (currentPage > paginas) {
          currentPage = paginas;
        }
        if (currentPage < 1) {
          currentPage = 1;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        _buscando = false;
        error = _limpiarError(e);
        avisos = [];
        totalAvisos = 0;
        currentPage = 1;
      });
    }
  }
  void _onSearchChanged() {
    _searchTimer?.cancel();
    if (mounted) {
      setState(() {});
    }
    _searchTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        currentPage = 1;
      });
      _cargarAvisos(mostrarCarga: false);
    });
  }
  String _tipoFiltroBackend(String filtro) {
    switch (filtro) {
      case 'Mantenimiento':
        return 'mantenimiento';
      case 'Falla / Incidente':
        return 'incidente';
      case 'Informativo':
        return 'informativo';
      case 'General':
        return 'general';
      default:
        return 'todos';
    }
  }
  int get _totalPaginas {
    if (totalAvisos <= 0) {
      return 1;
    }
    return (totalAvisos / porPagina).ceil();
  }
  List<Map<String, dynamic>> get _avisosPagina {
    final inicio = (currentPage - 1) * porPagina;
    if (inicio >= avisos.length) {
      return [];
    }
    final fin = inicio + porPagina;
    if (fin > avisos.length) {
      return avisos.sublist(inicio);
    }
    return avisos.sublist(inicio, fin);
  }
  int get _primerAvisoMostrado {
    if (totalAvisos == 0) {
      return 0;
    }
    return ((currentPage - 1) * porPagina) + 1;
  }
  int get _ultimoAvisoMostrado {
    if (totalAvisos == 0) {
      return 0;
    }
    final valor = currentPage * porPagina;
    return valor > totalAvisos ? totalAvisos : valor;
  }
  List<Map<String, dynamic>> _convertirListaMap(dynamic valor) {
    final resultado = <Map<String, dynamic>>[];
    if (valor is! List) {
      return resultado;
    }
    for (final item in valor) {
      if (item is Map) {
        resultado.add(Map<String, dynamic>.from(item));
      }
    }
    return resultado;
  }
  String _textoSeguro(dynamic valor) {
    if (valor == null) {
      return '';
    }
    if (valor is String) {
      return valor.trim();
    }
    if (valor is num || valor is bool) {
      return valor.toString();
    }
    if (valor is Map) {
      final posibles = [valor['nombre'], valor['name'], valor['value'], valor['descripcion'], valor['description'], valor['titulo'], valor['title'], valor['mensaje'], valor['message'], valor['texto'], valor['text'], valor['login']];
      for (final item in posibles) {
        final texto = _textoSeguro(item);
        if (texto.isNotEmpty) {
          return texto;
        }
      }
    }
    return '';
  }
  int _enteroSeguro(dynamic valor) {
    if (valor == null) {
      return 0;
    }
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    return int.tryParse(valor.toString().trim()) ?? 0;
  }
  String _limpiarError(Object error) {
    final texto = error.toString();
    if (texto.startsWith('Exception: ')) {
      return texto.substring('Exception: '.length);
    }
    return texto;
  }
  String _tituloAviso(Map<String, dynamic> aviso) {
    final valores = [aviso['titulo'], aviso['title'], aviso['nombre'], aviso['name']];
    for (final item in valores) {
      final texto = _textoSeguro(item);
      if (texto.isNotEmpty) {
        return texto;
      }
    }
    return 'Aviso';
  }
  String _descripcionAviso(Map<String, dynamic> aviso) {
    final valores = [aviso['descripcion'], aviso['description'], aviso['texto'], aviso['mensaje'], aviso['message']];
    for (final item in valores) {
      final texto = _textoSeguro(item);
      if (texto.isNotEmpty) {
        return texto;
      }
    }
    return '';
  }
  String _tipoAviso(Map<String, dynamic> aviso) {
    return _textoSeguro(aviso['tipo']).toLowerCase().trim();
  }
  String _prioridadAviso(Map<String, dynamic> aviso) {
    final valores = [aviso['importancia'], aviso['prioridad']];
    for (final item in valores) {
      final texto = _textoSeguro(item);
      if (texto.isNotEmpty) {
        return texto;
      }
    }
    return 'Normal';
  }
  String _afectaAviso(Map<String, dynamic> aviso) {
    final afectaTexto = _textoSeguro(aviso['afecta_texto']);
    if (afectaTexto.isNotEmpty) {
      return afectaTexto;
    }
    final afecta = aviso['afecta_a'];
    if (afecta is Map) {
      final tipo = _textoSeguro(afecta['tipo']).toLowerCase().trim();
      switch (tipo) {
        case 'todos':
          return 'Toda la empresa';
        case 'oficina':
          return 'Oficina';
        case 'departamentos':
          return 'Departamentos';
        case 'usuarios':
          return 'Usuarios específicos';
      }
    }
    final afectaDirecto = _textoSeguro(aviso['afecta']);
    if (afectaDirecto.isNotEmpty) {
      return afectaDirecto;
    }
    return 'Usuarios específicos';
  }
  DateTime? _fechaAviso(Map<String, dynamic> aviso) {
    final posibles = [aviso['fecha_inicio'], aviso['created_at'], aviso['updated_at'], aviso['fecha'], aviso['date']];
    for (final valor in posibles) {
      final texto = _textoSeguro(valor);
      if (texto.isEmpty) {
        continue;
      }
      final fecha = DateTime.tryParse(texto);
      if (fecha != null) {
        return fecha.toLocal();
      }
    }
    return null;
  }
  String _formatearFecha(Map<String, dynamic> aviso) {
    final fecha = _fechaAviso(aviso);
    if (fecha == null) {
      return 'Fecha no disponible';
    }
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = _nombreMes(fecha.month);
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia $mes $anio, $hora:$minuto';
  }
  String _nombreMes(int mes) {
    const meses = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    if (mes >= 1 && mes <= 12) {
      return meses[mes];
    }
    return '';
  }
  bool _estaFijado(Map<String, dynamic> aviso) {
    final valor = aviso['fijado_activo'];
    if (valor == true) {
      return true;
    }
    if (valor is num && valor.toInt() == 1) {
      return true;
    }
    if (valor is String) {
      final texto = valor.toLowerCase().trim();
      return texto == '1' || texto == 'true' || texto == 'si' || texto == 'sí';
    }
    return false;
  }
  String _archivoAviso(Map<String, dynamic> aviso) {
    final archivo = _textoSeguro(aviso['archivo']);
    if (archivo.isNotEmpty) {
      return archivo;
    }
    return AvisosusuarioService.obtenerArchivoUrl(aviso) ?? '';
  }
  String _nombreArchivo(String ruta) {
    final uri = Uri.tryParse(ruta);
    if (uri != null && uri.path.isNotEmpty) {
      final partes = uri.path.split('/');
      if (partes.isNotEmpty && partes.last.isNotEmpty) {
        return Uri.decodeComponent(partes.last);
      }
    }
    final partes = ruta.split('/');
    if (partes.isNotEmpty && partes.last.isNotEmpty) {
      return partes.last;
    }
    return 'Archivo';
  }
  String _extensionArchivo(String ruta) {
    final nombre = _nombreArchivo(ruta);
    final posicion = nombre.lastIndexOf('.');
    if (posicion == -1) {
      return '';
    }
    return nombre.substring(posicion + 1).toLowerCase();
  }
  bool _esImagen(String ruta) {
    const extensiones = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    return extensiones.contains(_extensionArchivo(ruta));
  }
  bool _esPdf(String ruta) {
    return _extensionArchivo(ruta) == 'pdf';
  }
  bool _esVideo(String ruta) {
    const extensiones = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp'];
    return extensiones.contains(_extensionArchivo(ruta));
  }
  String _urlArchivo(Map<String, dynamic> aviso) {
    return AvisosusuarioService.obtenerArchivoUrl(aviso) ?? '';
  }
  Future<void> _abrirArchivo(Map<String, dynamic> aviso) async {
    final url = _urlArchivo(aviso);
    if (url.isEmpty) {
      if (!mounted) return;
      home.showUserMessage(context, 'Este aviso no tiene un archivo válido.', isError: true);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      if (!mounted) return;
      home.showUserMessage(context, 'La dirección del archivo no es válida.', isError: true);
      return;
    }
    try {
      final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abierto && mounted) {
        home.showUserMessage(context, 'No se pudo abrir el archivo.', isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      home.showUserMessage(context, 'No se pudo abrir el archivo.', isError: true);
    }
  }
  IconData _iconoArchivo(String ruta) {
    if (_esImagen(ruta)) {
      return Icons.image_outlined;
    }
    if (_esPdf(ruta)) {
      return Icons.picture_as_pdf_outlined;
    }
    if (_esVideo(ruta)) {
      return Icons.video_library_outlined;
    }
    return Icons.attach_file_rounded;
  }
  Color _colorArchivo(String ruta) {
    if (_esImagen(ruta)) {
      return const Color(0xFF06B6D4);
    }
    if (_esPdf(ruta)) {
      return const Color(0xFFEF4444);
    }
    if (_esVideo(ruta)) {
      return const Color(0xFFA855F7);
    }
    return const Color(0xFF3B82F6);
  }
  String _tipoArchivo(String ruta) {
    if (_esImagen(ruta)) {
      return 'Imagen';
    }
    if (_esPdf(ruta)) {
      return 'Documento PDF';
    }
    if (_esVideo(ruta)) {
      return 'Video';
    }
    final extension = _extensionArchivo(ruta);
    if (extension.isNotEmpty) {
      return 'Archivo ${extension.toUpperCase()}';
    }
    return 'Archivo adjunto';
  }
  IconData _iconoAviso(String tipo) {
    switch (tipo) {
      case 'mantenimiento':
        return Icons.settings_outlined;
      case 'incidente':
      case 'falla':
        return Icons.error_outline_rounded;
      case 'informativo':
      case 'info':
        return Icons.info_outline_rounded;
      case 'general':
        return Icons.notifications_none_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
  Color _colorAviso(String tipo) {
    switch (tipo) {
      case 'mantenimiento':
        return const Color(0xFFF59E0B);
      case 'incidente':
      case 'falla':
        return const Color(0xFFEF4444);
      case 'informativo':
      case 'info':
        return const Color(0xFF06B6D4);
      case 'general':
        return Colors.grey;
      default:
        return const Color(0xFF3B82F6);
    }
  }
  Color _fondoAviso(String tipo) {
    switch (tipo) {
      case 'mantenimiento':
        return const Color(0xFF2B1C08);
      case 'incidente':
      case 'falla':
        return const Color(0xFF3B1219);
      case 'informativo':
      case 'info':
        return const Color(0xFF0C2A3A);
      case 'general':
        return const Color(0xFF1E293B);
      default:
        return const Color(0xFF101D3A);
    }
  }
  Color _fondoCategoria(String tipo) {
    switch (tipo) {
      case 'mantenimiento':
        return const Color(0xFF38240D);
      case 'incidente':
      case 'falla':
        return const Color(0xFF3B1219);
      case 'informativo':
      case 'info':
        return const Color(0xFF0C2A3A);
      case 'general':
        return const Color(0xFF1E293B);
      default:
        return const Color(0xFF101D3A);
    }
  }
  String _nombreCategoria(String tipo) {
    switch (tipo) {
      case 'mantenimiento':
        return 'MANTENIMIENTO';
      case 'incidente':
      case 'falla':
        return 'FALLA / INCIDENTE';
      case 'informativo':
      case 'info':
        return 'INFORMATIVO';
      case 'general':
        return 'GENERAL';
      default:
        return tipo.isEmpty ? 'AVISO' : tipo.toUpperCase();
    }
  }
  Color _colorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase().trim()) {
      case 'critica':
      case 'crítica':
        return const Color(0xFFEF4444);
      case 'alta':
        return const Color(0xFFF97316);
      case 'media':
        return const Color(0xFFF59E0B);
      case 'normal':
      case 'baja':
        return const Color(0xFF22C55E);
      default:
        return Colors.grey;
    }
  }
  Color _fondoPrioridad(String prioridad) {
    switch (prioridad.toLowerCase().trim()) {
      case 'critica':
      case 'crítica':
        return const Color(0xFF3B1219);
      case 'alta':
        return const Color(0xFF381B13);
      case 'media':
        return const Color(0xFF38240D);
      case 'normal':
      case 'baja':
        return const Color(0xFF12301D);
      default:
        return const Color(0xFF1E293B);
    }
  }
  void _seleccionarFiltro(String filtro) {
    if (selectedFilter == filtro) {
      return;
    }
    setState(() {
      selectedFilter = filtro;
      currentPage = 1;
    });
    _cargarAvisos();
  }
  void _cambiarPagina(int pagina) {
    if (pagina < 1 || pagina > _totalPaginas || pagina == currentPage) {
      return;
    }
    setState(() {
      currentPage = pagina;
    });
  }
  void _mostrarDetalle(Map<String, dynamic> aviso) {
    final tipo = _tipoAviso(aviso);
    final titulo = _tituloAviso(aviso);
    final descripcion = _descripcionAviso(aviso);
    final prioridad = _prioridadAviso(aviso);
    final afecta = _afectaAviso(aviso);
    final fecha = _formatearFecha(aviso);
    final icono = _iconoAviso(tipo);
    final color = _colorAviso(tipo);
    final archivo = _archivoAviso(aviso);
    final urlArchivo = _urlArchivo(aviso);
    final tieneArchivo = urlArchivo.isNotEmpty;
    final esImagen = _esImagen(archivo.isNotEmpty ? archivo : urlArchivo);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF0D1427),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(color: _fondoAviso(tipo), borderRadius: BorderRadius.circular(9)),
                        child: Icon(icono, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _fondoCategoria(tipo), borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                _nombreCategoria(tipo),
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              titulo,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (descripcion.isNotEmpty) Text(descripcion, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  if (tieneArchivo) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 14),
                    const Text(
                      'Archivo adjunto',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (esImagen) _buildVistaPreviaImagen(urlArchivo) else _buildArchivoAdjunto(aviso, archivo.isNotEmpty ? archivo : urlArchivo),
                  ],
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  _detalleFila(Icons.priority_high_rounded, 'Prioridad', prioridad, _colorPrioridad(prioridad)),
                  _detalleFila(Icons.groups_outlined, 'Afecta a', afecta, Colors.white),
                  _detalleFila(Icons.calendar_today_outlined, 'Fecha', fecha, Colors.white),
                  if (_estaFijado(aviso)) _detalleFila(Icons.push_pin_outlined, 'Estado', 'Aviso fijado', Colors.amber),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildVistaPreviaImagen(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 180, maxHeight: 400),
        color: const Color(0xFF060A17),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            final value = loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null;
            return SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(value: value)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 42),
                    const SizedBox(height: 10),
                    const Text('No se pudo cargar la vista previa', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final uri = Uri.tryParse(url);
                        if (uri != null) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Abrir imagen'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildArchivoAdjunto(Map<String, dynamic> aviso, String ruta) {
    final color = _colorArchivo(ruta);
    final icono = _iconoArchivo(ruta);
    return InkWell(
      onTap: () => _abrirArchivo(aviso),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nombreArchivo(ruta),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(_tipoArchivo(ruta), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new_rounded, color: Color(0xFF3B82F6), size: 19),
          ],
        ),
      ),
    );
  }
  Widget _detalleFila(IconData icon, String titulo, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              titulo,
              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
              iconTheme: const IconThemeData(color: Colors.white),
              title: const home.AppLogo(fontSize: 20),
              actions: [
                home.UserHeaderActions(onNotifications: () => home.showUserNotifications(context)),
                const SizedBox(width: 16),
              ],
            ),
      drawer: isDesktop ? null : const AppNavigationDrawer(activeRoute: 'Avisos'),
      body: Row(
        children: [
          if (isDesktop) const SizedBox(width: 260, child: AppNavigationDrawer(activeRoute: 'Avisos')),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _cargarAvisos(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(isDesktop), const SizedBox(height: 20), _buildFilterAndSearch(isDesktop), const SizedBox(height: 20), if (error != null) _buildError(), _buildAvisosContainer(screenWidth)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(bool isDesktop) {
    if (!isDesktop) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avisos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text('Mantente informado sobre mantenimientos, fallas y actualizaciones', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avisos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text('Mantente informado sobre mantenimientos, fallas y actualizaciones', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            home.UserHeaderActions(onNotifications: () => home.showUserNotifications(context)),
          ],
        ),
      ],
    );
  }
  Widget _buildFilterAndSearch(bool isDesktop) {
    final filtros = [
      {'label': 'Todos', 'color': Colors.white, 'background': const Color(0xFF2563EB)},
      {'label': 'Mantenimiento', 'color': const Color(0xFFF59E0B), 'background': const Color(0xFF38240D)},
      {'label': 'Falla / Incidente', 'color': const Color(0xFFEF4444), 'background': const Color(0xFF3B1219)},
      {'label': 'Informativo', 'color': const Color(0xFF06B6D4), 'background': const Color(0xFF0C2A3A)},
      {'label': 'General', 'color': Colors.grey, 'background': const Color(0xFF1E293B)},
    ];
    final filtroWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filtros.map((filtro) {
          final label = filtro['label'] as String;
          final color = filtro['color'] as Color;
          final background = filtro['background'] as Color;
          final seleccionado = selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _seleccionarFiltro(label),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: seleccionado ? background : const Color(0xFF0B1021),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: seleccionado ? color.withValues(alpha: 0.5) : Colors.white12),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: seleccionado ? color : Colors.grey, fontSize: 12, fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
    final searchWidget = TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        hintText: 'Buscar aviso...',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF060A17),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 18),
        suffixIcon: _buscando
            ? const Padding(
                padding: EdgeInsets.all(11),
                child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                },
                icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 17),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
      ),
    );
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: filtroWidget),
          const SizedBox(width: 16),
          SizedBox(width: 260, child: searchWidget),
        ],
      );
    }
    return Column(
      children: [
        filtroWidget,
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: searchWidget),
      ],
    );
  }
  Widget _buildError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudieron cargar los avisos',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(error ?? 'Error desconocido', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 8),
                TextButton.icon(onPressed: () => _cargarAvisos(), icon: const Icon(Icons.refresh, size: 16), label: const Text('Reintentar')),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAvisosContainer(double screenWidth) {
    if (cargando) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1021),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.12)),
        ),
        child: const LoadingScreen(mensaje: 'Cargando avisos...'),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth < 600 ? 12 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          if (_avisosPagina.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _avisosPagina.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _buildAvisoCard(_avisosPagina[index], screenWidth);
              },
            ),
          const SizedBox(height: 20),
          _buildPagination(screenWidth),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    final tieneBusqueda = searchController.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(tieneBusqueda ? Icons.search_off_rounded : Icons.notifications_none_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            tieneBusqueda ? 'No se encontraron avisos' : 'No hay avisos disponibles',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            tieneBusqueda ? 'Intenta con otro término de búsqueda.' : 'Actualmente no existen avisos dirigidos a ti.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
  Widget _buildAvisoCard(Map<String, dynamic> item, double screenWidth) {
    final isMobile = screenWidth < 768;
    final tipo = _tipoAviso(item);
    final titulo = _tituloAviso(item);
    final descripcion = _descripcionAviso(item);
    final prioridad = _prioridadAviso(item);
    final afecta = _afectaAviso(item);
    final fecha = _formatearFecha(item);
    final icono = _iconoAviso(tipo);
    final color = _colorAviso(tipo);
    final fijado = _estaFijado(item);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fijado ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _fondoAviso(tipo), borderRadius: BorderRadius.circular(8)),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      _categoriaBadge(tipo)
                    else
                      Row(
                        children: [
                          Expanded(child: _categoriaBadge(tipo)),
                          const SizedBox(width: 8),
                          _prioridadBadge(prioridad),
                        ],
                      ),
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        if (fijado) ...[const SizedBox(width: 6), const Icon(Icons.push_pin_rounded, color: Colors.amber, size: 16)],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile) ...[const SizedBox(height: 8), _prioridadBadge(prioridad)],
          if (descripcion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              descripcion,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11),
              children: [
                const TextSpan(
                  text: 'Afecta a: ',
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: afecta,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        fecha,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _mostrarDetalle(item),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver más',
                        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Color(0xFF3B82F6), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _categoriaBadge(String tipo) {
    final color = _colorAviso(tipo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _fondoCategoria(tipo), borderRadius: BorderRadius.circular(4)),
      child: Text(
        _nombreCategoria(tipo),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _prioridadBadge(String prioridad) {
    final color = _colorPrioridad(prioridad);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _fondoPrioridad(prioridad),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        prioridad,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _buildPagination(double screenWidth) {
    if (totalAvisos == 0) {
      return const SizedBox.shrink();
    }
    final small = screenWidth < 500;
    final totalPaginas = _totalPaginas;
    final paginas = _paginasVisibles(totalPaginas);
    final pageInfo = Text('Mostrando $_primerAvisoMostrado a $_ultimoAvisoMostrado de $totalAvisos avisos', style: const TextStyle(color: Colors.grey, fontSize: 12));
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageBtn(icon: Icons.chevron_left_rounded, disabled: currentPage == 1, onTap: () => _cambiarPagina(currentPage - 1)),
        const SizedBox(width: 4),
        ...paginas.map((pagina) {
          if (pagina == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: Colors.grey)),
            );
          }
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _pageNumberBtn(pagina));
        }),
        const SizedBox(width: 4),
        _pageBtn(icon: Icons.chevron_right_rounded, disabled: currentPage == totalPaginas, onTap: () => _cambiarPagina(currentPage + 1)),
      ],
    );
    if (small) {
      return Column(
        children: [
          pageInfo,
          const SizedBox(height: 12),
          FittedBox(child: controls),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: pageInfo),
        const SizedBox(width: 16),
        controls,
      ],
    );
  }
  List<int> _paginasVisibles(int total) {
    if (total <= 7) {
      return List.generate(total, (index) => index + 1);
    }
    if (currentPage <= 4) {
      return [1, 2, 3, 4, 5, -1, total];
    }
    if (currentPage >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    }
    return [1, -1, currentPage - 1, currentPage, currentPage + 1, -1, total];
  }
  Widget _pageBtn({required IconData icon, required bool disabled, required VoidCallback onTap}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: disabled ? null : onTap,
        icon: Icon(icon, size: 18, color: disabled ? Colors.white24 : Colors.grey),
      ),
    );
  }
  Widget _pageNumberBtn(int page) {
    final selected = currentPage == page;
    return InkWell(
      onTap: () => _cambiarPagina(page),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? const Color(0xFF2563EB) : Colors.white12),
        ),
        child: Text(
          '$page',
          style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({super.key, this.activeRoute = 'Inicio'});

  void _navegar(BuildContext context, String route, Widget screen) {
    if (activeRoute == route) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }
    navigateWithLoading(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1021),
      child: SafeArea(
        child: Container(
          color: const Color(0xFF0B1021),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const home.AppLogo(fontSize: 26),
              const SizedBox(height: 24),
              const Row(children: [home.UserAvatar(radius: 20), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Juan Pérez', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), Text('Administración', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey))]))]),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 20),
              _drawerItem(icon: Icons.home_rounded, title: 'Inicio', isActive: activeRoute == 'Inicio', onTap: () => _navegar(context, 'Inicio', const home.HomeScreen())),
              _drawerItem(icon: Icons.confirmation_number_outlined, title: 'Mis tickets', isActive: activeRoute == 'Mis tickets', onTap: () => _navegar(context, 'Mis tickets', const MisticketsScreen())),
              _drawerItem(icon: Icons.build_outlined, title: 'Crear ticket', isActive: activeRoute == 'Crear ticket', onTap: () => _navegar(context, 'Crear ticket', const CrearticketsScreen())),
              _drawerItem(icon: Icons.warning_amber_rounded, title: 'Avisos', isActive: activeRoute == 'Avisos', onTap: () => _navegar(context, 'Avisos', const AvisosScreen())),
              _drawerItem(icon: Icons.person_outline_rounded, title: 'Mi perfil', isActive: activeRoute == 'Mi perfil', onTap: () => _navegar(context, 'Mi perfil', const MiPerfilScreen())),
              const Spacer(),
              _drawerItem(icon: Icons.logout_rounded, title: 'Cerrar sesión', color: Colors.white70, onTap: () async { Navigator.pop(context); await SessionService.clearSession(); if (!context.mounted) return; Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, bool isActive = false, Color? color, required VoidCallback onTap}) {
    final itemColor = color ?? (isActive ? Colors.white : Colors.grey);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Material(color: isActive ? const Color(0xFF2563EB) : Colors.transparent, borderRadius: BorderRadius.circular(10), clipBehavior: Clip.antiAlias, child: ListTile(dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12), leading: Icon(icon, color: itemColor), title: Text(title, style: TextStyle(color: itemColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: onTap)));
  }
}
