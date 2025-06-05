import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, SettingsProvider>(
      builder: (context, appProvider, settings, child) {
        // Por ahora mostramos aplicaciones favoritas y algunas recientes
        // En el futuro aquí irán widgets personalizados
        final homeApps = [
          ...appProvider.favoriteApps.take(6),
          ...appProvider.recentApps.take(6),
        ].take(settings.homeGridColumns * settings.homeGridRows).toList();
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: settings.homeGridColumns,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemCount: homeApps.length,
            itemBuilder: (context, index) {
              if (index < homeApps.length) {
                final app = homeApps[index];
                return AppIcon(
                  app: app,
                  onTap: () {
                    appProvider.launchApp(app.packageName);
                  },
                  onLongPress: () {
                    _showAppOptions(context, app);
                  },
                );
              } else {
                // Espacio vacío para futuros widgets
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                );
              }
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
            leading: const Icon(Icons.remove_circle, color: Colors.white),
            title: const Text('Quitar de pantalla principal', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Quitar de pantalla principal
            },
          ),
        ],
      ),
    );
  }
}