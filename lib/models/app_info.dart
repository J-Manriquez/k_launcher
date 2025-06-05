import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class AppInfo {
  final String name;
  final String packageName;
  final Uint8List? icon;
  final bool isSystemApp;
  final bool isEnabled;
  final DateTime? lastUsed;
  final int usageCount;
  
  AppInfo({
    required this.name,
    required this.packageName,
    this.icon,
    this.isSystemApp = false,
    this.isEnabled = true,
    this.lastUsed,
    this.usageCount = 0,
  });
  
  factory AppInfo.fromNativeMap(Map<String, dynamic> map) {
    Uint8List? iconBytes;
    
    // Convertir el icono de Base64 a Uint8List
    if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
      try {
        iconBytes = base64Decode(map['icon']);
      } catch (e) {
        print('Error decodificando icono para ${map['appName']}: $e');
      }
    }
    
    return AppInfo(
      name: map['appName'] ?? '',
      packageName: map['packageName'] ?? '',
      icon: iconBytes,
      isSystemApp: map['isSystemApp'] ?? false,
      isEnabled: map['isEnabled'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packageName': packageName,
      'isSystemApp': isSystemApp,
      'isEnabled': isEnabled,
      'lastUsed': lastUsed?.millisecondsSinceEpoch,
      'usageCount': usageCount,
      'icon': icon != null ? base64Encode(icon!) : null,
    };
  }
  
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    Uint8List? iconBytes;
    
    if (json['icon'] != null) {
      try {
        iconBytes = base64Decode(json['icon']);
      } catch (e) {
        print('Error decodificando icono desde JSON: $e');
      }
    }
    
    return AppInfo(
      name: json['name'] ?? '',
      packageName: json['packageName'] ?? '',
      icon: iconBytes,
      isSystemApp: json['isSystemApp'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      lastUsed: json['lastUsed'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUsed'])
          : null,
      usageCount: json['usageCount'] ?? 0,
    );
  }
  
  AppInfo copyWith({
    String? name,
    String? packageName,
    Uint8List? icon,
    bool? isSystemApp,
    bool? isEnabled,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return AppInfo(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      icon: icon ?? this.icon,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isEnabled: isEnabled ?? this.isEnabled,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}