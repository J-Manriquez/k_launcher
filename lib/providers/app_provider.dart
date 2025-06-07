import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_info.dart';
import '../services/launcher_service.dart';
import '../services/wallpaper_service.dart';
import '../models/folder_info.dart';
import '../models/widget_info.dart';
import '../services/widget_service.dart';

class AppProvider extends ChangeNotifier {
  List<AppInfo> _installedApps = [];
  List<AppInfo> _filteredApps = [];
  List<AppInfo> _recentApps = [];
  List<AppInfo> _favoriteApps = [];
  List<AppInfo> _homeScreenApps = [];
  List<List<AppInfo>> _homeScreenPages = [[]];
  // Eliminada la variable _homeGridPositions
  File? _currentWallpaper;
  bool _isLoading = false;
  String _searchQuery = '';

  List<AppInfo> get installedApps => _installedApps;
  List<AppInfo> get filteredApps => _filteredApps;
  List<AppInfo> get recentApps => _recentApps;
  List<AppInfo> get favoriteApps => _favoriteApps;
  List<AppInfo> get homeScreenApps => _homeScreenApps;
  List<List<AppInfo>> get homeScreenPages => _homeScreenPages;
  // Eliminado el getter homeGridPositions
  File? get currentWallpaper => _currentWallpaper;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<WidgetInfo> _widgets = [];
  List<WidgetInfo> get widgets => _widgets;

  AppProvider() {
    // Eliminada la llamada a _loadHomeGridPositions
    _loadFolders();
    _loadHomeGridItems();
    _loadWidgets(); // Nuevo
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
      await _loadHomeGridItems();
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

  // Método actualizado para usar solo _homeGridItems
  int? getPositionOfApp(String packageName) {
    for (var entry in _homeGridItems.entries) {
      if (entry.value is AppInfo &&
          (entry.value as AppInfo).packageName == packageName) {
        return entry.key;
      }
    }
    return null;
  }

  // Método actualizado para usar solo _homeGridItems
  void addToHomeScreen(AppInfo app, {int pageIndex = 0}) {
    // Buscar la primera posición disponible
    int position = 0;
    while (_homeGridItems.containsKey(position)) {
      position++;
    }
    addItemToHomeGridPosition(app, position);
  }

  // Método actualizado para usar solo _homeGridItems
  void removeFromHomeScreen(String packageName) {
    final position = getPositionOfApp(packageName);
    if (position != null) {
      removeItemFromHomeGridPosition(position);
    }
  }

  // Método actualizado para usar solo _homeGridItems
  void _updateHomeScreenApps() {
    _homeScreenApps = _homeGridItems.entries
        .where((entry) => entry.value is AppInfo)
        .map((entry) => entry.value as AppInfo)
        .toList();
  }

  // Método actualizado para usar solo _homeGridItems
  bool isInHomeScreen(String packageName) {
    return _homeGridItems.entries
        .where((entry) => entry.value is AppInfo)
        .any((entry) => (entry.value as AppInfo).packageName == packageName);
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

  List<FolderInfo> _folders = [];
  Map<int, dynamic> _homeGridItems = {}; // Puede contener AppInfo o FolderInfo

  List<FolderInfo> get folders => _folders;
  Map<int, dynamic> get homeGridItems => _homeGridItems;

  void createFolder(String name) {
    final folder = FolderInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    _folders.add(folder);

    // Encontrar primera posición disponible
    int position = 0;
    while (_homeGridItems.containsKey(position)) {
      position++;
    }

    _homeGridItems[position] = folder;
    _saveFolders();
    _saveHomeGridItems();
    notifyListeners();
  }

  void addAppToFolder(String folderId, AppInfo app) {
    final folderIndex = _folders.indexWhere((f) => f.id == folderId);
    if (folderIndex != -1) {
      // Verificar si la app ya existe en la carpeta para evitar duplicados
      if (_folders[folderIndex].apps.any(
        (a) => a.packageName == app.packageName,
      )) {
        return; // Si ya existe, no hacer nada
      }

      // Crear una nueva lista con todos los elementos existentes más el nuevo
      _folders[folderIndex].apps = [..._folders[folderIndex].apps, app];

      // Buscar la posición de la app en _homeGridItems
      int? appPositionInItems;
      for (var entry in _homeGridItems.entries) {
        if (entry.value is AppInfo &&
            (entry.value as AppInfo).packageName == app.packageName) {
          appPositionInItems = entry.key;
          break;
        }
      }

      // Remover app del grid principal si está en el mapa
      if (appPositionInItems != null) {
        _homeGridItems.remove(appPositionInItems);
      }

      // Buscar la posición de la carpeta en _homeGridItems para actualizarla
      int? folderPosition;
      for (var entry in _homeGridItems.entries) {
        if (entry.value is FolderInfo &&
            (entry.value as FolderInfo).id == folderId) {
          folderPosition = entry.key;
          break;
        }
      }

      // Actualizar la carpeta en _homeGridItems si existe
      if (folderPosition != null) {
        _homeGridItems[folderPosition] = _folders[folderIndex];
      }

      _updateHomeScreenApps();
      _saveFolders();
      _saveHomeGridItems();
      notifyListeners();
    }
  }

  void removeAppFromFolder(String folderId, String packageName) {
    final folderIndex = _folders.indexWhere((f) => f.id == folderId);
    if (folderIndex != -1) {
      _folders[folderIndex].apps.removeWhere(
        (app) => app.packageName == packageName,
      );

      // Buscar la posición de la carpeta en _homeGridItems para actualizarla
      int? folderPosition;
      for (var entry in _homeGridItems.entries) {
        if (entry.value is FolderInfo &&
            (entry.value as FolderInfo).id == folderId) {
          folderPosition = entry.key;
          break;
        }
      }

      // Actualizar la carpeta en _homeGridItems si existe
      if (folderPosition != null) {
        _homeGridItems[folderPosition] = _folders[folderIndex];
      }

      _saveFolders();
      _saveHomeGridItems();
      notifyListeners();
    }
  }

  void deleteFolder(String folderId) {
    _folders.removeWhere((f) => f.id == folderId);

    // Remover carpeta del grid
    final folderPosition = _homeGridItems.entries
        .where(
          (entry) => entry.value is FolderInfo && entry.value.id == folderId,
        )
        .firstOrNull
        ?.key;

    if (folderPosition != null) {
      _homeGridItems.remove(folderPosition);
    }

    _saveFolders();
    _saveHomeGridItems();
    notifyListeners();
  }

  dynamic getItemAtPosition(int position) {
    return _homeGridItems[position];
  }

  void addItemToHomeGridPosition(dynamic item, int position) {
    _homeGridItems[position] = item;
    _saveHomeGridItems();
    notifyListeners();
  }

  void removeItemFromHomeGridPosition(int position) {
    _homeGridItems.remove(position);
    _saveHomeGridItems();
    notifyListeners();
  }

  void moveItemInHomeGrid(int fromPosition, int toPosition) {
    if (_homeGridItems.containsKey(fromPosition)) {
      final item = _homeGridItems[fromPosition]!;
      _homeGridItems.remove(fromPosition);
      _homeGridItems[toPosition] = item;
      _saveHomeGridItems();
      notifyListeners();
    }
  }

  Future<void> _saveFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foldersJson = _folders.map((folder) => folder.toJson()).toList();
      await prefs.setString('folders', jsonEncode(foldersJson));
    } catch (e) {
      print('Error guardando carpetas: $e');
    }
  }

