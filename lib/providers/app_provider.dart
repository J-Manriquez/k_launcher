import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_info.dart';
import '../services/launcher_service.dart';
import '../services/wallpaper_service.dart';

class AppProvider extends ChangeNotifier {
  List<AppInfo> _installedApps = [];
  List<AppInfo> _filteredApps = [];
  List<AppInfo> _recentApps = [];
  List<AppInfo> _favoriteApps = [];
  List<AppInfo> _homeScreenApps = [];
  List<List<AppInfo>> _homeScreenPages = [[]];
  Map<int, AppInfo> _homeGridPositions = {}; // Nueva: posiciones específicas en el grid
  File? _currentWallpaper;
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<AppInfo> get installedApps => _installedApps;
  List<AppInfo> get filteredApps => _filteredApps;
  List<AppInfo> get recentApps => _recentApps;
  List<AppInfo> get favoriteApps => _favoriteApps;
  List<AppInfo> get homeScreenApps => _homeScreenApps;
  List<List<AppInfo>> get homeScreenPages => _homeScreenPages;
  Map<int, AppInfo> get homeGridPositions => _homeGridPositions;
  File? get currentWallpaper => _currentWallpaper;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  AppProvider() {
    _loadHomeGridPositions();
  }
  
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
      
      // Cargar posiciones del grid guardadas
      await _loadHomeGridPositions();
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
    bool success;
    
    // Check if it's an asset path
    if (imagePath.startsWith('assets/')) {
      success = await WallpaperService.setWallpaperFromAsset(imagePath);
    } else {
      success = await WallpaperService.setWallpaperFromFile(imagePath);
    }
    
    if (success) {
      // For assets, create a temporary file or handle differently
      if (imagePath.startsWith('assets/')) {
        // Force refresh of wallpaper display
        _currentWallpaper = null;
        // Load the current wallpaper after setting
        await _loadCurrentWallpaper();
      } else {
        _currentWallpaper = File(imagePath);
      }
      notifyListeners();
    } else {
      throw Exception('Failed to set wallpaper');
    }
  }
  
  Future<void> _loadCurrentWallpaper() async {
    final wallpaperPath = await WallpaperService.getCurrentWallpaperPath();
    
    if (wallpaperPath != null && File(wallpaperPath).existsSync()) {
      _currentWallpaper = File(wallpaperPath);
    }
  }
  
  // Nuevos métodos para manejar posiciones específicas en el grid
  void addToHomeGridPosition(AppInfo app, int position) {
    _homeGridPositions[position] = app;
    _updateHomeScreenApps();
    _saveHomeGridPositions();
    notifyListeners();
  }
  
  void removeFromHomeGridPosition(int position) {
    _homeGridPositions.remove(position);
    _updateHomeScreenApps();
    _saveHomeGridPositions();
    notifyListeners();
  }
  
  void moveAppInHomeGrid(int fromPosition, int toPosition) {
    if (_homeGridPositions.containsKey(fromPosition)) {
      final app = _homeGridPositions[fromPosition]!;
      _homeGridPositions.remove(fromPosition);
      _homeGridPositions[toPosition] = app;
      _updateHomeScreenApps();
      _saveHomeGridPositions();
      notifyListeners();
    }
  }
  
  AppInfo? getAppAtPosition(int position) {
    return _homeGridPositions[position];
  }
  
  int? getPositionOfApp(String packageName) {
    for (var entry in _homeGridPositions.entries) {
      if (entry.value.packageName == packageName) {
        return entry.key;
      }
    }
    return null;
  }
  
  Future<void> _saveHomeGridPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> positionsMap = {};
      
      for (var entry in _homeGridPositions.entries) {
        positionsMap[entry.key.toString()] = jsonEncode({
          'packageName': entry.value.packageName,
          'name': entry.value.name,
        });
      }
      
      await prefs.setString('home_grid_positions', jsonEncode(positionsMap));
    } catch (e) {
      print('Error guardando posiciones del grid: $e');
    }
  }
  
  Future<void> _loadHomeGridPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? positionsJson = prefs.getString('home_grid_positions');
      
      if (positionsJson != null) {
        final Map<String, dynamic> positionsMap = jsonDecode(positionsJson);
        _homeGridPositions.clear();
        
        for (var entry in positionsMap.entries) {
          final int position = int.parse(entry.key);
          final Map<String, dynamic> appData = jsonDecode(entry.value);
          
          // Buscar la app en las aplicaciones instaladas
          final app = _installedApps.firstWhere(
            (installedApp) => installedApp.packageName == appData['packageName'],
            orElse: () => AppInfo(
              packageName: appData['packageName'],
              name: appData['name'],
              icon: null,
            ),
          );
          
          _homeGridPositions[position] = app;
        }
        
        _updateHomeScreenApps();
      }
    } catch (e) {
      print('Error cargando posiciones del grid: $e');
    }
  }
  
  void addToHomeScreen(AppInfo app, {int pageIndex = 0}) {
    // Buscar la primera posición disponible
    int position = 0;
    while (_homeGridPositions.containsKey(position)) {
      position++;
    }
    addToHomeGridPosition(app, position);
  }
  
  void removeFromHomeScreen(String packageName) {
    final position = getPositionOfApp(packageName);
    if (position != null) {
      removeFromHomeGridPosition(position);
    }
  }
  
  void moveAppInHomeScreen(int fromPageIndex, int fromIndex, int toPageIndex, int toIndex) {
    // Esta función ahora usa el nuevo sistema de posiciones
    moveAppInHomeGrid(fromIndex, toIndex);
  }
  
  void _updateHomeScreenApps() {
    _homeScreenApps = _homeGridPositions.values.toList();
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
  
  bool isInHomeScreen(String packageName) {
    return _homeGridPositions.values.any((app) => app.packageName == packageName);
  }
}