import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_launcher/models/folder_info.dart';
import 'package:k_launcher/widgets/folder_widget.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';

class HomeGrid extends StatefulWidget {
  final List<AppInfo>? apps;
  final Function(AppInfo)? onAppTap;
  final Function(AppInfo)? onAppLongPress;
  
  const HomeGrid({
    super.key,
    this.apps,
    this.onAppTap,
    this.onAppLongPress,
  });

  @override
  State<HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  bool _isDragging = false;
  int? _draggedFromPosition;
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, SettingsProvider>(
      builder: (context, appProvider, settings, child) {
        final screenSize = MediaQuery.of(context).size;
        
        // Calculate available screen space
        final availableWidth = screenSize.width;
        final availableHeight = screenSize.height;
        
        // Use home grid settings
        final columns = settings.homeGridColumns;
        final rows = settings.homeGridRows;
        final isEditMode = settings.homeGridEditMode;
        
        // Calculate module size to fit screen (minimum 10x10px, always square)
        final moduleWidth = availableWidth / columns;
        final moduleHeight = availableHeight / rows;
        final moduleSize = moduleWidth < moduleHeight ? moduleWidth : moduleHeight;
        
        // Ensure minimum size of 10px
        final finalModuleSize = moduleSize < 10 ? 10.0 : moduleSize;
        
        return Container(
          width: availableWidth,
          height: availableHeight,
          color: isEditMode ? Colors.black.withOpacity(0.1) : Colors.transparent,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 1.0,
            ),
            itemCount: columns * rows,
            itemBuilder: (context, index) {
              final item = appProvider.getItemAtPosition(index);
              
              if (item != null) {
                if (item is AppInfo) {
                  return _buildAppSlot(
                    context,
                    item,
                    index,
                    finalModuleSize,
                    isEditMode,
                    appProvider,
                    settings,
                  );
                } else if (item is FolderInfo) {
                  return _buildFolderSlot(
                    context,
                    item,
                    index,
                    finalModuleSize,
                    isEditMode,
                    appProvider,
                    settings,
                  );
                }
              }
              
              return _buildEmptySlot(
                context,
                index,
                finalModuleSize,
                isEditMode,
                appProvider,
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildAppSlot(
    BuildContext context,
    AppInfo app,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
    SettingsProvider settings,
  ) {
    Widget appWidget = Container(
      width: moduleSize,
      height: moduleSize,
      decoration: BoxDecoration(
        color: isEditMode ? Colors.black.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isEditMode ? Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (!isEditMode && !_isDragging) {
              if (widget.onAppTap != null) {
                widget.onAppTap!(app);
              } else {
                appProvider.launchApp(app.packageName);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: app.icon != null
                          ? Image.memory(
                              app.icon!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.android,
                                size: moduleSize * 0.3,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),
                if (settings.showAppNamesHome)
                  Expanded(
                    flex: 1,
                    child: Text(
                      app.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (moduleSize * 0.08).clamp(8.0, 12.0),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Envolver en GestureDetector para manejar long press y drag
    return GestureDetector(
      onLongPressStart: (details) {
        if (!isEditMode) {
          // Activar modo edición y iniciar drag
          settings.setHomeGridEditMode(true);
          HapticFeedback.mediumImpact();
        }
      },
      child: isEditMode ? _buildDraggableApp(
        appWidget,
        app,
        position,
        moduleSize,
        appProvider,
      ) : appWidget,

    );
  }
  
  Widget _buildDraggableApp(
    Widget appWidget,
    AppInfo app,
    int position,
    double moduleSize,
    AppProvider appProvider,
  ) {
    return LongPressDraggable<AppInfo>(
      data: app,
      delay: const Duration(milliseconds: 100),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: appWidget,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: moduleSize,
        height: moduleSize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
            // style: BorderStyle.dashed,
          ),
        ),
        child: Icon(
          Icons.apps,
          color: Colors.white.withOpacity(0.5),
          size: moduleSize * 0.3,
        ),
      ),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _draggedFromPosition = position;
        });
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _draggedFromPosition = null;
          _showDeleteMenu( context, position, app, appProvider);

        });
      },
      child: DragTarget<Object>(
        onWillAccept: (data) {
          if (data is AppInfo) {
            return data.packageName != app.packageName;
          } else if (data is FolderInfo) {
            return true; // Aceptar carpetas
          }
          return false;
        },
        onAccept: (data) {
          if (data is AppInfo) {
            final draggedPosition = appProvider.getPositionOfApp(data.packageName);
            if (draggedPosition != null && draggedPosition != position) {
              // Intercambiar posiciones
              _swapItems(appProvider, draggedPosition, position);
              HapticFeedback.mediumImpact();
            }
          } else if (data is FolderInfo) {
            final draggedPosition = appProvider.homeGridItems.entries
                .where((entry) => entry.value is FolderInfo && (entry.value as FolderInfo).id == data.id)
                .firstOrNull?.key;
                
            if (draggedPosition != null && draggedPosition != position) {
              // Intercambiar posiciones
              _swapItems(appProvider, draggedPosition, position);
              HapticFeedback.mediumImpact();
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isHovering ? Border.all(
                color: Colors.blue,
                width: 2,
              ) : null,
            ),
            child: appWidget,
          );
        },
      ),
    );
  }
  
  Widget _buildEmptySlot(
    BuildContext context,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
  ) {
    return DragTarget<Object>(

      onWillAccept: (data) => data != null,
      onAccept: (data) {
        if (data is AppInfo) {
          final currentPosition = appProvider.getPositionOfApp(data.packageName);
          if (currentPosition != null) {
            appProvider.moveItemInHomeGrid(currentPosition, position);
          } else {
            appProvider.addItemToHomeGridPosition(data, position);
          }
        } else if (data is FolderInfo) {
          final currentPosition = appProvider.homeGridItems.entries
              .where((entry) => entry.value is FolderInfo && (entry.value as FolderInfo).id == data.id)
              .firstOrNull?.key;
              
          if (currentPosition != null) {
            appProvider.moveItemInHomeGrid(currentPosition, position);
          }
        }
        HapticFeedback.mediumImpact();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: moduleSize,
          height: moduleSize,
          decoration: BoxDecoration(
            color: isEditMode 
                ? (isHovering 
                    ? Colors.blue.withOpacity(0.3) 
                    : Colors.transparent)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isEditMode ? Border.all(
              color: isHovering 
                  ? Colors.blue
                  : Colors.white.withOpacity(0.1),
              width: isHovering ? 2 : 1,
            ) : null,
          ),
          child: isEditMode ? Icon(
            isHovering ? Icons.add_circle : Icons.add,
            color: isHovering 
                ? Colors.blue
                : Colors.white.withOpacity(0.3),
            size: moduleSize * 0.3,
          ) : null,
        );
      },
    );
  }
  
  void _swapItems(AppProvider appProvider, int fromPosition, int toPosition) {
    final fromItem = appProvider.getItemAtPosition(fromPosition);
    final toItem = appProvider.getItemAtPosition(toPosition);
    
    if (fromItem != null) {
      appProvider.removeItemFromHomeGridPosition(fromPosition);
      if (toItem != null) {
        appProvider.removeItemFromHomeGridPosition(toPosition);
        appProvider.addItemToHomeGridPosition(toItem, fromPosition);
      }
      appProvider.addItemToHomeGridPosition(fromItem, toPosition);
    }
  }

  void _showAppOptions(BuildContext context, AppInfo app, AppProvider appProvider) {
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
              appProvider.isFavorite(app.packageName) ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            title: Text(
              appProvider.isFavorite(app.packageName) ? 'Quitar de favoritos' : 'Agregar a favoritos',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              if (appProvider.isFavorite(app.packageName)) {
                appProvider.removeFromFavorites(app.packageName);
              } else {
                appProvider.addToFavorites(app);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.white),
            title: const Text('Quitar de pantalla principal', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              appProvider.removeFromHomeScreen(app.packageName);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('${app.name} eliminado de la pantalla principal'),
              //     duration: const Duration(seconds: 2),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFolderSlot(
    BuildContext context,
    FolderInfo folder,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
    SettingsProvider settings,
  ) {
    return isEditMode
        ? _buildDraggableFolder(
            FolderWidget(
              folder: folder,
              size: moduleSize * 0.8,
              onTap: () => _openFolder(context, folder, appProvider),
            ),
            folder,
            position,
            moduleSize,
            appProvider,
          )
        : FolderWidget(
            folder: folder,
            size: moduleSize * 0.8,
            onTap: () => _openFolder(context, folder, appProvider),
            onLongPress: () {
              settings.setHomeGridEditMode(true);
              HapticFeedback.mediumImpact();
            },
          );
  }
  
  void _openFolder(BuildContext context, FolderInfo folder, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Obtener la carpeta actualizada del provider
          final updatedFolder = appProvider.folders.firstWhere(
            (f) => f.id == folder.id,
            orElse: () => folder,
          );
          
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        updatedFolder.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Botón para añadir aplicaciones
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () => _showAppSelectionDialog(
                              context, 
                              updatedFolder, 
                              appProvider,
                              () => setState(() {}), // Callback para actualizar el estado
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: updatedFolder.columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: updatedFolder.apps.length,
                    itemBuilder: (context, index) {
                      final app = updatedFolder.apps[index];
                      return AppIcon(
                        app: app,
                        onTap: () {
                          Navigator.pop(context);
                          appProvider.launchApp(app.packageName);
                        },
                        onLongPress: () => _showFolderAppOptions(
                          context, 
                          app, 
                          updatedFolder.id, 
                          appProvider,
                          () => setState(() {}), // Callback para actualizar el estado
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showFolderAppOptions(BuildContext context, AppInfo app, String folderId, AppProvider appProvider, [VoidCallback? onUpdate]) {
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
            title: const Text('Quitar de la carpeta', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              appProvider.removeAppFromFolder(folderId, app.packageName);
              if (onUpdate != null) onUpdate(); // Actualizar la vista de la carpeta
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('${app.name} eliminado de la carpeta'),
              //     duration: const Duration(seconds: 2),
              //   ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Mover a pantalla principal', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              appProvider.removeAppFromFolder(folderId, app.packageName);
              appProvider.addToHomeScreen(app);
              if (onUpdate != null) onUpdate(); // Actualizar la vista de la carpeta
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('${app.name} movido a la pantalla principal'),
              //     duration: const Duration(seconds: 2),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDraggableFolder(
    Widget folderWidget,
    FolderInfo folder,
    int position,
    double moduleSize,
    AppProvider appProvider,
  ) {
    return LongPressDraggable<Object>(
      data: folder,
      delay: const Duration(milliseconds: 100),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: folderWidget,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: moduleSize,
        height: moduleSize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.folder_open,
          color: Colors.white.withOpacity(0.5),
          size: moduleSize * 0.3,
        ),
      ),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _draggedFromPosition = position;
        });
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _draggedFromPosition = null;
          _showDeleteMenu( context, position, folder, appProvider);

        });
      },
      child: DragTarget<Object>(
        onWillAccept: (data) {
          // Aceptar apps o carpetas, pero no la misma carpeta
          if (data is AppInfo) {
            return true; // Siempre aceptar apps
          } else if (data is FolderInfo) {
            return data.id != folder.id; // Aceptar otras carpetas
          }
          return false;
        },
        onAccept: (data) {
          if (data is AppInfo) {
            // Si es una app, agregarla a la carpeta
            appProvider.addAppToFolder(folder.id, data);
            HapticFeedback.mediumImpact();
          } else if (data is FolderInfo) {
            // Si es otra carpeta, intercambiar posiciones
            final draggedPosition = appProvider.homeGridItems.entries
                .where((entry) => entry.value is FolderInfo && (entry.value as FolderInfo).id == (data as FolderInfo).id)
                .firstOrNull?.key;
                
            if (draggedPosition != null && draggedPosition != position) {
              // Intercambiar posiciones
              _swapItems(appProvider, draggedPosition, position);
              HapticFeedback.mediumImpact();
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isHovering ? Border.all(
                color: Colors.blue,
                width: 2,
              ) : null,
            ),
            child: folderWidget,
          );
        },
      ),
    );
  }
}

void _showAppSelectionDialog(BuildContext context, FolderInfo folder, AppProvider appProvider, [VoidCallback? onUpdate]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Seleccionar aplicaciones",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: appProvider.installedApps.length,
                  itemBuilder: (context, index) {
                    final app = appProvider.installedApps[index];
                    // Obtener la carpeta actualizada para verificar si la app está en ella
                    final updatedFolder = appProvider.folders.firstWhere(
                      (f) => f.id == folder.id,
                      orElse: () => folder,
                    );
                    final isInFolder = updatedFolder.apps.any((a) => a.packageName == app.packageName);
                    
                    return ListTile(
                      leading: app.icon != null
                        ? Image.memory(app.icon!, width: 40, height: 40)
                        : const Icon(Icons.android, color: Colors.white),
                      title: Text(app.name, style: const TextStyle(color: Colors.white)),
                      trailing: Checkbox(
                        value: isInFolder,
                        onChanged: (value) {
                          if (value == true && !isInFolder) {
                            appProvider.addAppToFolder(folder.id, app);
                            setState(() {}); // Actualizar el estado del diálogo
                            if (onUpdate != null) onUpdate(); // Actualizar la vista de la carpeta
                          } else if (value == false && isInFolder) {
                            appProvider.removeAppFromFolder(folder.id, app.packageName);
                            setState(() {}); // Actualizar el estado del diálogo
                            if (onUpdate != null) onUpdate(); // Actualizar la vista de la carpeta
                          }
                        },
                      ),
                      onTap: () {
                        if (!isInFolder) {
                          appProvider.addAppToFolder(folder.id, app);
                        } else {
                          appProvider.removeAppFromFolder(folder.id, app.packageName);
                        }
                        setState(() {}); // Actualizar el estado del diálogo
                        if (onUpdate != null) onUpdate(); // Actualizar la vista de la carpeta
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _showDeleteMenu(BuildContext context, int position, dynamic item, AppProvider appProvider) {
  // Obtener la posición global del widget actual
  final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
  if (renderBox == null) return;
  
  // Calcular la posición en la pantalla
  final Offset offset = renderBox.localToGlobal(Offset.zero);
  final Size size = renderBox.size;
  
  // Mostrar el menú en la posición del icono
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      offset.dx + size.width,
      offset.dy + size.height,
    ),
    items: [
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar', style: TextStyle(color: Colors.red),),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value == 'delete') {
      if (item is AppInfo) {
        // Buscar la posición de la app en _homeGridItems
        int? appPosition;
        for (var entry in appProvider.homeGridItems.entries) {
          if (entry.value is AppInfo && (entry.value as AppInfo).packageName == item.packageName) {
            appPosition = entry.key;
            break;
          }
        }
        
        if (appPosition != null) {
          appProvider.removeItemFromHomeGridPosition(appPosition);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('${item.name} eliminado de la pantalla principal'),
          //     duration: const Duration(seconds: 2),
          //   ),
          // );
        }
      } else if (item is FolderInfo) {
        // Buscar la posición de la carpeta en _homeGridItems
        int? folderPosition;
        for (var entry in appProvider.homeGridItems.entries) {
          if (entry.value is FolderInfo && (entry.value as FolderInfo).id == item.id) {
            folderPosition = entry.key;
            break;
          }
        }
        
        if (folderPosition != null) {
          appProvider.removeItemFromHomeGridPosition(folderPosition);
          appProvider.deleteFolder(item.id);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('${item.name} eliminado'),
          //     duration: const Duration(seconds: 2),
          //   ),
          // );
        }
      }
    }
  });
}