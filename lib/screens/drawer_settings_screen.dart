import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class DrawerSettingsScreen extends StatelessWidget {
  const DrawerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Cajón de Aplicaciones'),
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
                      subtitle: Text('${settings.drawerGridColumns} columnas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.drawerGridColumns.toDouble().clamp(3.0, 15.0),
                          min: 3,
                          max: 15,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setDrawerGridColumns(value.round());
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Filas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.drawerGridRows} filas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.drawerGridRows.toDouble().clamp(3.0, 15.0),
                          min: 3,
                          max: 15,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setDrawerGridRows(value.round());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
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
                      value: settings.showAppNamesDrawer,
                      onChanged: (value) {
                        settings.setShowAppNamesDrawer(value);
                      },
                      activeColor: Colors.blue,
                    ),
                    if (settings.showAppNamesDrawer)
                      ListTile(
                        title: const Text('Tamaño del texto', style: TextStyle(color: Colors.white)),
                        subtitle: Text('${settings.drawerAppNameTextSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                        trailing: SizedBox(
                          width: 150,
                          child: Slider(
                            value: settings.drawerAppNameTextSize.clamp(8.0, 20.0),
                            min: 8,
                            max: 20,
                            divisions: 12,
                            onChanged: (value) {
                              settings.setDrawerAppNameTextSize(value);
                            },
                          ),
                        ),
                      ),
                    ListTile(
                      title: const Text('Tamaño de iconos', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.drawerIconSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.drawerIconSize.clamp(32.0, 80.0),
                          min: 32,
                          max: 80,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setDrawerIconSize(value);
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