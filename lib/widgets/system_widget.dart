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
  static const MethodChannel _channel = MethodChannel('k_launcher/widget_view');
  
  @override
  Widget build(BuildContext context) {
    final width = widget.moduleSize * widget.widget.width;
    final height = widget.moduleSize * widget.widget.height;
    
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
            viewType: 'system_widget_view',
            creationParams: {
              'widgetId': widget.widget.id,
              'width': width.toInt(),
              'height': height.toInt(),
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
      ),
    );
  }
}