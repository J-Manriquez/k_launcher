import 'package:flutter/services.dart';
import '../models/app_info.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('k_launcher/launcher');
  
  static Future<void> initialize() async {
    // Inicialización del servicio
  }
  
  /// Obtiene la lista de aplicaciones instaladas (desde caché o sistema)
  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('getInstalledApps');
      return apps.map((app) => AppInfo.fromNativeMap(Map<String, dynamic>.from(app))).toList();
    } catch (e) {
      print('Error obteniendo aplicaciones: $e');
      return [];
    }
  }
  
  /// Fuerza la carga de aplicaciones desde el sistema (actualiza caché)
  static Future<List<AppInfo>> loadAppsFromSystem() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('loadAppsFromSystem');
      return apps.map((app) => AppInfo.fromNativeMap(Map<String, dynamic>.from(app))).toList();
    } catch (e) {
      print('Error cargando aplicaciones desde el sistema: $e');
      return [];
    }
  }
  
  /// Lanza una aplicación por su packageName
  static Future<void> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod('launchApp', {'packageName': packageName});
    } catch (e) {
      print('Error lanzando aplicación $packageName: $e');
      throw e;
    }
  }
  
  /// Abre la configuración de una aplicación
  static Future<void> openAppInfo(String packageName) async {
    try {
      await _channel.invokeMethod('openAppInfo', {'packageName': packageName});
    } catch (e) {
      print('Error abriendo información de $packageName: $e');
      throw e;
    }
  }
  
  /// Actualiza el estado habilitado/deshabilitado de una aplicación
  static Future<void> updateAppState(String packageName, bool isEnabled) async {
    try {
      await _channel.invokeMethod('updateAppState', {
        'packageName': packageName,
        'isEnabled': isEnabled,
      });
    } catch (e) {
      print('Error actualizando estado de $packageName: $e');
      throw e;
    }
  }
  
  /// Obtiene la fecha de la última actualización de la lista de apps
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
      await _channel.invokeMethod('setAsDefaultLauncher');
    } catch (e) {
      print('Error configurando launcher por defecto: $e');
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