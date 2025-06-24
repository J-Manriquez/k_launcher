import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_launcher/models/folder_info.dart';
import 'package:k_launcher/models/widget_info.dart';
import 'package:k_launcher/widgets/folder_widget.dart';
import 'package:k_launcher/widgets/system_widget.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';
import 'home_grid_helpers.dart'; // Importar el archivo de helpers

class HomeGrid extends StatefulWidget {
  final List<AppInfo>? apps;
  final Function(AppInfo)? onAppTap;
  final Function(AppInfo)? onAppLongPress;

  const HomeGrid({super.key, this.apps, this.onAppTap, this.onAppLongPress});

  @override
  State<HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  bool _isDragging = false;
  int? _draggedFromPosition;
  final Map<int, GlobalKey> _itemKeys = {};
  final Map<String, Offset> _dragStartPositions = {};
  String? _draggedItemId;


  void _swapItemsImproved(
    AppProvider appProvider,
    int fromPosition,
    int toPosition,
  ) {
    final fromItem = appProvider.getItemAtPosition(fromPosition);
    final toItem = appProvider.getItemAtPosition(toPosition);

    appProvider.removeItemFromHomeGridPosition(fromPosition);
    if (toItem != null) {
      appProvider.removeItemFromHomeGridPosition(toPosition);
    }

    if (fromItem != null) {
      appProvider.addItemToHomeGridPosition(fromItem, toPosition);
    }
    if (toItem != null) {
      appProvider.addItemToHomeGridPosition(toItem, fromPosition);
    }
  }

  void _createFolderWithAppsImproved(
    AppProvider appProvider,
    AppInfo app1,
    AppInfo app2,
    int position,
  ) {
    if (appProvider.homeGridItems.containsKey(position)) {
      final emptyPosition = appProvider.findEmptyPosition(1, 1);
      if (emptyPosition != null) {
        position = emptyPosition;
      } else {
        return;
      }
    }

    final folder = FolderInfo(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Nueva Carpeta',
      apps: [app1, app2],
    );

    final app1Position = appProvider.getPositionOfApp(app1.packageName);
    final app2Position = appProvider.getPositionOfApp(app2.packageName);

    if (app1Position != null) {
      appProvider.removeItemFromHomeGridPosition(app1Position);
    }
    if (app2Position != null) {
      appProvider.removeItemFromHomeGridPosition(app2Position);
    }

    appProvider.addFolder(folder);
    appProvider.addItemToHomeGridPosition(folder, position);
    setState(() {});
  }

  int? _findFolderPosition(AppProvider appProvider, String folderId) {
    for (var entry in appProvider.homeGridItems.entries) {
      if (entry.value is FolderInfo &&
          (entry.value as FolderInfo).id == folderId) {
        return entry.key;
      }
    }
    return null;
  }

