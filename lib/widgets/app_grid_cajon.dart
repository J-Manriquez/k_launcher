import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';

class AppsGridCajon extends StatelessWidget {
  final List<AppInfo> apps;
  
  const AppsGridCajon({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: settings.drawerGridColumns,
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
      },
    );
  }

  void _showAppOptions(BuildContext context, AppInfo app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('Información de la app', style: TextStyle(color: Colors.white)),
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
              color: Colors.white,
            ),
            title: Text(
              context.read<AppProvider>().isFavorite(app.packageName)
                  ? 'Quitar de favoritos'
                  : 'Añadir a favoritos',
              style: const TextStyle(color: Colors.white),
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
          ListTile(
            leading: Icon(
              context.read<AppProvider>().homeScreenApps.any((homeApp) => homeApp.packageName == app.packageName)
                  ? Icons.remove_from_queue
                  : Icons.add_to_home_screen,
              color: Colors.white,
            ),
            title: Text(
              context.read<AppProvider>().homeScreenApps.any((homeApp) => homeApp.packageName == app.packageName)
                  ? 'Quitar de pantalla principal'
                  : 'Añadir a pantalla principal',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              final appProvider = context.read<AppProvider>();
              if (appProvider.homeScreenApps.any((homeApp) => homeApp.packageName == app.packageName)) {
                appProvider.removeFromHomeScreen(app.packageName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${app.name} removida de la pantalla principal'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                appProvider.addToHomeScreen(app);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${app.name} añadida a la pantalla principal'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}