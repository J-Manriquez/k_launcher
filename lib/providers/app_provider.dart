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
import 'settings_provider.dart'; // Agregar esta importación

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
  // Agregar referencia al SettingsProvider
  SettingsProvider? _settingsProvider;

  AppProvider() {
    // Eliminada la llamada a _loadHomeGridPositions
    _loadFolders();
    _loadHomeGridItems();
    _loadWidgets(); // Nuevo
  }

  // Método para establecer la referencia al SettingsProvider
  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }
  
  // Implementar el método _getGridColumns
  int _getGridColumns() {
    return _settingsProvider?.homeGridColumns ?? 3; // Valor por defecto de 3 columnas
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

  List<WidgetInfo> _availableWidgets = [];
  List<WidgetInfo> get availableWidgets => _availableWidgets;

  Future<void> loadAvailableWidgets() async {
    try {
      final List<Map<String, dynamic>> widgetMaps =
          await WidgetService.getAppsWithWidgets();
      // CORRECCIÓN: Mapear List<Map<String, dynamic>> a List<WidgetInfo>
      _availableWidgets = widgetMaps.map((map) {
        // Asumimos que getAppsWithWidgets() devuelve mapas que se pueden usar para construir WidgetInfo
        // que representan *tipos* de widgets disponibles, no instancias.
        // El 'id' aquí sería un identificador único para el tipo de widget, no para la instancia.
        // 'nativeWidgetId' será null para los widgets disponibles que aún no se han agregado.
        return WidgetInfo(
          id:
              map['packageName'] +
              "/" +
              map['className'], // Crear un ID único para el tipo de widget
          name: map['label'], // o el nombre que proporcione getAppsWithWidgets
          packageName: map['packageName'],
          className: map['className'],
          // width y height podrían ser predeterminados o provenir del map si está disponible
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading available widgets: $e');
      }
      _availableWidgets = [];
      notifyListeners();
    }
  }

  Future<bool> addWidget(WidgetInfo widgetInfo, int col, int row) async {
    try {
      // CORRECCIÓN: Usar widgetInfo.className como providerName (o el identificador correcto del widget provider)
      // y pasar width y height de widgetInfo.
      final result = await WidgetService.createWidget(
        widgetInfo.className, // o packageName + className si es necesario
        widgetInfo
            .width, // Esto debería ser el tamaño en dp, no en celdas del grid inicialmente.
        widgetInfo.height, // Ajustar si WidgetService.createWidget espera dp.
      );

      if (result != null && result['widgetId'] != null) {
        final int nativeId = result['widgetId'] as int;
        // CORRECCIÓN: Asignar el nativeWidgetId al widgetInfo
        widgetInfo.nativeWidgetId = nativeId;

        // El 'id' de WidgetInfo debe ser único para la instancia en el grid
        final newWidget = widgetInfo.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        _homeGridItems[row][col] = newWidget;
        await _saveHomeGridItems();
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to create widget natively or result is invalid.');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding widget: $e');
      }
      return false;
    }
  }

  Future<void> updateWidgetSize(
    String widgetId,
    int newWidth,
    int newHeight,
  ) async {
    // Iterar sobre las entradas del Map _homeGridItems
    for (var entry in _homeGridItems.entries) {
      final item = entry.value;
      if (item is WidgetInfo && item.id == widgetId) {
        item.width = newWidth;
        item.height = newHeight;
        if (item.nativeWidgetId != null) {
          await WidgetService.updateWidget(
            item.nativeWidgetId!,
            newWidth,
            newHeight,
          );
        } else {
          if (kDebugMode) {
            print(
              'Error: nativeWidgetId is null for widget $widgetId. Cannot update native widget.',
            );
          }
        }
        await _saveHomeGridItems();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> removeWidget(String widgetId) async {
    int? nativeIdToRemove;
    int? positionToRemove;

    // Buscar el widget en _homeGridItems
    for (var entry in _homeGridItems.entries) {
      final item = entry.value;
      if (item is WidgetInfo && item.id == widgetId) {
        nativeIdToRemove = item.nativeWidgetId;
        positionToRemove = entry.key;
        break;
      }
    }

    if (positionToRemove != null) {
      // Eliminar el widget del grid
      _homeGridItems.remove(positionToRemove);

      // Eliminar el widget nativo si existe
      if (nativeIdToRemove != null) {
        await WidgetService.deleteWidget(nativeIdToRemove);
      } else {
        if (kDebugMode) {
          print(
            'Warning: nativeWidgetId is null for widget $widgetId during removal.',
          );
        }
      }

      await _saveHomeGridItems();
      notifyListeners();
    } else {
      if (kDebugMode) {
        print('Widget with id $widgetId not found in home grid.');
      }
    }
  }

  // NUEVO: Método para encontrar una posición vacía en el grid
  int? findEmptyPosition(int itemWidth, int itemHeight) {
    // Implementación simple: busca la primera posición vacía sin considerar el tamaño.
    // TODO: Implementar una lógica más robusta que considere el tamaño del widget.
    for (int i = 0; i < 100; i++) {
      // Asume un máximo de 100 posiciones
      if (!_homeGridItems.containsKey(i)) {
        return i;
      }
    }
    return null; // No se encontró posición vacía
  }

  // NUEVO: Método para agregar un widget al grid en una posición específica
  void addWidgetToHomeGrid(WidgetInfo widget, int position) {
    _homeGridItems[position] = widget;
    _saveHomeGridItems();
    notifyListeners();
  }

  // Agregar estos métodos a la clase AppProvider:
  int? getWidgetStartPosition(String widgetId) {
    int? minPosition;
    for (final entry in homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widgetId) {
        if (minPosition == null || entry.key < minPosition) {
          minPosition = entry.key;
        }
      }
    }
    return minPosition;
  }

  void updateWidget(WidgetInfo widget) {
    // Encontrar la posición actual del widget
    final currentPosition = getWidgetStartPosition(widget.id);
    if (currentPosition != null) {
      // Limpiar las posiciones ocupadas por el widget anterior
      _clearWidgetPositions(widget.id);

      // Verificar si hay espacio para el nuevo tamaño
      if (_canPlaceWidget(currentPosition, widget.width, widget.height)) {
        // Colocar el widget en las nuevas posiciones
        _placeWidgetAtPosition(widget, currentPosition);
      } else {
        // Si no hay espacio, buscar una nueva posición
        final newPosition = findEmptyPosition(widget.width, widget.height);
        if (newPosition != null) {
          _placeWidgetAtPosition(widget, newPosition);
        }
      }

      notifyListeners();
    }
  }

  void _clearWidgetPositions(String widgetId) {
    final positionsToRemove = <int>[];
    for (final entry in homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widgetId) {
        positionsToRemove.add(entry.key);
      }
    }
    for (final position in positionsToRemove) {
      homeGridItems.remove(position);
    }
  }

  bool _canPlaceWidget(int startPosition, int width, int height) {
    final int columns = _getGridColumns(); // Asegurar que sea int
    final int startRow = startPosition ~/ columns;
    final int startCol = startPosition % columns;

    // Verificar que el widget no se salga del grid
    if (startCol + width > columns) return false;

    // Verificar que todas las posiciones estén libres
    for (int row = startRow; row < startRow + height; row++) {
      for (int col = startCol; col < startCol + width; col++) {
        final int position = row * columns + col;
        if (homeGridItems.containsKey(position)) {
          return false;
        }
      }
    }

    return true;
  }

  void _placeWidgetAtPosition(WidgetInfo widget, int startPosition) {
    // Get current grid configuration from settings
    final int columns = _getGridColumns(); // Asegurar que sea int
    final int startRow = startPosition ~/ columns;
    final int startCol = startPosition % columns;

    // Colocar el widget en todas las posiciones que ocupa
    for (int row = startRow; row < startRow + widget.height; row++) {
      for (int col = startCol; col < startCol + widget.width; col++) {
        final int position = row * columns + col;
        homeGridItems[position] = widget;
      }
    }
  }
}
