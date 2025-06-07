import 'package:flutter/services.dart';
import '../models/widget_info.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('k_launcher/widgets');
  
  /// Obtiene la lista de widgets disponibles en el sistema
  static Future<List<WidgetInfo>> getAvailableWidgets() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getAvailableWidgets');
      return result.map((widget) => WidgetInfo(
        id: widget['id'],
        name: widget['name'],
        packageName: widget['packageName'],
        className: widget['className'],
        width: 2, // Tamaño por defecto
        height: 2,
      )).toList();
    } catch (e) {
      print('Error obteniendo widgets: $e');
      return [];
    }
  }
  
  /// Crea una instancia de un widget
  static Future<bool> createWidget(WidgetInfo widget) async {
    try {
      final bool result = await _channel.invokeMethod('createWidget', {
        'id': widget.id,
        'packageName': widget.packageName,
        'className': widget.className,
        'configuration': widget.configuration,
      });
      return result;
    } catch (e) {
      print('Error creando widget: $e');
      return false;
    }
  }
  
  /// Actualiza la configuración de un widget
  static Future<bool> updateWidget(WidgetInfo widget) async {
    try {
      final bool result = await _channel.invokeMethod('updateWidget', {
        'id': widget.id,
        'configuration': widget.configuration,
      });
      return result;
    } catch (e) {
      print('Error actualizando widget: $e');
      return false;
    }
  }
  
  /// Elimina un widget
  static Future<bool> deleteWidget(String widgetId) async {
    try {
      final bool result = await _channel.invokeMethod('deleteWidget', {
        'id': widgetId,
      });
      return result;
    } catch (e) {
      print('Error eliminando widget: $e');
      return false;
    }
  }
}