  Future<void> _loadFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foldersJson = prefs.getString('folders');

      if (foldersJson != null) {
        final List<dynamic> foldersList = jsonDecode(foldersJson);
        _folders = foldersList
            .map((json) => FolderInfo.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error cargando carpetas: $e');
    }
  }

  Future<void> _loadWidgets() async {
    await loadAvailableWidgets();
  }

  Future<void> _loadHomeGridItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('home_grid_items');

      if (itemsJson != null) {
        final Map<String, dynamic> itemsMap = jsonDecode(itemsJson);
        _homeGridItems.clear();

        for (var entry in itemsMap.entries) {
          final int position = int.parse(entry.key);
          final Map<String, dynamic> itemData = entry.value;

          if (itemData['type'] == 'app') {
            final app = _installedApps.firstWhere(
              (installedApp) =>
                  installedApp.packageName == itemData['data']['packageName'],
              orElse: () => AppInfo.fromJson(itemData['data']),
            );
            _homeGridItems[position] = app;
          } else if (itemData['type'] == 'folder') {
            final folder = FolderInfo.fromJson(itemData['data']);
            _homeGridItems[position] = folder;
          } else if (itemData['type'] == 'widget') {
            final widget = WidgetInfo.fromJson(itemData['data']);
            _homeGridItems[position] = widget;
          }
        }
      }
    } catch (e) {
      print('Error cargando items del grid: $e');
    }
  }

  Future<void> _saveHomeGridItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> itemsMap = {};

      for (var entry in _homeGridItems.entries) {
        if (entry.value is AppInfo) {
          itemsMap[entry.key.toString()] = {
            'type': 'app',
            'data': (entry.value as AppInfo).toJson(),
          };
        } else if (entry.value is FolderInfo) {
          itemsMap[entry.key.toString()] = {
            'type': 'folder',
            'data': (entry.value as FolderInfo).toJson(),
          };
        } else if (entry.value is WidgetInfo) {
          itemsMap[entry.key.toString()] = {
            'type': 'widget',
            'data': (entry.value as WidgetInfo).toJson(),
          };
        }
      }

      await prefs.setString('home_grid_items', jsonEncode(itemsMap));
    } catch (e) {
      print('Error guardando items del grid: $e');
    }
  }

  /// Carga los widgets disponibles
  Future<void> loadAvailableWidgets() async {
    try {
      _widgets = await WidgetService.getAvailableWidgets();
      notifyListeners();
    } catch (e) {
      print('Error cargando widgets: $e');
    }
  }

  /// Añade un widget a la pantalla principal
  Future<void> addWidget(WidgetInfo widget) async {
    try {
      final success = await WidgetService.createWidget(widget);
      if (success) {
        // Buscar primera posición disponible
        int position = 0;
        while (_homeGridItems.containsKey(position)) {
          position++;
        }

        _homeGridItems[position] = widget;
        _saveHomeGridItems();
        notifyListeners();
      }
    } catch (e) {
      print('Error añadiendo widget: $e');
    }
  }

  /// Actualiza el tamaño de un widget
  Future<void> updateWidgetSize(String widgetId, int width, int height) async {
    // Buscar el widget en _homeGridItems
    for (var entry in _homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widgetId) {
        final updatedWidget = (entry.value as WidgetInfo).copyWith(
          width: width,
          height: height,
        );
        _homeGridItems[entry.key] = updatedWidget;

        await WidgetService.updateWidget(updatedWidget);
        _saveHomeGridItems();
        notifyListeners();
        break;
      }
    }
  }

  /// Elimina un widget
  Future<void> removeWidget(String widgetId) async {
    try {
      await WidgetService.deleteWidget(widgetId);

      // Remover del grid
      _homeGridItems.removeWhere(
        (key, value) => value is WidgetInfo && value.id == widgetId,
      );

      _saveHomeGridItems();
      notifyListeners();
    } catch (e) {
      print('Error eliminando widget: $e');
    }
  }
}