  Widget _buildImprovedDraggableApp(
    Widget appWidget,
    AppInfo app,
    int position,
    double moduleSize,
    AppProvider appProvider,
  ) {
    return LongPressDraggable<AppInfo>(
      data: app,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
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
      ),
      childWhenDragging: Container(
        width: moduleSize,
        height: moduleSize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Icon(
          Icons.apps,
          color: Colors.white.withOpacity(0.7),
          size: moduleSize * 0.4,
        ),
      ),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _draggedFromPosition = position;
          _draggedItemId = app.packageName;
        });
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _draggedFromPosition = null;
          _draggedItemId = null;
        });
      },
      child: DragTarget<Object>(
        onWillAccept: (data) {
          if (data is AppInfo) {
            return data.packageName != app.packageName;
          } else if (data is FolderInfo) {
            return true;
          }
          return false;
        },
        onAccept: (data) {
          if (data is AppInfo) {
            final draggedPosition = appProvider.getPositionOfApp(
              data.packageName,
            );
            if (draggedPosition != null && draggedPosition != position) {
              _createFolderWithAppsImproved(appProvider, data, app, position);
              HapticFeedback.mediumImpact();
            }
          } else if (data is FolderInfo) {
            final draggedPosition = _findFolderPosition(appProvider, data.id);
            if (draggedPosition != null && draggedPosition != position) {
              _swapItemsImproved(appProvider, draggedPosition, position);
              HapticFeedback.mediumImpact();
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isHovering
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: appWidget,
          );
        },
      ),
    );
  }

  Widget _buildImprovedAppSlot(
    BuildContext context,
    AppInfo app,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
    SettingsProvider settings,
  ) {
    _itemKeys[position] ??= GlobalKey();

    Widget appWidget = Container(
      key: _itemKeys[position],
      width: moduleSize,
      height: moduleSize,
      decoration: BoxDecoration(
        color: isEditMode ? Colors.black.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isEditMode
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: app.icon != null
                          ? Image.memory(app.icon!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.android,
                                size: moduleSize * 0.4,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                ),
                if (settings.showAppNamesHome)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        app.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (moduleSize * 0.1).clamp(10.0, 14.0),
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onLongPressStart: (details) {
        if (!isEditMode) {
          settings.setHomeGridEditMode(true);
          HapticFeedback.mediumImpact();
        }
        _dragStartPositions[app.packageName] = details.globalPosition;
      },
      child: isEditMode
          ? _buildImprovedDraggableApp(
              appWidget,
              app,
              position,
              moduleSize,
              appProvider,
            )
          : appWidget,
    );
  }

  Widget _buildImprovedEmptySlot(
    BuildContext context,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
  ) {
    return DragTarget<Object>(
      onWillAccept: (data) => isEditMode,
      onAccept: (data) {
        if (data is AppInfo) {
          final draggedPosition = appProvider.getPositionOfApp(data.packageName);
          if (draggedPosition != null) {
            appProvider.removeItemFromHomeGridPosition(draggedPosition);
            appProvider.addItemToHomeGridPosition(data, position);
            HapticFeedback.mediumImpact();
          }
        } else if (data is FolderInfo) {
          final draggedPosition = _findFolderPosition(appProvider, data.id);
          if (draggedPosition != null) {
            appProvider.removeItemFromHomeGridPosition(draggedPosition);
            appProvider.addItemToHomeGridPosition(data, position);
            HapticFeedback.mediumImpact();
          }
        }
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
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isEditMode
                ? Border.all(
                    color: isHovering
                        ? Colors.green
                        : Colors.white.withOpacity(0.2),
                    width: isHovering ? 2 : 1,
                  )
                : null,
          ),
          child: isEditMode
              ? Icon(
                  isHovering ? Icons.add_circle : Icons.add,
                  color: isHovering
                      ? Colors.green
                      : Colors.white.withOpacity(0.3),
                  size: moduleSize * 0.3,
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, SettingsProvider>(
      builder: (context, appProvider, settings, child) {
        final columns = settings.homeGridColumns;
        final rows = settings.homeGridRows;
        final screenSize = MediaQuery.of(context).size;
        final availableWidth = screenSize.width - 32;
        final moduleSize = (availableWidth - (columns - 1) * 4) / columns;
        final isEditMode = settings.homeGridEditMode;

        return Container(
          constraints: BoxConstraints(
            minHeight: rows * moduleSize,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: rows * moduleSize + (rows - 1) * 4,
              child: Stack(
                children: [
                  // Grid de fondo solo en modo edición
                  if (isEditMode)
                    _buildGridBackground(columns, rows, moduleSize),
                  // Elementos del grid
                  ..._buildGridItems(appProvider, settings, columns, rows, moduleSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Construir fondo del grid
  Widget _buildGridBackground(int columns, int rows, double moduleSize) {
    return Stack(
      children: List.generate(columns * rows, (index) {
        final row = index ~/ columns;
        final col = index % columns;
        return Positioned(
          left: col * (moduleSize + 4),
          top: row * (moduleSize + 4),
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }

  // Construir elementos del grid
  List<Widget> _buildGridItems(
    AppProvider appProvider,
    SettingsProvider settings,
    int columns,
    int rows,
    double moduleSize,
  ) {
    List<Widget> items = [];
    Set<int> occupiedPositions = {};

    for (var entry in appProvider.homeGridItems.entries) {
      final position = entry.key;
      final item = entry.value;
      
      if (occupiedPositions.contains(position)) continue;
      
      final row = position ~/ columns;
      final col = position % columns;
      
      if (item is WidgetInfo) {
        // Marcar todas las posiciones ocupadas por este widget
        for (int r = row; r < row + item.height && r < rows; r++) {
          for (int c = col; c < col + item.width && c < columns; c++) {
            occupiedPositions.add(r * columns + c);
          }
        }
        
        final totalWidth = item.width * moduleSize + (item.width - 1) * 4;
        final totalHeight = item.height * moduleSize + (item.height - 1) * 4;
        
        items.add(
          Positioned(
            left: col * (moduleSize + 4),
            top: row * (moduleSize + 4),
            child: Container(
              width: totalWidth,
              height: totalHeight,
              child: HomeGridHelpers.buildWidgetSlot(
                context,
                item,
                position,
                moduleSize,
                settings.homeGridEditMode,
                appProvider,
                settings,
                setState,
              ),
            ),
          ),
        );
      } else {
        // Apps y carpetas ocupan una sola celda
        occupiedPositions.add(position);
        
        Widget itemWidget;
        if (item is AppInfo) {
          itemWidget = _buildImprovedAppSlot(
            context,
            item,
            position,
            moduleSize,
            settings.homeGridEditMode,
            appProvider,
            settings,
          );
        } else if (item is FolderInfo) {
          itemWidget = HomeGridHelpers.buildFolderSlot(
            context,
            item,
            position,
            moduleSize,
            settings.homeGridEditMode,
            appProvider,
            settings,
            setState,
            _itemKeys,
            _isDragging,
            _draggedFromPosition,
            _draggedItemId,
            _findFolderPosition,
            _swapItemsImproved,
          );
        } else {
          continue;
        }
        
        items.add(
          Positioned(
            left: col * (moduleSize + 4),
            top: row * (moduleSize + 4),
            child: Container(
              width: moduleSize,
              height: moduleSize,
              child: itemWidget,
            ),
          ),
        );
      }
    }
    
    // Agregar slots vacíos en modo edición
    if (settings.homeGridEditMode) {
      for (int i = 0; i < columns * rows; i++) {
        if (!occupiedPositions.contains(i)) {
          final row = i ~/ columns;
          final col = i % columns;
          
          items.add(
            Positioned(
              left: col * (moduleSize + 4),
              top: row * (moduleSize + 4),
              child: Container(
                width: moduleSize,
                height: moduleSize,
                child: _buildImprovedEmptySlot(
                  context,
                  i,
                  moduleSize,
                  true,
                  appProvider,
                ),
              ),
            ),
          );
        }
      }
    }
    
    return items;
  }
}
