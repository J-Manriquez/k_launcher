import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/widget_service.dart';
import '../providers/app_provider.dart';
import '../models/widget_info.dart';

class WidgetSelectorSheet extends StatefulWidget {
  final AppProvider appProvider;

  const WidgetSelectorSheet({super.key, required this.appProvider});

  @override
  State<WidgetSelectorSheet> createState() => _WidgetSelectorSheetState();
}

class _WidgetSelectorSheetState extends State<WidgetSelectorSheet> {
  List<Map<String, dynamic>> appsWithWidgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppsWithWidgets();
    
    // Configurar callbacks de permisos
    WidgetService.setPermissionCallbacks(
      onPermissionGranted: _onWidgetPermissionGranted,
      onPermissionDenied: _onWidgetPermissionDenied,
    );
  }
  
  void _onWidgetPermissionGranted(int widgetId, String provider) {
    // Reintenta crear el widget después de obtener permisos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso concedido, creando widget...')),
    );
    // Aquí puedes reintentar la creación del widget
  }
  
  void _onWidgetPermissionDenied(int widgetId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso denegado para crear widget')),
    );
  }

  Future<void> _loadAppsWithWidgets() async {
    try {
      final apps = await WidgetService.getAppsWithWidgets();
      setState(() {
        appsWithWidgets = apps;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading apps with widgets: $e');
      setState(() {
        appsWithWidgets = []; // Lista vacía en caso de error
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando widgets: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seleccionar Widget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : appsWithWidgets.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron widgets disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appsWithWidgets.length,
                    itemBuilder: (context, index) {
                      final app = appsWithWidgets[index];
                      return _buildAppWithWidgets(app);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppWithWidgets(Map<String, dynamic> app) {
    // Validar que 'widgets' existe y es una lista
    final dynamic widgetsData = app['widgets'];
    final List<Map<String, dynamic>> widgets = [];

    if (widgetsData is List) {
      for (final widget in widgetsData) {
        if (widget is Map) {
          widgets.add(Map<String, dynamic>.from(widget));
        }
      }
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: _buildAppIcon(app),
        title: Text(
          app['appName']?.toString() ?? 'App desconocida',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${widgets.length} widget(s) disponible(s)',
          style: const TextStyle(color: Colors.grey),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.grey,
        children: widgets.map((widget) => _buildWidgetTile(widget)).toList(),
      ),
    );
  }

  Widget _buildAppIcon(Map<String, dynamic> app) {
    if (app['icon'] != null && app['icon'].toString().isNotEmpty) {
      try {
        final iconData = app['icon'].toString().trim();
        if (iconData.isNotEmpty) {
          return Image.memory(
            base64Decode(iconData),
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading app icon: $error');
              return const Icon(Icons.apps, color: Colors.white);
            },
          );
        }
      } catch (e) {
        print('Error decoding base64 icon: $e');
      }
    }
    return const Icon(Icons.apps, color: Colors.white);
  }

  Widget _buildWidgetTile(Map<String, dynamic> widget) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      title: Text(
        widget['widgetName'],
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Tamaño: ${widget['minWidth']}x${widget['minHeight']}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: ElevatedButton(
        onPressed: () => _addWidget(widget),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: const Text('Agregar'),
      ),
    );
  }

  Future<void> _addWidget(Map<String, dynamic> widgetData) async {
    try {
      // Crear el widget nativo con dimensiones automáticas
      final result = await WidgetService.createWidget(
        widgetData['provider'], // providerName
        0, // width - será calculado automáticamente
        0, // height - será calculado automáticamente
      );
  
      if (result != null) {
        if (result['requiresPermission'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitando permiso para crear widget...')),
          );
          return;
        }
        
        if (result != null && result['requiresPermission'] == false) {
          print('Creating WidgetInfo with nativeWidgetId: ${result['widgetId']}');
          
          final widgetInfo = WidgetInfo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: widgetData['widgetName'],
            packageName: widgetData['provider'].split('/')[0],
            className: widgetData['provider'].split('/')[1],
            nativeWidgetId: result['widgetId'] as int,
            width: result['gridWidth'] as int, // Usar dimensiones calculadas automáticamente
            height: result['gridHeight'] as int,
            imageData: result['image'] as String?,
          );
          
          print('WidgetInfo created with nativeWidgetId: ${widgetInfo.nativeWidgetId}');
          
          // Encontrar posición vacía en el grid
          final position = widget.appProvider.findEmptyPosition(
            widgetInfo.width,
            widgetInfo.height,
          );
          if (position != null) {
            widget.appProvider.addWidgetToHomeGrid(widgetInfo, position);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Widget agregado exitosamente')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay espacio suficiente en el grid'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear widget')),
        );
      }
    } catch (e) {
      print('Error in _addWidget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Eliminar el diálogo de tamaño ya que ahora es automático
  // Future<Map<String, int>?> _showSizeDialog() async { ... } // ELIMINAR ESTA FUNCIÓN
}
