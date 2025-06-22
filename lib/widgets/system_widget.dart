import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/widget_info.dart';

class SystemWidget extends StatefulWidget {
  final WidgetInfo widget;
  final double moduleSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const SystemWidget({
    super.key,
    required this.widget,
    required this.moduleSize,
    this.onTap,
    this.onLongPress,
  });
  
  @override
  State<SystemWidget> createState() => _SystemWidgetState();
}

class _SystemWidgetState extends State<SystemWidget> {
  static final Map<int, bool> _createdViews = {};
  
  @override
  void dispose() {
    // Limpiar el registro cuando el widget se destruye
    if (widget.widget.nativeWidgetId != null) {
      _createdViews.remove(widget.widget.nativeWidgetId!);
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final width = widget.moduleSize * widget.widget.width;
    final height = widget.moduleSize * widget.widget.height;
    
    // Verificar que tenemos un nativeWidgetId válido
    if (widget.widget.nativeWidgetId == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'Widget Error',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    
    // Usar una key estable basada en el nativeWidgetId
    final widgetId = widget.widget.nativeWidgetId!;
    final viewKey = ValueKey('widget_view_$widgetId');
    
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AndroidView(
            key: viewKey,
            viewType: 'system_widget_view',
            creationParams: {
              'widgetId': widgetId,
              'width': width.toInt(),
              'height': height.toInt(),
            },
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (int id) {
              print('Platform view created with ID: $id, Widget ID: $widgetId');
            },
          ),
        ),
      ),
    );
  }
}