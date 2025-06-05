import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Configuración de Grid de Aplicaciones
              Card(
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cajón de Aplicaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Columnas del grid de aplicaciones
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Columnas:',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Slider(
                            value: settings.gridColumns.toDouble(),
                            min: 3,
                            max: 6,
                            divisions: 3,
                            label: settings.gridColumns.toString(),
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              settings.setGridColumns(value.round());
                            },
                          ),
                          Text(
                            settings.gridColumns.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      
                      // Filas del grid de aplicaciones
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filas:',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Slider(
                            value: settings.gridRows.toDouble(),
                            min: 4,
                            max: 8,
                            divisions: 4,
                            label: settings.gridRows.toString(),
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              settings.setGridRows(value.round());
                            },
                          ),
                          Text(
                            settings.gridRows.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configuración de Grid de Pantalla Principal
              Card(
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pantalla Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Columnas del grid de pantalla principal
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Columnas:',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Slider(
                            value: settings.homeGridColumns.toDouble(),
                            min: 2,
                            max: 5,
                            divisions: 3,
                            label: settings.homeGridColumns.toString(),
                            activeColor: Colors.purple,
                            onChanged: (value) {
                              settings.setHomeGridColumns(value.round());
                            },
                          ),
                          Text(
                            settings.homeGridColumns.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      
                      // Filas del grid de pantalla principal
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filas:',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Slider(
                            value: settings.homeGridRows.toDouble(),
                            min: 3,
                            max: 6,
                            divisions: 3,
                            label: settings.homeGridRows.toString(),
                            activeColor: Colors.purple,
                            onChanged: (value) {
                              settings.setHomeGridRows(value.round());
                            },
                          ),
                          Text(
                            settings.homeGridRows.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Otras configuraciones
              Card(
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apariencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text(
                          'Mostrar nombres de aplicaciones',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.showAppNames,
                        activeColor: Colors.blue,
                        onChanged: settings.setShowAppNames,
                      ),
                      
                      SwitchListTile(
                        title: const Text(
                          'Habilitar animaciones',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.enableAnimations,
                        activeColor: Colors.blue,
                        onChanged: settings.setEnableAnimations,
                      ),
                      
                      SwitchListTile(
                        title: const Text(
                          'Mostrar puntos de notificación',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.showNotificationDots,
                        activeColor: Colors.blue,
                        onChanged: settings.setShowNotificationDots,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}