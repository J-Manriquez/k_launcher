import 'package:flutter/material.dart';
import 'package:k_launcher/widgets/wallpaper_selector.dart';
import 'package:k_launcher/widgets/widget_selector_sheet.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';

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
      body: Consumer2<SettingsProvider, AppProvider>(
        builder: (context, settings, appProvider, child) {
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

              // Configuración de Carpetas
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Configuración de Carpetas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Crear nueva carpeta', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Añadir una carpeta a la pantalla principal', style: TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () => _showCreateFolderDialog(context, appProvider),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Mostrar nombres de carpetas', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Mostrar el nombre debajo de cada carpeta', style: TextStyle(color: Colors.grey)),
                      value: settings.showFolderNames,
                      onChanged: (value) {
                        settings.setShowFolderNames(value);
                      },
                      activeColor: Colors.blue,
                    ),
                    if (settings.showFolderNames)
                      ListTile(
                        title: const Text('Tamaño del texto de carpetas', style: TextStyle(color: Colors.white)),
                        subtitle: Text('${settings.folderNameTextSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                        trailing: SizedBox(
                          width: 150,
                          child: Slider(
                            value: settings.folderNameTextSize.clamp(8.0, 20.0),
                            min: 8,
                            max: 20,
                            divisions: 12,
                            onChanged: (value) {
                              settings.setFolderNameTextSize(value);
                            },
                          ),
                        ),
                      ),
                    SwitchListTile(
                      title: const Text('Mostrar nombres de apps en carpetas', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Mostrar el nombre de las apps dentro de las carpetas', style: TextStyle(color: Colors.grey)),
                      value: settings.showAppNamesInFolders,
                      onChanged: (value) {
                        settings.setShowAppNamesInFolders(value);
                      },
                      activeColor: Colors.blue,
                    ),
                    ListTile(
                      title: const Text('Tamaño de iconos de carpetas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.folderIconSize.toInt()}px', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.folderIconSize.clamp(32.0, 80.0),
                          min: 32,
                          max: 80,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setFolderIconSize(value);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Columnas en carpetas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.defaultFolderColumns} columnas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.defaultFolderColumns.toDouble().clamp(2.0, 6.0),
                          min: 2,
                          max: 6,
                          divisions: 4,
                          onChanged: (value) {
                            settings.setDefaultFolderColumns(value.round());
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Filas en carpetas', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${settings.defaultFolderRows} filas', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.defaultFolderRows.toDouble().clamp(2.0, 6.0),
                          min: 2,
                          max: 6,
                          divisions: 4,
                          onChanged: (value) {
                            settings.setDefaultFolderRows(value.round());
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Color de fondo de carpetas', style: TextStyle(color: Colors.white)),
                      trailing: GestureDetector(
                        onTap: () => _showColorPicker(context, settings),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: settings.defaultFolderBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Configuración de Carpetas
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Configuración de widgets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Añadir widget', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Añadir un widget a la pantalla principal', style: TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () => _showWidgetSelector(context, appProvider),
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
  
  void _showCreateFolderDialog(BuildContext context, AppProvider appProvider) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Crear nueva carpeta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre de la carpeta',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                appProvider.createFolder(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Carpeta "${controller.text}" creada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  
  void _showColorPicker(BuildContext context, SettingsProvider settings) {
    final List<Color> colors = [
      const Color(0xFF424242),
      const Color(0xFF1976D2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
      const Color(0xFFD32F2F),
      const Color(0xFF7B1FA2),
      const Color(0xFF00796B),
      const Color(0xFF455A64),
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Seleccionar color', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              settings.setDefaultFolderBackgroundColor(color);
              Navigator.pop(context);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: settings.defaultFolderBackgroundColor == color 
                      ? Colors.white 
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
  
  void _showWidgetSelector(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => WidgetSelectorSheet(appProvider: appProvider),
    );
  }
}