import 'package:flutter/services.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('k_launcher/widgets');

  // Obtener todas las aplicaciones que tienen widgets
  static Future<List<Map<String, dynamic>>> getAppsWithWidgets() async {
    try {
      final result = await _channel.invokeMethod('getAppsWithWidgets');
      if (result == null) return [];

      // Convertir explícitamente el resultado a la estructura esperada
      final List<dynamic> resultList = List<dynamic>.from(result);
      return resultList.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(
            item.map((key, value) {
              if (key == 'widgets' && value is List) {
                return MapEntry(
                  key.toString(),
                  List<Map<String, dynamic>>.from(
                    value.map((widget) => Map<String, dynamic>.from(widget)),
                  ),
                );
              }
              // Validar y limpiar datos Base64
              if (key == 'icon' && value is String) {
                final cleanIcon = value.trim().replaceAll(RegExp(r'\s+'), '');
                return MapEntry(key.toString(), cleanIcon);
              }
              return MapEntry(key.toString(), value);
            }),
          );
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      print('Error getting apps with widgets: $e');
      return [];
    }
  }

  // Crear un nuevo widget
  static Future<Map<String, dynamic>?> createWidget(
    String providerName,
    int width,
    int height,
  ) async {
    try {
      final result = await _channel.invokeMethod('createWidget', {
        'providerName': providerName,
        'width': width,
        'height': height,
      });
      
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      print('Error creating widget: $e');
      return null;
    }
  }

  // Configurar listener para permisos de widgets
  static void setPermissionCallbacks({
    Function(int widgetId, String provider)? onPermissionGranted,
    Function(int widgetId)? onPermissionDenied,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetPermissionGranted':
          if (onPermissionGranted != null) {
            final widgetId = call.arguments['widgetId'] as int;
            final provider = call.arguments['provider'] as String;
            onPermissionGranted(widgetId, provider);
          }
          break;
        case 'onWidgetPermissionDenied':
          if (onPermissionDenied != null) {
            final widgetId = call.arguments['widgetId'] as int;
            onPermissionDenied(widgetId);
          }
          break;
      }
    });
  }

  // Actualizar un widget existente
  static Future<String?> updateWidget(
    int widgetId,
    int width,
    int height,
  ) async {
    try {
      final result = await _channel.invokeMethod('updateWidget', {
        'widgetId': widgetId,
        'width': width,
        'height': height,
      });
      return result as String?;
    } catch (e) {
      print('Error updating widget: $e');
      return null;
    }
  }

  // Eliminar un widget
  static Future<bool> deleteWidget(int widgetId) async {
    try {
      final result = await _channel.invokeMethod('deleteWidget', {
        'widgetId': widgetId,
      });
      return result as bool;
    } catch (e) {
      print('Error deleting widget: $e');
      return false;
    }
  }
}
