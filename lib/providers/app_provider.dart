import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_info.dart';
import '../services/launcher_service.dart';
import '../services/wallpaper_service.dart';

class AppProvider extends ChangeNotifier {
  List<AppInfo> _installedApps = [];
  List<AppInfo> _filteredApps = [];
  List<AppInfo> _recentApps = [];
  List<AppInfo> _favoriteApps = [];
  File? _currentWallpaper;
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<AppInfo> get installedApps => _installedApps;
  List<AppInfo> get filteredApps => _filteredApps;
  List<AppInfo> get recentApps => _recentApps;
  List<AppInfo> get favoriteApps => _favoriteApps;
  File? get currentWallpaper => _currentWallpaper;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  Future<void> loadInstalledApps() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _installedApps = await LauncherService.getInstalledApps();
      _filteredApps = List.from(_installedApps);
      
      // Cargar aplicaciones recientes
      _recentApps = await LauncherService.getRecentApps();
      
      // Cargar wallpaper actual
      await _loadCurrentWallpaper();
    } catch (e) {
      print('Error cargando aplicaciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void filterApps(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredApps = List.from(_installedApps);
    } else {
      _filteredApps = _installedApps
          .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    
    notifyListeners();
  }
  
  Future<void> launchApp(String packageName) async {
    await LauncherService.launchApp(packageName);
    
    // Actualizar aplicaciones recientes
    _recentApps = await LauncherService.getRecentApps();
    notifyListeners();
  }
  
  Future<void> setWallpaper(String imagePath) async {
    // Cambiar setWallpaper por setWallpaperFromFile
    final success = await WallpaperService.setWallpaperFromFile(imagePath);
    
    if (success) {
      _currentWallpaper = File(imagePath);
      notifyListeners();
    }
  }
  
  Future<void> _loadCurrentWallpaper() async {
    final wallpaperPath = await WallpaperService.getCurrentWallpaperPath();
    
    if (wallpaperPath != null && File(wallpaperPath).existsSync()) {
      _currentWallpaper = File(wallpaperPath);
    }
  }
  
  void addToFavorites(AppInfo app) {
    if (!_favoriteApps.any((favApp) => favApp.packageName == app.packageName)) {
      _favoriteApps.add(app);
      notifyListeners();
    }
  }
  
  void removeFromFavorites(String packageName) {
    _favoriteApps.removeWhere((app) => app.packageName == packageName);
    notifyListeners();
  }
  
  bool isFavorite(String packageName) {
    return _favoriteApps.any((app) => app.packageName == packageName);
  }
}