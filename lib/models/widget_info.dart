import 'dart:ui';

class WidgetInfo {
  final String id;
  final String name;
  final String packageName;
  final String className;
  int width; // Número de módulos de ancho
  int height; // Número de módulos de alto
  final Map<String, dynamic> configuration;
  
  WidgetInfo({
    required this.id,
    required this.name,
    required this.packageName,
    required this.className,
    this.width = 2,
    this.height = 2,
    Map<String, dynamic>? configuration,
  }) : configuration = configuration ?? {};
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'packageName': packageName,
      'className': className,
      'width': width,
      'height': height,
      'configuration': configuration,
    };
  }
  
  factory WidgetInfo.fromJson(Map<String, dynamic> json) {
    return WidgetInfo(
      id: json['id'],
      name: json['name'],
      packageName: json['packageName'],
      className: json['className'],
      width: json['width'] ?? 2,
      height: json['height'] ?? 2,
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
    );
  }
  
  WidgetInfo copyWith({
    String? id,
    String? name,
    String? packageName,
    String? className,
    int? width,
    int? height,
    Map<String, dynamic>? configuration,
  }) {
    return WidgetInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      className: className ?? this.className,
      width: width ?? this.width,
      height: height ?? this.height,
      configuration: configuration ?? this.configuration,
    );
  }
}