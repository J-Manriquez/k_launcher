import 'dart:ui';

class WidgetInfo {
  final String id;
  final String name;
  final String packageName;
  final String className; // Nombre de la clase del AppWidgetProviderInfo
  int width; 
  int height; 
  final Map<String, dynamic> configuration;
  int? nativeWidgetId; 
  String? imageData; // Para la previsualización del widget (Base64 String)

  WidgetInfo({
    required this.id,
    required this.name,
    required this.packageName,
    required this.className,
    this.width = 2,
    this.height = 2,
    this.nativeWidgetId,
    this.imageData,
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
      'nativeWidgetId': nativeWidgetId,
      'imageData': imageData,
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
      nativeWidgetId: json['nativeWidgetId'],
      imageData: json['imageData'],
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
    int? nativeWidgetId,
    String? imageData,
    Map<String, dynamic>? configuration,
  }) {
    return WidgetInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      className: className ?? this.className,
      width: width ?? this.width,
      height: height ?? this.height,
      nativeWidgetId: nativeWidgetId ?? this.nativeWidgetId,
      imageData: imageData ?? this.imageData,
      configuration: configuration ?? this.configuration,
    );
  }
}