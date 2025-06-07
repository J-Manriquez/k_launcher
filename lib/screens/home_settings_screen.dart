import 'package:flutter/material.dart';
import 'package:k_launcher/widgets/wallpaper_selector.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class HomeSettingsScreen extends StatelessWidget {
  const HomeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Pantalla Principal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Configuración de Grid
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Configuración del Grid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Columnas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.homeGridColumns} columnas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.homeGridColumns.toDouble().clamp(3.0, 15.0),
                          min: 3,
                          max: 15,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setHomeGridColumns(value.round());
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Filas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.homeGridRows} filas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.homeGridRows.toDouble().clamp(3.0, 15.0),
                          min: 3,
                          max: 15,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setHomeGridRows(value.round());
                          },
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Modo Edición', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Permite mover y reorganizar aplicaciones', style: TextStyle(color: Colors.grey)),
                      value: settings.homeGridEditMode,
                      onChanged: (value) {
                        settings.setHomeGridEditMode(value);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    builder: (context) => const WallpaperSelector(),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Cambiar fondo de pantalla',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                        )
                      ]
                    )
                  )
                )
              ),
            

  //  void _showWallpaperSelector() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const WallpaperSelector(),
  //   );
  // }
              const SizedBox(height: 16),

              // Configuración de Apariencia
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Apariencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Mostrar nombres de aplicaciones', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Mostrar el nombre debajo de cada icono', style: TextStyle(color: Colors.grey)),
                      value: settings.showAppNamesHome,
                      onChanged: (value) {
                        settings.setShowAppNamesHome(value);
                      },
                      activeColor: Colors.blue,
                    ),
                    if (settings.showAppNamesHome)
                      ListTile(
                        title: const Text('Tamaño del texto', style: TextStyle(color: Colors.white)),
                        subtitle: Text('${settings.homeAppNameTextSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                        trailing: SizedBox(
                          width: 150,
                          child: Slider(
                            value: settings.homeAppNameTextSize.clamp(8.0, 20.0),
                            min: 8,
                            max: 20,
                            divisions: 12,
                            onChanged: (value) {
                              settings.setHomeAppNameTextSize(value);
                            },
                          ),
                        ),
                      ),
                    ListTile(
                      title: const Text('Tamaño de iconos', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.homeIconSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.homeIconSize.clamp(32.0, 80.0),
                          min: 32,
                          max: 80,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setHomeIconSize(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}