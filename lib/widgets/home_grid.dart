import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';

class HomeGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, SettingsProvider>(
      builder: (context, appProvider, settings, child) {
        final screenSize = MediaQuery.of(context).size;
        
        // Calculate available screen space
        final availableWidth = screenSize.width;
        final availableHeight = screenSize.height; // * 0.7 Usar 70% de la pantalla
        
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
              final app = appProvider.getAppAtPosition(index);
              
              if (app != null) {
                return _buildAppSlot(
                  context,
                  app,
                  index,
                  finalModuleSize,
                  isEditMode,
                  appProvider,
                  settings,
                );
              } else {
                return _buildEmptySlot(
                  context,
                  index,
                  finalModuleSize,
                  isEditMode,
                  appProvider,
                );
              }
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
            if (!isEditMode) {
              if (onAppTap != null) {
                onAppTap!(app);
              } else {
                appProvider.launchApp(app.packageName);
              }
            }
          },
          onLongPress: () {
            if (onAppLongPress != null) {
              onAppLongPress!(app);
            } else {
              _showAppOptions(context, app, appProvider);
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
    
    if (isEditMode) {
      return Draggable<AppInfo>(
        data: app,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: appWidget,
          ),
        ),
        childWhenDragging: Container(
          width: moduleSize,
          height: moduleSize,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: DragTarget<AppInfo>(
          onAccept: (draggedApp) {
            final draggedPosition = appProvider.getPositionOfApp(draggedApp.packageName);
            if (draggedPosition != null) {
              appProvider.moveAppInHomeGrid(draggedPosition, position);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return appWidget;
          },
        ),
        onDragStarted: () {
          // Opcional: feedback háptico
        },
        onDragEnd: (details) {
          // El drop se maneja en DragTarget
        },
      );
    }
    
    return appWidget;
  }
  
  Widget _buildEmptySlot(
    BuildContext context,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
  ) {
    return DragTarget<AppInfo>(
      onAccept: (app) {
        final currentPosition = appProvider.getPositionOfApp(app.packageName);
        if (currentPosition != null) {
          appProvider.moveAppInHomeGrid(currentPosition, position);
        } else {
          appProvider.addToHomeGridPosition(app, position);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return Container(
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
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: isHovering ? 2 : 1,
            ) : null,
          ),
          child: isEditMode ? Icon(
            Icons.add,
            color: isHovering 
                ? Colors.blue.withOpacity(0.7)
                : Colors.white.withOpacity(0.2),
            size: moduleSize * 0.3,
          ) : null,
        );
      },
    );
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${app.name} eliminado de la pantalla principal'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}