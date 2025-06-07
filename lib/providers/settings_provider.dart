import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = true;
  
  // Configuraciones para mostrar nombres de aplicaciones
  bool _showAppNamesHome = true;
  bool _showAppNamesDrawer = true;
  bool _showAppNames = true;
  bool _showHomeAppNames = true;
  bool _showDrawerAppNames = true;
  // Configuraciones de tamaño de texto e iconos
  double _homeAppNameTextSize = 12.0;
  double _drawerAppNameTextSize = 12.0;
  double _homeIconSize = 48.0;
  double _drawerIconSize = 48.0;
  
  // Configuraciones para el cajón de aplicaciones (drawer)
  int _drawerGridColumns = 4;
  int _drawerGridRows = 5;
  
  // Configuraciones para la pantalla principal (home)
  int _homeGridColumns = 3;
  int _homeGridRows = 4;
  bool _homeGridEditMode = false;
  
  bool _enableAnimations = true;
  bool _showNotificationDots = true;
  bool _showDock = true;
  
  // Configuración del fondo de pantalla
  String _wallpaperPath = '';
  
  // Getters
  bool get darkMode => _darkMode;
  bool get showAppNamesHome => _showAppNamesHome;
  bool get showAppNamesDrawer => _showAppNamesDrawer;
  
  double get homeAppNameTextSize => _homeAppNameTextSize;
  double get drawerAppNameTextSize => _drawerAppNameTextSize;
  double get homeIconSize => _homeIconSize;
  double get drawerIconSize => _drawerIconSize;
  
  // Drawer grid getters
  int get drawerGridColumns => _drawerGridColumns;
  int get drawerGridRows => _drawerGridRows;
  
  // Home grid getters
  int get homeGridColumns => _homeGridColumns;
  int get homeGridRows => _homeGridRows;
  bool get homeGridEditMode => _homeGridEditMode;
  
  bool get enableAnimations => _enableAnimations;
  bool get showNotificationDots => _showNotificationDots;
  bool get showDock => _showDock;
  
  String get wallpaperPath => _wallpaperPath;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _showAppNamesHome = prefs.getBool('show_app_names_home') ?? true;
      _showAppNamesDrawer = prefs.getBool('show_app_names_drawer') ?? true;
      
      _homeAppNameTextSize = prefs.getDouble('home_app_name_text_size') ?? 12.0;
      _drawerAppNameTextSize = prefs.getDouble('drawer_app_name_text_size') ?? 12.0;
      _homeIconSize = prefs.getDouble('home_icon_size') ?? 48.0;
      _drawerIconSize = prefs.getDouble('drawer_icon_size') ?? 48.0;
      
      // Load drawer grid settings
      _drawerGridColumns = prefs.getInt('drawer_grid_columns') ?? 4;
      _drawerGridRows = prefs.getInt('drawer_grid_rows') ?? 5;
      
      // Load home grid settings
      _homeGridColumns = prefs.getInt('home_grid_columns') ?? 3;
      _homeGridRows = prefs.getInt('home_grid_rows') ?? 4;
      _homeGridEditMode = prefs.getBool('home_grid_edit_mode') ?? false;
      
      _enableAnimations = prefs.getBool('enable_animations') ?? true;
      _showNotificationDots = prefs.getBool('show_notification_dots') ?? true;
      _showDock = prefs.getBool('show_dock') ?? true;
      
      _wallpaperPath = prefs.getString('wallpaper_path') ?? '';
      
      notifyListeners();
    } catch (e) {
      print('Error cargando configuración: $e');
    }
  }
  
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }
  
  Future<void> setShowAppNamesHome(bool value) async {
    _showAppNamesHome = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_app_names_home', value);
  }
  
  Future<void> setShowAppNamesDrawer(bool value) async {
    _showAppNamesDrawer = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_app_names_drawer', value);
  }
  
  Future<void> setHomeAppNameTextSize(double value) async {
    _homeAppNameTextSize = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('home_app_name_text_size', value);
  }
  
  Future<void> setDrawerAppNameTextSize(double value) async {
    _drawerAppNameTextSize = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('drawer_app_name_text_size', value);
  }
  
  Future<void> setHomeIconSize(double value) async {
    _homeIconSize = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('home_icon_size', value);
  }
  
  Future<void> setDrawerIconSize(double value) async {
    _drawerIconSize = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('drawer_icon_size', value);
  }
  
  // Drawer grid setters
  Future<void> setDrawerGridColumns(int value) async {
    _drawerGridColumns = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('drawer_grid_columns', value);
  }
  
  Future<void> setDrawerGridRows(int value) async {
    _drawerGridRows = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('drawer_grid_rows', value);
  }
  
  // Home grid setters
  Future<void> setHomeGridColumns(int value) async {
    _homeGridColumns = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('home_grid_columns', value);
  }
  
  Future<void> setHomeGridRows(int value) async {
    _homeGridRows = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('home_grid_rows', value);
  }
  
  void setHomeGridEditMode(bool editMode) {
    _homeGridEditMode = editMode;
    notifyListeners();
  }
  
  Future<void> setEnableAnimations(bool value) async {
    _enableAnimations = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_animations', value);
  }
  
  Future<void> setShowNotificationDots(bool value) async {
    _showNotificationDots = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_notification_dots', value);
  }
  
  Future<void> setShowDock(bool value) async {
    _showDock = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_dock', value);
  }
  
  Future<void> setWallpaperPath(String path) async {
    _wallpaperPath = path;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper_path', path);
  }
}