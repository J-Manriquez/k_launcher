import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_launcher/models/folder_info.dart';
import 'package:k_launcher/models/widget_info.dart';
import 'package:k_launcher/widgets/folder_widget.dart';
import 'package:k_launcher/widgets/system_widget.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';

class HomeGridHelpers {
  static Widget buildFolderSlot(
    BuildContext context,
    FolderInfo folder,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
    SettingsProvider settings,
    Function(VoidCallback) setState,
    Map<int, GlobalKey> itemKeys,
    bool isDragging,
    int? draggedFromPosition,
    String? draggedItemId,
    Function(AppProvider, String) findFolderPosition,
    Function(AppProvider, int, int) swapItemsImproved,
  ) {
    itemKeys[position] ??= GlobalKey();

    return Container(
      key: itemKeys[position],
      child: isEditMode
          ? _buildImprovedDraggableFolder(
              FolderWidget(
                folder: folder,
                size: moduleSize * 0.9,
                onTap: () => _openFolderImproved(context, folder, appProvider),
              ),
              folder,
              position,
              moduleSize,
              appProvider,
              setState,
              isDragging,
              draggedFromPosition,
              draggedItemId,
              findFolderPosition,
              swapItemsImproved,
            )
          : FolderWidget(
              folder: folder,
              size: moduleSize * 0.9,
              onTap: () => _openFolderImproved(context, folder, appProvider),
              onLongPress: () {
                settings.setHomeGridEditMode(true);
                HapticFeedback.mediumImpact();
              },
            ),
    );
  }

  static Widget buildWidgetSlot(
    BuildContext context,
    WidgetInfo widget,
    int position,
    double moduleSize,
    bool isEditMode,
    AppProvider appProvider,
    SettingsProvider settings,
    Function(VoidCallback) setState,
  ) {
    final totalWidth = widget.width * moduleSize + (widget.width - 1) * 4;
    final totalHeight = widget.height * moduleSize + (widget.height - 1) * 4;

    Widget widgetContainer = Container(
      width: totalWidth,
      height: totalHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SystemWidget(
          widget: widget,
          onTap: isEditMode
              ? () => _showWidgetOptions(context, widget, appProvider, setState)
              : null,
          moduleSize: moduleSize,
        ),
      ),
    );

