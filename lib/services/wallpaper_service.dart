import 'dart:io';
import 'package:flutter/services.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperService {
  static const int HOME_SCREEN = 1;
  static const int LOCK_SCREEN = 2;
  static const int BOTH_SCREEN = 3;
  static const String _wallpaperPathKey = 'current_wallpaper_path';

  // Método para establecer fondo de pantalla desde archivo
  static Future<bool> setWallpaperFromFile(String filePath, {int location = BOTH_SCREEN}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }

      final wallpaperManager = WallpaperManagerFlutter();
      
      int wallpaperLocation;
      switch (location) {
        case HOME_SCREEN:
          wallpaperLocation = WallpaperManagerFlutter.homeScreen;
          break;
        case LOCK_SCREEN:
          wallpaperLocation = WallpaperManagerFlutter.lockScreen;
          break;
        case BOTH_SCREEN:
        default:
          wallpaperLocation = WallpaperManagerFlutter.bothScreens;
          break;
      }

      final result = await wallpaperManager.setWallpaper(
        file,
        wallpaperLocation,
      );
      
      // Guardar la ruta del wallpaper en SharedPreferences
      if (result) {
        await _saveWallpaperPath(filePath);
      }
      
      return result;
    } catch (e) {
      print('Error al establecer fondo de pantalla: $e');
      return false;
    }
  }

  // Método para establecer fondo de pantalla desde asset
  static Future<bool> setWallpaperFromAsset(String assetPath, {int location = BOTH_SCREEN}) async {
    try {
      // Para assets, necesitamos copiar el archivo a un directorio permanente
      final byteData = await rootBundle.load(assetPath);
      final appDir = await getApplicationDocumentsDirectory();
      final wallpapersDir = Directory('${appDir.path}/wallpapers');
      
      // Crear directorio si no existe
      if (!await wallpapersDir.exists()) {
        await wallpapersDir.create(recursive: true);
      }
      
      // Crear archivo permanente con nombre único basado en el asset
      final fileName = assetPath.split('/').last;
      final permanentFile = File('${wallpapersDir.path}/$fileName');
      await permanentFile.writeAsBytes(byteData.buffer.asUint8List());
      
      // Usar el método setWallpaperFromFile con el archivo permanente
      final result = await setWallpaperFromFile(permanentFile.path, location: location);
      
      return result;
    } catch (e) {
      print('Error al establecer fondo de pantalla desde asset: $e');
      return false;
    }
  }

  // Método para obtener imágenes de la galería
  static Future<List<String>> getGalleryImages() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return [];
      
      // Buscar en directorios comunes de imágenes
      final commonImageDirs = [
        '/storage/emulated/0/DCIM/Camera',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Download',
        '${directory.path}/Pictures',
      ];
      
      List<String> imageFiles = [];
      
      for (String dirPath in commonImageDirs) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          for (var file in files) {
            if (file is File && _isImageFile(file.path)) {
              imageFiles.add(file.path);
            }
          }
        }
      }
      
      return imageFiles;
    } catch (e) {
      print('Error obteniendo imágenes de galería: $e');
      return [];
    }
  }

  // Método para obtener fondos de pantalla por defecto
  static Future<List<String>> getDefaultWallpapers() async {
    try {
      // Lista de fondos de pantalla incluidos en assets
      final defaultWallpapers = [
        'assets/wallpapers/wallpaper-1.jpg',
        'assets/wallpapers/wallpaper-2.jpg',
        'assets/wallpapers/wallpaper-3.jpg',
      ];
      
      // Filtrar solo los que realmente existen
      List<String> existingWallpapers = [];
      
      for (String assetPath in defaultWallpapers) {
        try {
          await rootBundle.load(assetPath);
          existingWallpapers.add(assetPath);
        } catch (e) {
          // El asset no existe, continuar con el siguiente
          continue;
        }
      }
      
      return existingWallpapers;
    } catch (e) {
      print('Error obteniendo fondos por defecto: $e');
      return [];
    }
  }

  // Método auxiliar para verificar si un archivo es una imagen
  static bool _isImageFile(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.bmp', '.webp'];
    final lowerPath = path.toLowerCase();
    return extensions.any((ext) => lowerPath.endsWith(ext));
  }

  // Método para obtener la ruta del fondo de pantalla actual
  static Future<String?> getCurrentWallpaperPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_wallpaperPathKey);
    } catch (e) {
      print('Error obteniendo ruta del wallpaper: $e');
      return null;
    }
  }

  // Método privado para guardar la ruta del wallpaper
  static Future<void> _saveWallpaperPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperPathKey, path);
    } catch (e) {
      print('Error guardando ruta del wallpaper: $e');
    }
  }

  // Método para limpiar el fondo de pantalla
  static Future<bool> clearWallpaper() async {
    // Este plugin no proporciona un método clear()
    // Podrías establecer un fondo de pantalla por defecto en su lugar
    return false;
  }
}