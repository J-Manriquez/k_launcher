import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'app_icon.dart';

class Dock extends StatelessWidget {
  const Dock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final favoriteApps = appProvider.favoriteApps.take(4).toList();
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Aplicaciones favoritas
              ...favoriteApps.map((app) => SizedBox(
                width: 60,
                child: AppIcon(
                  app: app,
                  onTap: () {
                    appProvider.launchApp(app.packageName);
                  },
                ),
              )),
              
              // Rellenar espacios vacíos
              ...List.generate(
                4 - favoriteApps.length,
                (index) => SizedBox(
                  width: 60,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}