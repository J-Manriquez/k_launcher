import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = true;
  bool _showAppNames = true;
  int _gridColumns = 4;
  bool _enableAnimations = true;
  bool _showNotificationDots = true;
  
  bool get darkMode => _darkMode;
  bool get showAppNames => _showAppNames;
  int get gridColumns => _gridColumns;
  bool get enableAnimations => _enableAnimations;
  bool get showNotificationDots => _showNotificationDots;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _showAppNames = prefs.getBool('show_app_names') ?? true;
      _gridColumns = prefs.getInt('grid_columns') ?? 4;
      _enableAnimations = prefs.getBool('enable_animations') ?? true;
      _showNotificationDots = prefs.getBool('show_notification_dots') ?? true;
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
  
  Future<void> setShowAppNames(bool value) async {
    _showAppNames = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_app_names', value);
  }
  
  Future<void> setGridColumns(int value) async {
    _gridColumns = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('grid_columns', value);
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
}