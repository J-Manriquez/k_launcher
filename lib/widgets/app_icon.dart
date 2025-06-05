import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppIcon extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  
  const AppIcon({
    super.key,
    required this.app,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: app.icon != null
                  ? Image.memory(
                      app.icon!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.android,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}