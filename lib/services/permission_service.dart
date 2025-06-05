import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('k_launcher/permissions');
  
  static Future<void> initialize() async {
    // Inicialización del servicio
  }
  
  static Future<List<String>> checkAllPermissions() async {
    List<String> missingPermissions = [];
    
    // Verificar permisos estándar
    final permissions = [
      Permission.systemAlertWindow,
      Permission.accessNotificationPolicy,
    ];
    
    // Agregar permisos específicos según la versión de Android
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+)
      permissions.add(Permission.notification);
      
      // Para Android 11+ (API 30+) - Gestión de almacenamiento
      permissions.add(Permission.manageExternalStorage);
    }
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        missingPermissions.add(_getPermissionName(permission));
      }
    }
    
    // Verificar permisos especiales a través del canal nativo
    try {
      final hasUsageStats = await _channel.invokeMethod('hasUsageStatsPermission');
      if (!hasUsageStats) {
        missingPermissions.add('Estadísticas de uso de aplicaciones');
      }
      
      final canDrawOverlays = await _channel.invokeMethod('canDrawOverlays');
      if (!canDrawOverlays) {
        missingPermissions.add('Dibujar sobre otras aplicaciones');
      }
      
      final canWriteSettings = await _channel.invokeMethod('canWriteSettings');
      if (!canWriteSettings) {
        missingPermissions.add('Modificar configuración del sistema');
      }
      
      // Verificar gestión de almacenamiento especial
      final hasStorageManagement = await _channel.invokeMethod('hasStorageManagementPermission');
      if (!hasStorageManagement) {
        missingPermissions.add('Gestión completa de almacenamiento');
      }
    } catch (e) {
      print('Error verificando permisos nativos: $e');
    }
    
    return missingPermissions;
  }
  
  static Future<bool> requestAllPermissions() async {
    // Solicitar permisos estándar uno por uno
    final permissions = [
      Permission.systemAlertWindow,
      Permission.accessNotificationPolicy,
    ];
    
    // Agregar permisos específicos según la versión
    if (Platform.isAndroid) {
      permissions.add(Permission.notification);
    }
    
    // Solicitar permisos estándar
    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        print('Permiso denegado: $permission');
      }
    }
    
    // Solicitar permisos especiales
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
      await _channel.invokeMethod('requestOverlayPermission');
      await _channel.invokeMethod('requestWriteSettingsPermission');
      await _channel.invokeMethod('requestStorageManagementPermission');
      await _channel.invokeMethod('requestNotificationPermission');
    } catch (e) {
      print('Error solicitando permisos nativos: $e');
    }
    
    // Verificar si todos los permisos fueron concedidos
    final missing = await checkAllPermissions();
    return missing.isEmpty;
  }
  
  static String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.systemAlertWindow:
        return 'Ventana de sistema';
      case Permission.manageExternalStorage:
        return 'Gestión de almacenamiento';
      case Permission.notification:
        return 'Notificaciones';
      case Permission.accessNotificationPolicy:
        return 'Política de notificaciones';
      default:
        return permission.toString();
    }
  }
}