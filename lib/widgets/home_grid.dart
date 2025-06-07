import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        });
      },
      child: DragTarget<AppInfo>(
        onWillAccept: (data) => data != null && data.packageName != app.packageName,
        onAccept: (draggedApp) {
          final draggedPosition = appProvider.getPositionOfApp(draggedApp.packageName);
          if (draggedPosition != null && draggedPosition != position) {
            // Intercambiar posiciones
            _swapApps(appProvider, draggedPosition, position);
            HapticFeedback.mediumImpact();
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
    return DragTarget<AppInfo>(
      onWillAccept: (data) => data != null,
      onAccept: (app) {
        final currentPosition = appProvider.getPositionOfApp(app.packageName);
        if (currentPosition != null) {
          appProvider.moveAppInHomeGrid(currentPosition, position);
        } else {
          appProvider.addToHomeGridPosition(app, position);
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
  
  void _swapApps(AppProvider appProvider, int fromPosition, int toPosition) {
    final fromApp = appProvider.getAppAtPosition(fromPosition);
    final toApp = appProvider.getAppAtPosition(toPosition);
    
    if (fromApp != null) {
      appProvider.removeFromHomeGridPosition(fromPosition);
      if (toApp != null) {
        appProvider.removeFromHomeGridPosition(toPosition);
        appProvider.addToHomeGridPosition(toApp, fromPosition);
      }
      appProvider.addToHomeGridPosition(fromApp, toPosition);
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