    return isEditMode
        ? _buildImprovedDraggableWidget(
            widgetContainer,
            widget,
            position,
            moduleSize,
            appProvider,
            setState,
          )
        : GestureDetector(
            onLongPress: () {
              settings.setHomeGridEditMode(true);
              HapticFeedback.mediumImpact();
            },
            child: widgetContainer,
          );
  }

  static Widget _buildImprovedDraggableFolder(
    Widget folderWidget,
    FolderInfo folder,
    int position,
    double moduleSize,
    AppProvider appProvider,
    Function(VoidCallback) setState,
    bool isDragging,
    int? draggedFromPosition,
    String? draggedItemId,
    Function(AppProvider, String) findFolderPosition,
    Function(AppProvider, int, int) swapItemsImproved,
  ) {
    return LongPressDraggable<FolderInfo>(
      data: folder,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Container(
            width: moduleSize,
            height: moduleSize,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Icon(
          Icons.folder_open,
          color: Colors.white.withOpacity(0.7),
          size: moduleSize * 0.4,
        ),
      ),
      onDragStarted: () {
        setState(() {
          isDragging = true;
          draggedFromPosition = position;
          draggedItemId = folder.id;
        });
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        setState(() {
          isDragging = false;
          draggedFromPosition = null;
          draggedItemId = null;
        });
      },
      child: DragTarget<Object>(
        onWillAccept: (data) {
          if (data is AppInfo) return true;
          if (data is FolderInfo) return data.id != folder.id;
          return false;
        },
        onAccept: (data) {
          if (data is AppInfo) {
            final draggedPosition = appProvider.getPositionOfApp(
              data.packageName,
            );
            if (draggedPosition != null) {
              appProvider.removeItemFromHomeGridPosition(draggedPosition);
              appProvider.addAppToFolder(folder.id, data);
              HapticFeedback.mediumImpact();
            }
          } else if (data is FolderInfo) {
            final draggedPosition = findFolderPosition(appProvider, data.id);
            if (draggedPosition != null && draggedPosition != position) {
              swapItemsImproved(appProvider, draggedPosition, position);
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
                  ? Border.all(color: Colors.orange, width: 2)
                  : null,
            ),
            child: folderWidget,
          );
        },
      ),
    );
  }

  static Widget _buildImprovedDraggableWidget(
    Widget widgetContainer,
    WidgetInfo widget,
    int position,
    double moduleSize,
    AppProvider appProvider,
    Function(VoidCallback) setState,
  ) {
    return LongPressDraggable<WidgetInfo>(
      data: widget,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: Container(
            width: widget.width * moduleSize,
            height: widget.height * moduleSize,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widgetContainer,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: widget.width * moduleSize,
        height: widget.height * moduleSize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Icon(
          Icons.widgets,
          color: Colors.white.withOpacity(0.7),
          size: moduleSize * 0.4,
        ),
      ),
      onDragStarted: () {
        setState(() {});
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        setState(() {});
      },
      child: DragTarget<Object>(
        onWillAccept: (data) => false,
        builder: (context, candidateData, rejectedData) => widgetContainer,
      ),
    );
  }

  static void _openFolderImproved(
    BuildContext context,
    FolderInfo folder,
    AppProvider appProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        folder.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: folder.apps.length,
                    itemBuilder: (context, index) {
                      final app = folder.apps[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          appProvider.launchApp(app.packageName);
                        },
                        onLongPress: () {
                          _showFolderAppOptions(
                            context,
                            app,
                            folder,
                            appProvider,
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: app.icon != null
                                      ? Image.memory(
                                          app.icon!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[700],
                                          child: const Icon(
                                            Icons.android,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  app.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
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

  static void _showWidgetOptions(
    BuildContext context,
    WidgetInfo widget,
    AppProvider appProvider,
    Function(VoidCallback) setState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opciones del Widget',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.crop_free, color: Colors.white70),
              title: const Text(
                'Redimensionar',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showWidgetResizeOptions(
                  context,
                  widget,
                  appProvider,
                  setState,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeWidget(appProvider, widget, setState);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showWidgetResizeOptions(
    BuildContext context,
    WidgetInfo widget,
    AppProvider appProvider,
    Function(VoidCallback) setState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Redimensionar Widget',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...[
              {'size': '1x1', 'width': 1, 'height': 1},
              {'size': '2x1', 'width': 2, 'height': 1},
              {'size': '1x2', 'width': 1, 'height': 2},
              {'size': '2x2', 'width': 2, 'height': 2},
              {'size': '3x2', 'width': 3, 'height': 2},
              {'size': '4x2', 'width': 4, 'height': 2},
            ].map(
              (option) => ListTile(
                leading: Icon(
                  Icons.crop_free,
                  color:
                      widget.width == option['width'] &&
                          widget.height == option['height']
                      ? Colors.orange
                      : Colors.white70,
                ),
                title: Text(
                  option['size'] as String,
                  style: TextStyle(
                    color:
                        widget.width == option['width'] &&
                            widget.height == option['height']
                        ? Colors.orange
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _resizeWidget(
                    appProvider,
                    widget,
                    option['width'] as int,
                    option['height'] as int,
                    setState,
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _resizeWidget(
    AppProvider appProvider,
    WidgetInfo widget,
    int newWidth,
    int newHeight,
    Function(VoidCallback) setState,
    BuildContext context,
  ) {
    final currentPosition = _findWidgetPosition(appProvider, widget.id);
    if (currentPosition == null) return;

    final currentPositions = <int>[];
    for (var entry in appProvider.homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widget.id) {
        currentPositions.add(entry.key);
      }
    }

    for (final pos in currentPositions) {
      appProvider.removeItemFromHomeGridPosition(pos);
    }

    if (_canPlaceWidgetAtPosition(
      appProvider,
      currentPosition,
      newWidth,
      newHeight,
    )) {
      final updatedWidget = WidgetInfo(
        id: widget.id,
        name: widget.name,
        width: newWidth,
        height: newHeight,
        packageName: widget.packageName,
        className: widget.className,
      );

      appProvider.updateWidget(updatedWidget);
      appProvider.updateWidgetSize(widget.id, newWidth, newHeight);
      _placeWidgetAtPosition(appProvider, updatedWidget, currentPosition);

      setState(() {});
    } else {
      final newPosition = appProvider.findEmptyPosition(newWidth, newHeight);
      if (newPosition != null) {
        final updatedWidget = WidgetInfo(
          id: widget.id,
          name: widget.name,
          width: newWidth,
          height: newHeight,
          packageName: widget.packageName,
          className: widget.className,
        );

        appProvider.updateWidget(updatedWidget);
        appProvider.updateWidgetSize(widget.id, newWidth, newHeight);
        _placeWidgetAtPosition(appProvider, updatedWidget, newPosition);

        setState(() {});
      } else {
        for (final pos in currentPositions) {
          appProvider.addItemToHomeGridPosition(widget, pos);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay espacio suficiente para el nuevo tamaño'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static void _removeWidget(
    AppProvider appProvider,
    WidgetInfo widget,
    Function(VoidCallback) setState,
  ) {
    final currentPositions = <int>[];
    for (var entry in appProvider.homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widget.id) {
        currentPositions.add(entry.key);
      }
    }

    for (final pos in currentPositions) {
      appProvider.removeItemFromHomeGridPosition(pos);
    }

    appProvider.removeWidget(widget.id);
    setState(() {});
  }

  static bool _canPlaceWidgetAtPosition(
    AppProvider appProvider,
    int startPosition,
    int width,
    int height,
  ) {
    final gridWidth = 4;
    final startRow = startPosition ~/ gridWidth;
    final startCol = startPosition % gridWidth;

    if (startCol + width > gridWidth) return false;

    for (int row = startRow; row < startRow + height; row++) {
      for (int col = startCol; col < startCol + width; col++) {
        final position = row * gridWidth + col;
        if (appProvider.homeGridItems.containsKey(position)) {
          return false;
        }
      }
    }
    return true;
  }

  static void _placeWidgetAtPosition(
    AppProvider appProvider,
    WidgetInfo widget,
    int startPosition,
  ) {
    final gridWidth = 4;
    final startRow = startPosition ~/ gridWidth;
    final startCol = startPosition % gridWidth;

    for (int row = startRow; row < startRow + widget.height; row++) {
      for (int col = startCol; col < startCol + widget.width; col++) {
        final position = row * gridWidth + col;
        appProvider.addItemToHomeGridPosition(widget, position);
      }
    }
  }

  static int? _findWidgetPosition(AppProvider appProvider, String widgetId) {
    for (var entry in appProvider.homeGridItems.entries) {
      if (entry.value is WidgetInfo &&
          (entry.value as WidgetInfo).id == widgetId) {
        return entry.key;
      }
    }
    return null;
  }

  static void _showFolderAppOptions(
    BuildContext context,
    AppInfo app,
    FolderInfo folder,
    AppProvider appProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              app.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white70),
              title: const Text(
                'Información de la app',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // appProvider.openAppInfo(app.packageName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.orange),
              title: const Text(
                'Quitar de la carpeta',
                style: TextStyle(color: Colors.orange),
              ),
              onTap: () {
                Navigator.pop(context);
                appProvider.removeAppFromFolder(folder.id, app.packageName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text(
                'Mover a inicio',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                final emptyPosition = appProvider.findEmptyPosition(1, 1);
                if (emptyPosition != null) {
                  appProvider.removeAppFromFolder(folder.id, app.packageName);
                  appProvider.addItemToHomeGridPosition(app, emptyPosition);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
