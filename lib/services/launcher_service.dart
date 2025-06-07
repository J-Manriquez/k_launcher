import 'package:flutter/services.dart';
import '../models/app_info.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('k_launcher/launcher');
  static const MethodChannel _permissionsChannel = MethodChannel('k_launcher/permissions');
  
  static Future<void> initialize() async {
    // Inicialización del servicio
  }
  
  /// Obtiene la lista de aplicaciones instaladas (desde caché o sistema)
  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('getInstalledApps');
      return apps.map((app) => AppInfo.fromNativeMap(Map<String, dynamic>.from(app))).toList();
    } catch (e) {
      print('Error obteniendo aplicaciones instaladas: $e');
      return [];
    }
  }
  
  /// Carga aplicaciones directamente del sistema
  static Future<List<AppInfo>> loadAppsFromSystem() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('loadAppsFromSystem');
      return apps.map((app) => AppInfo.fromNativeMap(Map<String, dynamic>.from(app))).toList();
    } catch (e) {
      print('Error cargando aplicaciones del sistema: $e');
      return [];
    }
  }
  
  /// Lanza una aplicación específica
  static Future<void> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod('launchApp', {'packageName': packageName});
    } catch (e) {
      print('Error lanzando aplicación: $e');
      throw e;
    }
  }
  
  /// Abre la información de una aplicación
  static Future<void> openAppInfo(String packageName) async {
    try {
      await _channel.invokeMethod('openAppInfo', {'packageName': packageName});
    } catch (e) {
      print('Error abriendo información de la aplicación: $e');
      throw e;
    }
  }
  
  /// Actualiza el estado de una aplicación
  static Future<void> updateAppState(String packageName, bool isEnabled) async {
    try {
      await _channel.invokeMethod('updateAppState', {
        'packageName': packageName,
        'isEnabled': isEnabled,
      });
    } catch (e) {
      print('Error actualizando estado de la aplicación: $e');
      throw e;
    }
  }
  
  /// Obtiene la fecha de la última actualización
  static Future<String> getLastUpdateDate() async {
    try {
      return await _channel.invokeMethod('getLastUpdateDate');
    } catch (e) {
      print('Error obteniendo fecha de actualización: $e');
      return 'Nunca';
    }
  }
  
  /// Obtiene la lista de paquetes habilitados
  static Future<List<String>> getEnabledPackages() async {
    try {
      final List<dynamic> packages = await _channel.invokeMethod('getEnabledPackages');
      return packages.cast<String>();
    } catch (e) {
      print('Error obteniendo paquetes habilitados: $e');
      return [];
    }
  }
  
  /// Configura la aplicación como launcher por defecto
  static Future<void> setAsDefaultLauncher() async {
    try {
      await _permissionsChannel.invokeMethod('setAsDefaultLauncher');
    } catch (e) {
      print('Error configurando launcher por defecto: $e');
      throw e;
    }
  }
  
  /// Verifica si la aplicación es el launcher por defecto
  static Future<bool> isDefaultLauncher() async {
    try {
      return await _permissionsChannel.invokeMethod('isDefaultLauncher');
    } catch (e) {
      print('Error verificando launcher por defecto: $e');
      return false;
    }
  }
  
  /// Resetea la configuración de launcher por defecto
  static Future<void> resetDefaultLauncher() async {
    try {
      await _permissionsChannel.invokeMethod('resetDefaultLauncher');
    } catch (e) {
      print('Error reseteando launcher por defecto: $e');
      throw e;
    }
  }
  
  /// Obtiene aplicaciones recientes (implementación futura)
  static Future<List<AppInfo>> getRecentApps() async {
    try {
      // Por ahora retornamos lista vacía, puedes implementar esto más tarde
      // usando usage stats o SharedPreferences
      return [];
    } catch (e) {
      print('Error obteniendo aplicaciones recientes: $e');
      return [];
    }
  }
}