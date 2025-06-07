import 'dart:ui';
import 'app_info.dart';

class FolderInfo {
  final String id;
  String name;
  List<AppInfo> apps;
  Color backgroundColor;
  int columns;
  int rows;
  
  FolderInfo({
    required this.id,
    required this.name,
    List<AppInfo>? apps,  // Cambiado a nullable
    this.backgroundColor = const Color(0xFF424242),
    this.columns = 3,
    this.rows = 3,
  }) : apps = apps ?? []; // Inicializar con una lista vacía mutable
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'apps': apps.map((app) => app.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
      'columns': columns,
      'rows': rows,
    };
  }
  
  factory FolderInfo.fromJson(Map<String, dynamic> json) {
    return FolderInfo(
      id: json['id'],
      name: json['name'],
      apps: (json['apps'] as List).map((app) => AppInfo.fromJson(app)).toList(),
      backgroundColor: Color(json['backgroundColor']),
      columns: json['columns'] ?? 3,
      rows: json['rows'] ?? 3,
    );
  }
}