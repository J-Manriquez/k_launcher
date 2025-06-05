import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import 'app_icon.dart';

class AppGrid extends StatelessWidget {
  final List<AppInfo> apps;
  
  const AppGrid({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return AppIcon(
            app: app,
            onTap: () {
              context.read<AppProvider>().launchApp(app.packageName);
            },
            onLongPress: () {
              _showAppOptions(context, app);
            },
          );
        },
      ),
    );
  }
  
  void _showAppOptions(BuildContext context, AppInfo app) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información de la app'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Abrir información de la app
              },
            ),
            ListTile(
              leading: Icon(
                context.read<AppProvider>().isFavorite(app.packageName)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              title: Text(
                context.read<AppProvider>().isFavorite(app.packageName)
                    ? 'Quitar de favoritos'
                    : 'Añadir a favoritos',
              ),
              onTap: () {
                Navigator.pop(context);
                if (context.read<AppProvider>().isFavorite(app.packageName)) {
                  context.read<AppProvider>().removeFromFavorites(app.packageName);
                } else {
                  context.read<AppProvider>().addToFavorites(app);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}