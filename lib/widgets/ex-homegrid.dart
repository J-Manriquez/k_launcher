// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:k_launcher/models/folder_info.dart';
// import 'package:k_launcher/models/widget_info.dart';
// import 'package:k_launcher/widgets/folder_widget.dart';
// import 'package:k_launcher/widgets/system_widget.dart';
// import 'package:provider/provider.dart';
// import '../models/app_info.dart';
// import '../providers/app_provider.dart';
// import '../providers/settings_provider.dart';
// import 'app_icon.dart';

// class HomeGrid extends StatefulWidget {
//   final List<AppInfo>? apps;
//   final Function(AppInfo)? onAppTap;
//   final Function(AppInfo)? onAppLongPress;

//   const HomeGrid({super.key, this.apps, this.onAppTap, this.onAppLongPress});

//   @override
//   State<HomeGrid> createState() => _HomeGridState();
// }

// class _HomeGridState extends State<HomeGrid> {
//   bool _isDragging = false;
//   int? _draggedFromPosition;
//   final Map<int, GlobalKey> _itemKeys = {}; // Nuevo: claves para cada elemento
//   final Map<String, Offset> _dragStartPositions = {};
//   String? _draggedItemId; // Agregar esta línea

//   Widget _buildImprovedGridBackground(
//     int columns,
//     int rows,
//     double moduleSize,
//   ) {
//     return Positioned(
//       top: 50, // Offset para evitar superposición con status bar
//       left: 0,
//       right: 0,
//       child: Container(
//         height: rows * moduleSize,
//         child: GridView.builder(
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: columns,
//             crossAxisSpacing: 4,
//             mainAxisSpacing: 4,
//             childAspectRatio: 1.0,
//           ),
//           itemCount: columns * rows,
//           itemBuilder: (context, index) {
//             return _buildImprovedEmptySlot(
//               context,
//               index,
//               moduleSize,
//               true,
//               Provider.of<AppProvider>(context, listen: false),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Funciones auxiliares mejoradas
//   void _swapItemsImproved(
//     AppProvider appProvider,
//     int fromPosition,
//     int toPosition,
//   ) {
//     final fromItem = appProvider.getItemAtPosition(fromPosition);
//     final toItem = appProvider.getItemAtPosition(toPosition);

//     // Limpiar posiciones originales
//     appProvider.removeItemFromHomeGridPosition(fromPosition);
//     if (toItem != null) {
//       appProvider.removeItemFromHomeGridPosition(toPosition);
//     }

//     // Colocar elementos en nuevas posiciones
//     if (fromItem != null) {
//       appProvider.addItemToHomeGridPosition(fromItem, toPosition);
//     }
//     if (toItem != null) {
//       appProvider.addItemToHomeGridPosition(toItem, fromPosition);
//     }
//   }

//   void _createFolderWithAppsImproved(
//     AppProvider appProvider,
//     AppInfo app1,
//     AppInfo app2,
//     int position,
//   ) {
//     // Verificar que la posición esté disponible
//     if (appProvider.homeGridItems.containsKey(position)) {
//       // Buscar una posición vacía cercana
//       final emptyPosition = appProvider.findEmptyPosition(1, 1);
//       if (emptyPosition != null) {
//         position = emptyPosition;
//       } else {
//         return; // No hay espacio disponible
//       }
//     }

//     // Crear nueva carpeta con ID único
//     final folder = FolderInfo(
//       id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
//       name: 'Nueva Carpeta',
//       apps: [app1, app2],
//     );

//     // Remover apps de sus posiciones actuales
//     final app1Position = appProvider.getPositionOfApp(app1.packageName);
//     final app2Position = appProvider.getPositionOfApp(app2.packageName);

//     if (app1Position != null) {
//       appProvider.removeItemFromHomeGridPosition(app1Position);
//     }
//     if (app2Position != null) {
//       appProvider.removeItemFromHomeGridPosition(app2Position);
//     }

//     // Agregar carpeta al provider y al grid
//     appProvider.addFolder(folder);
//     appProvider.addItemToHomeGridPosition(folder, position);

//     // Notificar cambios
//     setState(() {});
//   }

//   int? _findFolderPosition(AppProvider appProvider, String folderId) {
//     for (var entry in appProvider.homeGridItems.entries) {
//       if (entry.value is FolderInfo &&
//           (entry.value as FolderInfo).id == folderId) {
//         return entry.key;
//       }
//     }
//     return null;
//   }

//   void _moveWidgetToPosition(
//     AppProvider appProvider,
//     WidgetInfo widget,
//     int newPosition,
//   ) {
//     // Limpiar posiciones actuales del widget
//     final currentPositions = <int>[];
//     for (var entry in appProvider.homeGridItems.entries) {
//       if (entry.value is WidgetInfo &&
//           (entry.value as WidgetInfo).id == widget.id) {
//         currentPositions.add(entry.key);
//       }
//     }

//     // Remover de posiciones actuales
//     for (final pos in currentPositions) {
//       appProvider.removeItemFromHomeGridPosition(pos);
//     }

//     // Verificar si hay espacio en la nueva posición
//     final columns = Provider.of<SettingsProvider>(
//       context,
//       listen: false,
//     ).homeGridColumns;
//     if (_canPlaceWidgetAtPosition(
//       appProvider,
//       newPosition,
//       widget.width,
//       widget.height,
//     )) {
//       _placeWidgetAtPosition(appProvider, widget, newPosition);
//     } else {
//       // Si no hay espacio, volver a colocar en posición original
//       for (final pos in currentPositions) {
//         appProvider.addItemToHomeGridPosition(widget, pos);
//       }
//     }
//   }

//   Widget _buildImprovedDraggableApp(
//     Widget appWidget,
//     AppInfo app,
//     int position,
//     double moduleSize,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<AppInfo>(
//       data: app,
//       delay: const Duration(milliseconds: 150),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.1,
//           child: Container(
//             width: moduleSize,
//             height: moduleSize,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: appWidget,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: moduleSize,
//         height: moduleSize,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//         ),
//         child: Icon(
//           Icons.apps,
//           color: Colors.white.withOpacity(0.7),
//           size: moduleSize * 0.4,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//           _draggedItemId = app.packageName;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//           _draggedItemId = null;
//         });
//       },
//       child: DragTarget<Object>(
//         onWillAccept: (data) {
//           if (data is AppInfo) {
//             return data.packageName != app.packageName;
//           } else if (data is FolderInfo) {
//             return true;
//           }
//           return false;
//         },
//         onAccept: (data) {
//           if (data is AppInfo) {
//             final draggedPosition = appProvider.getPositionOfApp(
//               data.packageName,
//             );
//             if (draggedPosition != null && draggedPosition != position) {
//               // Crear carpeta si se arrastra una app sobre otra
//               _createFolderWithAppsImproved(appProvider, data, app, position);
//               HapticFeedback.mediumImpact();
//             }
//           } else if (data is FolderInfo) {
//             final draggedPosition = _findFolderPosition(appProvider, data.id);
//             if (draggedPosition != null && draggedPosition != position) {
//               _swapItemsImproved(appProvider, draggedPosition, position);
//               HapticFeedback.mediumImpact();
//             }
//           }
//         },
//         builder: (context, candidateData, rejectedData) {
//           final isHovering = candidateData.isNotEmpty;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: isHovering
//                   ? Border.all(color: Colors.blue, width: 2)
//                   : null,
//             ),
//             child: appWidget,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildImprovedAppSlot(
//     BuildContext context,
//     AppInfo app,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     _itemKeys[position] ??= GlobalKey();

//     Widget appWidget = Container(
//       key: _itemKeys[position],
//       width: moduleSize,
//       height: moduleSize,
//       decoration: BoxDecoration(
//         color: isEditMode ? Colors.black.withOpacity(0.1) : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: isEditMode
//             ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () {
//             if (!isEditMode && !_isDragging) {
//               if (widget.onAppTap != null) {
//                 widget.onAppTap!(app);
//               } else {
//                 appProvider.launchApp(app.packageName);
//               }
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: app.icon != null
//                           ? Image.memory(app.icon!, fit: BoxFit.cover)
//                           : Container(
//                               color: Colors.grey[300],
//                               child: Icon(
//                                 Icons.android,
//                                 size: moduleSize * 0.4,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 if (settings.showAppNamesHome)
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Text(
//                         app.name,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: (moduleSize * 0.1).clamp(10.0, 14.0),
//                           fontWeight: FontWeight.w500,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.5),
//                               blurRadius: 2,
//                             ),
//                           ],
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     return GestureDetector(
//       onLongPressStart: (details) {
//         if (!isEditMode) {
//           settings.setHomeGridEditMode(true);
//           HapticFeedback.mediumImpact();
//         }
//         _dragStartPositions[app.packageName] = details.globalPosition;
//       },
//       child: isEditMode
//           ? _buildImprovedDraggableApp(
//               appWidget,
//               app,
//               position,
//               moduleSize,
//               appProvider,
//             )
//           : appWidget,
//     );
//   }

//   Widget _buildImprovedWidgetSlot(
//     BuildContext context,
//     WidgetInfo widget,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     final totalWidth = widget.width * moduleSize + (widget.width - 1) * 4;
//     final totalHeight = widget.height * moduleSize + (widget.height - 1) * 4;

//     Widget widgetChild = SystemWidget(widget: widget, moduleSize: moduleSize);

//     Widget widgetContainer = Container(
//       width: totalWidth,
//       height: totalHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: widgetChild,
//     );

//     return GestureDetector(
//       onLongPressStart: (details) {
//         if (!isEditMode) {
//           settings.setHomeGridEditMode(true);
//           HapticFeedback.mediumImpact();
//         } else {
//           _showImprovedWidgetOptions(context, widget, appProvider);
//         }
//       },
//       child: isEditMode
//           ? _buildImprovedDraggableWidget(
//               widgetContainer,
//               widget,
//               position,
//               totalWidth,
//               totalHeight,
//               appProvider,
//             )
//           : widgetContainer,
//     );
//   }

//   Widget _buildImprovedDraggableWidget(
//     Widget widgetContainer,
//     WidgetInfo widget,
//     int position,
//     double totalWidth,
//     double totalHeight,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<WidgetInfo>(
//       data: widget,
//       delay: const Duration(milliseconds: 150),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.05,
//           child: Container(
//             width: totalWidth,
//             height: totalHeight,
//             decoration: BoxDecoration(
//               color: Colors.purple.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: widgetContainer,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: totalWidth,
//         height: totalHeight,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//         ),
//         child: Icon(
//           Icons.widgets,
//           color: Colors.white.withOpacity(0.7),
//           size: totalWidth * 0.2,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//           _draggedItemId = widget.id;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//           _draggedItemId = null;
//         });
//       },
//       child: DragTarget<Object>(
//         onWillAccept: (data) => false, // Los widgets no aceptan drops
//         builder: (context, candidateData, rejectedData) => widgetContainer,
//       ),
//     );
//   }

//   Widget _buildImprovedDraggableFolder(
//     Widget folderWidget,
//     FolderInfo folder,
//     int position,
//     double moduleSize,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<FolderInfo>(
//       data: folder,
//       delay: const Duration(milliseconds: 150),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.1,
//           child: Container(
//             width: moduleSize,
//             height: moduleSize,
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: folderWidget,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: moduleSize,
//         height: moduleSize,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//         ),
//         child: Icon(
//           Icons.folder_open,
//           color: Colors.white.withOpacity(0.7),
//           size: moduleSize * 0.4,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//           _draggedItemId = folder.id;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//           _draggedItemId = null;
//         });
//       },
//       child: DragTarget<Object>(
//         onWillAccept: (data) {
//           if (data is AppInfo) return true;
//           if (data is FolderInfo) return data.id != folder.id;
//           return false;
//         },
//         onAccept: (data) {
//           if (data is AppInfo) {
//             final draggedPosition = appProvider.getPositionOfApp(
//               data.packageName,
//             );
//             if (draggedPosition != null) {
//               appProvider.removeItemFromHomeGridPosition(draggedPosition);
//               appProvider.addAppToFolder(folder.id, data);
//               HapticFeedback.mediumImpact();
//             }
//           } else if (data is FolderInfo) {
//             final draggedPosition = _findFolderPosition(appProvider, data.id);
//             if (draggedPosition != null && draggedPosition != position) {
//               _swapItemsImproved(appProvider, draggedPosition, position);
//               HapticFeedback.mediumImpact();
//             }
//           }
//         },
//         builder: (context, candidateData, rejectedData) {
//           final isHovering = candidateData.isNotEmpty;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: isHovering
//                   ? Border.all(color: Colors.orange, width: 2)
//                   : null,
//             ),
//             child: folderWidget,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildImprovedEmptySlot(
//     BuildContext context,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//   ) {
//     return DragTarget<Object>(
//       onWillAccept: (data) =>
//           data != null && !appProvider.homeGridItems.containsKey(position),
//       onAccept: (data) {
//         if (data is AppInfo) {
//           final currentPosition = appProvider.getPositionOfApp(
//             data.packageName,
//           );
//           if (currentPosition != null) {
//             appProvider.moveItemInHomeGrid(currentPosition, position);
//           } else {
//             appProvider.addItemToHomeGridPosition(data, position);
//           }
//         } else if (data is FolderInfo) {
//           final currentPosition = _findFolderPosition(appProvider, data.id);
//           if (currentPosition != null) {
//             appProvider.moveItemInHomeGrid(currentPosition, position);
//           }
//         } else if (data is WidgetInfo) {
//           _moveWidgetToPosition(appProvider, data, position);
//         }
//         HapticFeedback.mediumImpact();
//       },
//       builder: (context, candidateData, rejectedData) {
//         final isHovering = candidateData.isNotEmpty;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: moduleSize,
//           height: moduleSize,
//           decoration: BoxDecoration(
//             color: isEditMode
//                 ? (isHovering
//                       ? Colors.blue.withOpacity(0.3)
//                       : Colors.transparent)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             border: isEditMode
//                 ? Border.all(
//                     color: isHovering
//                         ? Colors.blue
//                         : Colors.white.withOpacity(0.1),
//                     width: isHovering ? 2 : 1,
//                   )
//                 : null,
//           ),
//           child: isEditMode
//               ? Icon(
//                   isHovering ? Icons.add_circle : Icons.add,
//                   color: isHovering
//                       ? Colors.blue
//                       : Colors.white.withOpacity(0.3),
//                   size: moduleSize * 0.3,
//                 )
//               : null,
//         );
//       },
//     );
//   }

//   Widget _buildImprovedFolderSlot(
//     BuildContext context,
//     FolderInfo folder,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     _itemKeys[position] ??= GlobalKey();

//     return Container(
//       key: _itemKeys[position],
//       child: isEditMode
//           ? _buildImprovedDraggableFolder(
//               FolderWidget(
//                 folder: folder,
//                 size: moduleSize * 0.9,
//                 onTap: () => _openFolderImproved(context, folder, appProvider),
//               ),
//               folder,
//               position,
//               moduleSize,
//               appProvider,
//             )
//           : FolderWidget(
//               folder: folder,
//               size: moduleSize * 0.9,
//               onTap: () => _openFolderImproved(context, folder, appProvider),
//               onLongPress: () {
//                 settings.setHomeGridEditMode(true);
//                 HapticFeedback.mediumImpact();
//               },
//             ),
//     );
//   }

//   List<Widget> _buildAllGridItemsImproved(
//     AppProvider appProvider,
//     SettingsProvider settings,
//     double moduleSize,
//     bool isEditMode,
//     int columns,
//   ) {
//     final List<Widget> items = [];
//     final Set<int> processedPositions = {};

//     for (final entry in appProvider.homeGridItems.entries) {
//       final position = entry.key;
//       final item = entry.value;

//       if (processedPositions.contains(position)) continue;

//       final row = position ~/ columns;
//       final col = position % columns;
//       final left = col * (moduleSize + 4); // Incluir spacing
//       final top = 50 + row * (moduleSize + 4); // Offset inicial + spacing

//       Widget? itemWidget;

//       if (item is AppInfo) {
//         itemWidget = _buildImprovedAppSlot(
//           context,
//           item,
//           position,
//           moduleSize,
//           isEditMode,
//           appProvider,
//           settings,
//         );
//         processedPositions.add(position);
//       } else if (item is FolderInfo) {
//         itemWidget = _buildImprovedFolderSlot(
//           context,
//           item,
//           position,
//           moduleSize,
//           isEditMode,
//           appProvider,
//           settings,
//         );
//         processedPositions.add(position);
//       } else if (item is WidgetInfo) {
//         final startPosition = appProvider.getWidgetStartPosition(item.id);
//         if (startPosition == position) {
//           itemWidget = _buildImprovedWidgetSlot(
//             context,
//             item,
//             position,
//             moduleSize,
//             isEditMode,
//             appProvider,
//             settings,
//           );

//           // Marcar todas las posiciones ocupadas
//           final startRow = startPosition! ~/ columns;
//           final startCol = startPosition % columns;
//           for (int r = startRow; r < startRow + item.height; r++) {
//             for (int c = startCol; c < startCol + item.width; c++) {
//               processedPositions.add(r * columns + c);
//             }
//           }
//         }
//       }

//       if (itemWidget != null) {
//         items.add(Positioned(left: left, top: top, child: itemWidget));
//       }
//     }

//     return items;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<AppProvider, SettingsProvider>(
//       builder: (context, appProvider, settings, child) {
//         final screenSize = MediaQuery.of(context).size;
//         final padding = MediaQuery.of(context).padding;

//         // Calcular espacio disponible con mejor precisión
//         final availableWidth = screenSize.width - 32; // Margen lateral
//         final availableHeight =
//             screenSize.height -
//             padding.top -
//             padding.bottom -
//             100; // Espacio para UI

//         final columns = settings.homeGridColumns;
//         final rows = settings.homeGridRows;
//         final isEditMode = settings.homeGridEditMode;

//         // Calcular tamaño de módulo con mejor distribución
//         final moduleWidth = availableWidth / columns;
//         final moduleHeight = availableHeight / rows;
//         final moduleSize =
//             (moduleWidth < moduleHeight ? moduleWidth : moduleHeight).clamp(
//               60.0,
//               120.0,
//             );

//         return Container(
//           width: screenSize.width,
//           height: screenSize.height,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Stack(
//             children: [
//               // Grid de fondo mejorado
//               if (isEditMode)
//                 _buildImprovedGridBackground(columns, rows, moduleSize),

//               // Elementos del grid con posicionamiento corregido
//               ..._buildAllGridItemsImproved(
//                 appProvider,
//                 settings,
//                 moduleSize,
//                 isEditMode,
//                 columns,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGridBackground(int columns, int rows, double moduleSize) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: columns,
//         crossAxisSpacing: 0,
//         mainAxisSpacing: 0,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: columns * rows,
//       itemBuilder: (context, index) {
//         return _buildEmptySlot(
//           context,
//           index,
//           moduleSize,
//           true,
//           Provider.of<AppProvider>(context, listen: false),
//         );
//       },
//     );
//   }

//   List<Widget> _buildAllGridItems(
//     AppProvider appProvider,
//     SettingsProvider settings,
//     double moduleSize,
//     bool isEditMode,
//   ) {
//     final List<Widget> items = [];
//     final Set<int> processedPositions = {};
//     final columns = settings.homeGridColumns;

//     for (final entry in appProvider.homeGridItems.entries) {
//       final position = entry.key;
//       final item = entry.value;

//       // Skip if this position was already processed (for multi-cell widgets)
//       if (processedPositions.contains(position)) continue;

//       final row = position ~/ columns;
//       final col = position % columns;
//       final left = col * moduleSize;
//       final top = row * moduleSize;

//       if (item is AppInfo) {
//         items.add(
//           Positioned(
//             left: left,
//             top: top,
//             child: _buildAppSlot(
//               context,
//               item,
//               position,
//               moduleSize,
//               isEditMode,
//               appProvider,
//               settings,
//             ),
//           ),
//         );
//         processedPositions.add(position);
//       } else if (item is FolderInfo) {
//         items.add(
//           Positioned(
//             left: left,
//             top: top,
//             child: _buildFolderSlot(
//               context,
//               item,
//               position,
//               moduleSize,
//               isEditMode,
//               appProvider,
//               settings,
//             ),
//           ),
//         );
//         processedPositions.add(position);
//       } else if (item is WidgetInfo) {
//         // Only render widget at its start position
//         final startPosition = appProvider.getWidgetStartPosition(item.id);
//         if (startPosition == position) {
//           items.add(
//             Positioned(
//               left: left,
//               top: top,
//               child: _buildWidgetSlot(
//                 context,
//                 item,
//                 position,
//                 moduleSize,
//                 isEditMode,
//                 appProvider,
//                 settings,
//               ),
//             ),
//           );

//           // Mark all positions occupied by this widget as processed
//           final startRow = startPosition! ~/ columns;
//           final startCol = startPosition % columns;
//           for (int r = startRow; r < startRow + item.height; r++) {
//             for (int c = startCol; c < startCol + item.width; c++) {
//               processedPositions.add(r * columns + c);
//             }
//           }
//         }
//       }
//     }

//     return items;
//   }

//   Widget _buildAppSlot(
//     BuildContext context,
//     AppInfo app,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     // Crear una clave única para este elemento
//     _itemKeys[position] ??= GlobalKey();
//     Widget appWidget = Container(
//       key: _itemKeys[position],
//       width: moduleSize,
//       height: moduleSize,
//       decoration: BoxDecoration(
//         color: isEditMode ? Colors.black.withOpacity(0.2) : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//         border: isEditMode
//             ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(8),
//           onTap: () {
//             if (!isEditMode && !_isDragging) {
//               if (widget.onAppTap != null) {
//                 widget.onAppTap!(app);
//               } else {
//                 appProvider.launchApp(app.packageName);
//               }
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(2),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: app.icon != null
//                           ? Image.memory(app.icon!, fit: BoxFit.cover)
//                           : Container(
//                               color: Colors.grey[300],
//                               child: Icon(
//                                 Icons.android,
//                                 size: moduleSize * 0.3,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 if (settings.showAppNamesHome)
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       app.name,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: (moduleSize * 0.08).clamp(8.0, 12.0),
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     // Envolver en GestureDetector para manejar long press y drag
//     return GestureDetector(
//       onLongPressStart: (details) {
//         if (!isEditMode) {
//           // Activar modo edición y iniciar drag
//           settings.setHomeGridEditMode(true);
//           HapticFeedback.mediumImpact();
//         }
//       },
//       child: isEditMode
//           ? _buildDraggableApp(
//               appWidget,
//               app,
//               position,
//               moduleSize,
//               appProvider,
//             )
//           : appWidget,
//     );
//   }

//   Widget _buildDraggableApp(
//     Widget appWidget,
//     AppInfo app,
//     int position,
//     double moduleSize,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<AppInfo>(
//       data: app,
//       delay: const Duration(milliseconds: 100),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.2,
//           child: Container(
//             width: moduleSize,
//             height: moduleSize,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.5),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: appWidget,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: moduleSize,
//         height: moduleSize,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.5),
//             width: 2,
//             // style: BorderStyle.dashed,
//           ),
//         ),
//         child: Icon(
//           Icons.apps,
//           color: Colors.white.withOpacity(0.5),
//           size: moduleSize * 0.3,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//           _showDeleteMenu(
//             context,
//             position,
//             app,
//             appProvider,
//             _itemKeys[position],
//           );
//         });
//       },
//       child: DragTarget<Object>(
//         onWillAccept: (data) {
//           if (data is AppInfo) {
//             return data.packageName != app.packageName;
//           } else if (data is FolderInfo) {
//             return true; // Aceptar carpetas
//           }
//           return false;
//         },
//         onAccept: (data) {
//           if (data is AppInfo) {
//             final draggedPosition = appProvider.getPositionOfApp(
//               data.packageName,
//             );
//             if (draggedPosition != null && draggedPosition != position) {
//               // Intercambiar posiciones
//               _swapItems(appProvider, draggedPosition, position);
//               HapticFeedback.mediumImpact();
//             }
//           } else if (data is FolderInfo) {
//             final draggedPosition = appProvider.homeGridItems.entries
//                 .where(
//                   (entry) =>
//                       entry.value is FolderInfo &&
//                       (entry.value as FolderInfo).id == data.id,
//                 )
//                 .firstOrNull
//                 ?.key;

//             if (draggedPosition != null && draggedPosition != position) {
//               // Intercambiar posiciones
//               _swapItems(appProvider, draggedPosition, position);
//               HapticFeedback.mediumImpact();
//             }
//           }
//         },
//         builder: (context, candidateData, rejectedData) {
//           final isHovering = candidateData.isNotEmpty;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: isHovering
//                   ? Border.all(color: Colors.blue, width: 2)
//                   : null,
//             ),
//             child: appWidget,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDraggableWidget(
//     Widget widgetContainer,
//     WidgetInfo widget,
//     int position,
//     double totalWidth,
//     double totalHeight,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<WidgetInfo>(
//       data: widget,
//       delay: const Duration(milliseconds: 100),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.1,
//           child: Container(
//             width: totalWidth,
//             height: totalHeight,
//             decoration: BoxDecoration(
//               color: Colors.purple.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.5),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: widgetContainer,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: totalWidth,
//         height: totalHeight,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//         ),
//         child: Icon(
//           Icons.widgets,
//           color: Colors.white.withOpacity(0.5),
//           size: totalWidth * 0.3,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//         });
//       },
//       child: widgetContainer,
//     );
//   }

//   // Agregar el método _buildWidgetSlot:
//   Widget _buildWidgetSlot(
//     BuildContext context,
//     WidgetInfo widget,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     // Calculate total widget size
//     final totalWidth = widget.width * moduleSize;
//     final totalHeight = widget.height * moduleSize;

//     Widget widgetChild = SystemWidget(widget: widget, moduleSize: moduleSize);

//     Widget widgetContainer = Container(
//       width: totalWidth,
//       height: totalHeight,
//       child: widgetChild,
//     );

//     // Agregar GestureDetector para manejar long press
//     return GestureDetector(
//       onLongPressStart: (details) {
//         if (!isEditMode) {
//           settings.setHomeGridEditMode(true);
//           HapticFeedback.mediumImpact();
//         } else {
//           // Mostrar menú de opciones del widget
//           _showWidgetResizeOptions(context, widget, appProvider);
//         }
//       },
//       child: isEditMode
//           ? _buildDraggableWidget(
//               widgetContainer,
//               widget,
//               position,
//               totalWidth,
//               totalHeight,
//               appProvider,
//             )
//           : widgetContainer,
//     );
//   }

//   Widget _buildEmptySlot(
//     BuildContext context,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//   ) {
//     return DragTarget<Object>(
//       onWillAccept: (data) => data != null,
//       onAccept: (data) {
//         if (data is AppInfo) {
//           final currentPosition = appProvider.getPositionOfApp(
//             data.packageName,
//           );
//           if (currentPosition != null) {
//             appProvider.moveItemInHomeGrid(currentPosition, position);
//           } else {
//             appProvider.addItemToHomeGridPosition(data, position);
//           }
//         } else if (data is FolderInfo) {
//           final currentPosition = appProvider.homeGridItems.entries
//               .where(
//                 (entry) =>
//                     entry.value is FolderInfo &&
//                     (entry.value as FolderInfo).id == data.id,
//               )
//               .firstOrNull
//               ?.key;

//           if (currentPosition != null) {
//             appProvider.moveItemInHomeGrid(currentPosition, position);
//           }
//         } else if (data is WidgetInfo) {
//           final currentPosition = appProvider.homeGridItems.entries
//               .where(
//                 (entry) =>
//                     entry.value is WidgetInfo &&
//                     (entry.value as WidgetInfo).id == data.id,
//               )
//               .firstOrNull
//               ?.key;

//           if (currentPosition != null) {
//             appProvider.moveItemInHomeGrid(currentPosition, position);
//           }
//         }
//         HapticFeedback.mediumImpact();
//       },
//       builder: (context, candidateData, rejectedData) {
//         final isHovering = candidateData.isNotEmpty;

//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: moduleSize,
//           height: moduleSize,
//           decoration: BoxDecoration(
//             color: isEditMode
//                 ? (isHovering
//                       ? Colors.blue.withOpacity(0.3)
//                       : Colors.transparent)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//             border: isEditMode
//                 ? Border.all(
//                     color: isHovering
//                         ? Colors.blue
//                         : Colors.white.withOpacity(0.1),
//                     width: isHovering ? 2 : 1,
//                   )
//                 : null,
//           ),
//           child: isEditMode
//               ? Icon(
//                   isHovering ? Icons.add_circle : Icons.add,
//                   color: isHovering
//                       ? Colors.blue
//                       : Colors.white.withOpacity(0.3),
//                   size: moduleSize * 0.3,
//                 )
//               : null,
//         );
//       },
//     );
//   }

//   void _swapItems(AppProvider appProvider, int fromPosition, int toPosition) {
//     final fromItem = appProvider.getItemAtPosition(fromPosition);
//     final toItem = appProvider.getItemAtPosition(toPosition);

//     if (fromItem != null) {
//       appProvider.removeItemFromHomeGridPosition(fromPosition);
//       if (toItem != null) {
//         appProvider.removeItemFromHomeGridPosition(toPosition);
//         appProvider.addItemToHomeGridPosition(toItem, fromPosition);
//       }
//       appProvider.addItemToHomeGridPosition(fromItem, toPosition);
//     }
//   }

//   void _showAppOptions(
//     BuildContext context,
//     AppInfo app,
//     AppProvider appProvider,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[900],
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.info, color: Colors.white),
//             title: const Text(
//               'Información de la app',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               // TODO: Abrir información de la app
//             },
//           ),
//           ListTile(
//             leading: Icon(
//               appProvider.isFavorite(app.packageName)
//                   ? Icons.favorite
//                   : Icons.favorite_border,
//               color: Colors.white,
//             ),
//             title: Text(
//               appProvider.isFavorite(app.packageName)
//                   ? 'Quitar de favoritos'
//                   : 'Agregar a favoritos',
//               style: const TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               if (appProvider.isFavorite(app.packageName)) {
//                 appProvider.removeFromFavorites(app.packageName);
//               } else {
//                 appProvider.addToFavorites(app);
//               }
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.remove_circle, color: Colors.white),
//             title: const Text(
//               'Quitar de pantalla principal',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               appProvider.removeFromHomeScreen(app.packageName);
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   SnackBar(
//               //     content: Text('${app.name} eliminado de la pantalla principal'),
//               //     duration: const Duration(seconds: 2),
//               //   ),
//               // );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFolderSlot(
//     BuildContext context,
//     FolderInfo folder,
//     int position,
//     double moduleSize,
//     bool isEditMode,
//     AppProvider appProvider,
//     SettingsProvider settings,
//   ) {
//     // Crear una clave única para este elemento
//     _itemKeys[position] ??= GlobalKey();
//     return Container(
//       key: _itemKeys[position], // Asignar la clave única
//       child: isEditMode
//           ? _buildDraggableFolder(
//               FolderWidget(
//                 folder: folder,
//                 size: moduleSize * 0.8,
//                 onTap: () => _openFolder(context, folder, appProvider),
//               ),
//               folder,
//               position,
//               moduleSize,
//               appProvider,
//             )
//           : FolderWidget(
//               folder: folder,
//               size: moduleSize * 0.8,
//               onTap: () => _openFolder(context, folder, appProvider),
//               onLongPress: () {
//                 settings.setHomeGridEditMode(true);
//                 HapticFeedback.mediumImpact();
//               },
//             ),
//     );
//   }

//   void _openFolder(
//     BuildContext context,
//     FolderInfo folder,
//     AppProvider appProvider,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.grey[900],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           // Obtener la carpeta actualizada del provider
//           final updatedFolder = appProvider.folders.firstWhere(
//             (f) => f.id == folder.id,
//             orElse: () => folder,
//           );

//           return DraggableScrollableSheet(
//             initialChildSize: 0.7,
//             minChildSize: 0.5,
//             maxChildSize: 0.95,
//             expand: false,
//             builder: (context, scrollController) => Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         updatedFolder.name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           // Botón para añadir aplicaciones
//                           IconButton(
//                             icon: const Icon(Icons.add, color: Colors.white),
//                             onPressed: () => _showAppSelectionDialog(
//                               context,
//                               updatedFolder,
//                               appProvider,
//                               () => setState(
//                                 () {},
//                               ), // Callback para actualizar el estado
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.white),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: GridView.builder(
//                     controller: scrollController,
//                     padding: const EdgeInsets.all(16),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: updatedFolder.columns,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: 0.8,
//                     ),
//                     itemCount: updatedFolder.apps.length,
//                     itemBuilder: (context, index) {
//                       final app = updatedFolder.apps[index];
//                       return AppIcon(
//                         app: app,
//                         onTap: () {
//                           Navigator.pop(context);
//                           appProvider.launchApp(app.packageName);
//                         },
//                         onLongPress: () => _showFolderAppOptions(
//                           context,
//                           app,
//                           updatedFolder,
//                           appProvider,
//                           () => setState(
//                             () {},
//                           ), // Callback para actualizar el estado
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showFolderAppOptions(
//     BuildContext context,
//     AppInfo app,
//     FolderInfo folder, // Cambiar de String a FolderInfo
//     AppProvider appProvider, [
//     VoidCallback? onUpdate,
//   ]) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[900],
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.info, color: Colors.white),
//             title: const Text(
//               'Información de la app',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               // TODO: Abrir información de la app
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.remove_circle, color: Colors.white),
//             title: const Text(
//               'Quitar de la carpeta',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               appProvider.removeAppFromFolder(folder.id, app.packageName);
//               if (onUpdate != null)
//                 onUpdate(); // Actualizar la vista de la carpeta
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   SnackBar(
//               //     content: Text('${app.name} eliminado de la carpeta'),
//               //     duration: const Duration(seconds: 2),
//               //   ),
//               // );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.home, color: Colors.white),
//             title: const Text(
//               'Mover a pantalla principal',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               appProvider.removeAppFromFolder(folder.id, app.packageName);
//               appProvider.addToHomeScreen(app);
//               if (onUpdate != null)
//                 onUpdate(); // Actualizar la vista de la carpeta
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   SnackBar(
//               //     content: Text('${app.name} movido a la pantalla principal'),
//               //     duration: const Duration(seconds: 2),
//               //   ),
//               // );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _createFolderWithApps(
//     AppProvider appProvider,
//     AppInfo app1,
//     AppInfo app2,
//     int position,
//   ) {
//     // Crear nueva carpeta
//     final folder = FolderInfo(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: 'Nueva Carpeta',
//       apps: [app1, app2],
//     );

//     // Remover las apps de sus posiciones actuales
//     final app2Position = appProvider.getPositionOfApp(app2.packageName);
//     if (app2Position != null) {
//       appProvider.removeItemFromHomeGridPosition(app2Position);
//     }

//     // Colocar la carpeta en la posición
//     appProvider.addItemToHomeGridPosition(folder, position);

//     // Usar el método del AppProvider para agregar la carpeta
//     appProvider.addFolder(folder);
//   }

//   Widget _buildDraggableFolder(
//     Widget folderWidget,
//     FolderInfo folder,
//     int position,
//     double moduleSize,
//     AppProvider appProvider,
//   ) {
//     return LongPressDraggable<Object>(
//       data: folder,
//       delay: const Duration(milliseconds: 100),
//       feedback: Material(
//         color: Colors.transparent,
//         child: Transform.scale(
//           scale: 1.2,
//           child: Container(
//             width: moduleSize,
//             height: moduleSize,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.5),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: folderWidget,
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         width: moduleSize,
//         height: moduleSize,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//         ),
//         child: Icon(
//           Icons.folder_open,
//           color: Colors.white.withOpacity(0.5),
//           size: moduleSize * 0.3,
//         ),
//       ),
//       onDragStarted: () {
//         setState(() {
//           _isDragging = true;
//           _draggedFromPosition = position;
//         });
//         HapticFeedback.lightImpact();
//       },
//       onDragEnd: (details) {
//         setState(() {
//           _isDragging = false;
//           _draggedFromPosition = null;
//           _showDeleteMenu(
//             context,
//             position,
//             folder,
//             appProvider,
//             _itemKeys[position],
//           );
//         });
//       },
//       child: DragTarget<Object>(
//         onWillAccept: (data) {
//           if (data is AppInfo) {
//             // Para carpetas, siempre aceptar apps (para agregar a la carpeta)
//             return true;
//           } else if (data is FolderInfo) {
//             // No permitir arrastrar una carpeta sobre sí misma
//             return data.id != folder.id;
//           }
//           return false;
//         },
//         onAccept: (data) {
//           if (data is AppInfo) {
//             // Agregar app a la carpeta existente
//             final draggedPosition = appProvider.getPositionOfApp(
//               data.packageName,
//             );
//             if (draggedPosition != null) {
//               appProvider.removeItemFromHomeGridPosition(draggedPosition);
//               appProvider.addAppToFolder(folder.id, data);
//               HapticFeedback.mediumImpact();
//             }
//           } else if (data is FolderInfo) {
//             // Intercambiar posiciones de carpetas
//             final draggedPosition = appProvider.homeGridItems.entries
//                 .where(
//                   (entry) =>
//                       entry.value is FolderInfo &&
//                       (entry.value as FolderInfo).id == data.id,
//                 )
//                 .firstOrNull
//                 ?.key;

//             if (draggedPosition != null && draggedPosition != position) {
//               // Usar el método existente _swapItems en lugar del no existente swapItemsInHomeGrid
//               _swapItems(appProvider, draggedPosition, position);
//               HapticFeedback.mediumImpact();
//             }
//           }
//         },
//         builder: (context, candidateData, rejectedData) {
//           final isHovering = candidateData.isNotEmpty;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: isHovering
//                   ? Border.all(color: Colors.blue, width: 2)
//                   : null,
//             ),
//             child: folderWidget,
//           );
//         },
//       ),
//     );
//   }
  
// void _handleDelete(
//   dynamic item,
//   AppProvider appProvider,
//   BuildContext context,
// ) {
//   if (item is AppInfo) {
//     int? appPosition;
//     for (var entry in appProvider.homeGridItems.entries) {
//       if (entry.value is AppInfo &&
//           (entry.value as AppInfo).packageName == item.packageName) {
//         appPosition = entry.key;
//         break;
//       }
//     }

//     if (appPosition != null) {
//       appProvider.removeItemFromHomeGridPosition(appPosition);
//     }
//   } else if (item is FolderInfo) {
//     int? folderPosition;
//     for (var entry in appProvider.homeGridItems.entries) {
//       if (entry.value is FolderInfo &&
//           (entry.value as FolderInfo).id == item.id) {
//         folderPosition = entry.key;
//         break;
//       }
//     }

//     if (folderPosition != null) {
//       appProvider.removeItemFromHomeGridPosition(folderPosition);
//       appProvider.deleteFolder(item.id);
//     }
//   } else if (item is WidgetInfo) {
//     int? widgetPosition;
//     for (var entry in appProvider.homeGridItems.entries) {
//       if (entry.value is WidgetInfo &&
//           (entry.value as WidgetInfo).id == item.id) {
//         widgetPosition = entry.key;
//         break;
//       }
//     }

//     if (widgetPosition != null) {
//       appProvider.removeWidget(item.id);
//     }
//   }
// }

// void _showResizeDialog(
//   BuildContext context,
//   WidgetInfo widget,
//   AppProvider appProvider,
// ) {
//   int newWidth = widget.width;
//   int newHeight = widget.height;

//   showDialog(
//     context: context,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setState) => AlertDialog(
//         backgroundColor: Colors.grey[900],
//         title: Text(
//           'Cambiar tamaño de ${widget.name}',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Text('Ancho: ', style: TextStyle(color: Colors.white)),
//                 Expanded(
//                   child: Slider(
//                     value: newWidth.toDouble(),
//                     min: 1,
//                     max: 6,
//                     divisions: 5,
//                     label: newWidth.toString(),
//                     onChanged: (value) {
//                       setState(() {
//                         newWidth = value.toInt();
//                       });
//                     },
//                   ),
//                 ),
//                 Text(
//                   newWidth.toString(),
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text('Alto: ', style: TextStyle(color: Colors.white)),
//                 Expanded(
//                   child: Slider(
//                     value: newHeight.toDouble(),
//                     min: 1,
//                     max: 6,
//                     divisions: 5,
//                     label: newHeight.toString(),
//                     onChanged: (value) {
//                       setState(() {
//                         newHeight = value.toInt();
//                       });
//                     },
//                   ),
//                 ),
//                 Text(
//                   newHeight.toString(),
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancelar', style: TextStyle(color: Colors.white)),
//           ),
//           TextButton(
//             onPressed: () {
//               appProvider.updateWidgetSize(widget.id, newWidth, newHeight);
//               Navigator.pop(context);
//             },
//             child: Text('Aplicar', style: TextStyle(color: Colors.blue)),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// // Agregar función para redimensionar widgets
// void _showWidgetResizeOptions(
//   BuildContext context,
//   WidgetInfo widget,
//   AppProvider appProvider,
// ) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.grey[900],
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Redimensionar Widget',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           ...[
//             {'size': '1x1', 'width': 1, 'height': 1},
//             {'size': '2x1', 'width': 2, 'height': 1},
//             {'size': '1x2', 'width': 1, 'height': 2},
//             {'size': '2x2', 'width': 2, 'height': 2},
//             {'size': '3x2', 'width': 3, 'height': 2},
//             {'size': '4x2', 'width': 4, 'height': 2},
//           ].map(
//             (option) => ListTile(
//               leading: Icon(
//                 Icons.crop_free,
//                 color:
//                     widget.width == option['width'] &&
//                         widget.height == option['height']
//                     ? Colors.orange
//                     : Colors.white70,
//               ),
//               title: Text(
//                 option['size'] as String,
//                 style: TextStyle(
//                   color:
//                       widget.width == option['width'] &&
//                           widget.height == option['height']
//                       ? Colors.orange
//                       : Colors.white,
//                 ),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 _resizeWidget(
//                   appProvider,
//                   widget,
//                   option['width'] as int,
//                   option['height'] as int,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// void _resizeWidget(
//   AppProvider appProvider,
//   WidgetInfo widget,
//   int newWidth,
//   int newHeight,
// ) {
//   // Verificar si hay espacio suficiente
//   final currentPosition = _findWidgetPosition(appProvider, widget.id);
//   if (currentPosition == null) return;

//   // Limpiar posiciones actuales del widget
//   final currentPositions = <int>[];
//   for (var entry in appProvider.homeGridItems.entries) {
//     if (entry.value is WidgetInfo &&
//         (entry.value as WidgetInfo).id == widget.id) {
//       currentPositions.add(entry.key);
//     }
//   }

//   // Remover widget de posiciones actuales
//   for (final pos in currentPositions) {
//     appProvider.removeItemFromHomeGridPosition(pos);
//   }

//   // Verificar si el nuevo tamaño cabe en la posición actual
//   if (_canPlaceWidgetAtPosition(
//     appProvider,
//     currentPosition,
//     newWidth,
//     newHeight,
//   )) {
//     // Crear widget actualizado
//     final updatedWidget = WidgetInfo(
//       id: widget.id,
//       name: widget.name,
//       width: newWidth,
//       height: newHeight,
//       packageName: widget.packageName,
//       className: widget.className,
//     );

//     // Actualizar en el provider
//     appProvider.updateWidget(updatedWidget);

//     // Actualizar tamaño del widget nativo
//     appProvider.updateWidgetSize(widget.id, newWidth, newHeight);

//     // Colocar widget en las nuevas posiciones
//     _placeWidgetAtPosition(appProvider, updatedWidget, currentPosition);

//     setState(() {});
//   } else {
//     // Buscar nueva posición si no cabe
//     final newPosition = appProvider.findEmptyPosition(newWidth, newHeight);
//     if (newPosition != null) {
//       final updatedWidget = WidgetInfo(
//         id: widget.id,
//         name: widget.name,
//         width: newWidth,
//         height: newHeight,
//         packageName: widget.packageName,
//         className: widget.className,
//       );

//       appProvider.updateWidget(updatedWidget);
//       appProvider.updateWidgetSize(widget.id, newWidth, newHeight);
//       _placeWidgetAtPosition(appProvider, updatedWidget, newPosition);

//       setState(() {});
//     } else {
//       // Restaurar widget en posiciones originales
//       for (final pos in currentPositions) {
//         appProvider.addItemToHomeGridPosition(widget, pos);
//       }

//       // Mostrar mensaje de error
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No hay espacio suficiente para el nuevo tamaño'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }

// bool _canPlaceWidgetAtPosition(
//   AppProvider appProvider,
//   int startPosition,
//   int width,
//   int height,
// ) {
//   final gridWidth = 4; // Asumiendo grid de 4 columnas
//   final startRow = startPosition ~/ gridWidth;
//   final startCol = startPosition % gridWidth;

//   // Verificar que no se salga del grid
//   if (startCol + width > gridWidth) return false;

//   // Verificar que todas las posiciones estén libres
//   for (int row = startRow; row < startRow + height; row++) {
//     for (int col = startCol; col < startCol + width; col++) {
//       final position = row * gridWidth + col;
//       if (appProvider.homeGridItems.containsKey(position)) {
//         return false;
//       }
//     }
//   }
//   return true;
// }

// void _placeWidgetAtPosition(
//   AppProvider appProvider,
//   WidgetInfo widget,
//   int startPosition,
// ) {
//   final gridWidth = 4;
//   final startRow = startPosition ~/ gridWidth;
//   final startCol = startPosition % gridWidth;

//   for (int row = startRow; row < startRow + widget.height; row++) {
//     for (int col = startCol; col < startCol + widget.width; col++) {
//       final position = row * gridWidth + col;
//       appProvider.addItemToHomeGridPosition(widget, position);
//     }
//   }
// }

// int? _findWidgetPosition(AppProvider appProvider, String widgetId) {
//   for (var entry in appProvider.homeGridItems.entries) {
//     if (entry.value is WidgetInfo &&
//         (entry.value as WidgetInfo).id == widgetId) {
//       return entry.key;
//     }
//   }
//   return null;
// }

// }



// void _showAppSelectionDialog(
//   BuildContext context,
//   FolderInfo folder,
//   AppProvider appProvider, [
//   VoidCallback? onUpdate,
// ]) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.grey[900],
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => StatefulBuilder(
//       builder: (context, setState) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.7,
//           minChildSize: 0.5,
//           maxChildSize: 0.95,
//           expand: false,
//           builder: (context, scrollController) => Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Seleccionar aplicaciones",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: appProvider.installedApps.length,
//                   itemBuilder: (context, index) {
//                     final app = appProvider.installedApps[index];
//                     // Obtener la carpeta actualizada para verificar si la app está en ella
//                     final updatedFolder = appProvider.folders.firstWhere(
//                       (f) => f.id == folder.id,
//                       orElse: () => folder,
//                     );
//                     final isInFolder = updatedFolder.apps.any(
//                       (a) => a.packageName == app.packageName,
//                     );

//                     return ListTile(
//                       leading: app.icon != null
//                           ? Image.memory(app.icon!, width: 40, height: 40)
//                           : const Icon(Icons.android, color: Colors.white),
//                       title: Text(
//                         app.name,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       trailing: Checkbox(
//                         value: isInFolder,
//                         onChanged: (value) {
//                           if (value == true && !isInFolder) {
//                             appProvider.addAppToFolder(folder.id, app);
//                             setState(() {}); // Actualizar el estado del diálogo
//                             if (onUpdate != null)
//                               onUpdate(); // Actualizar la vista de la carpeta
//                           } else if (value == false && isInFolder) {
//                             appProvider.removeAppFromFolder(
//                               folder.id,
//                               app.packageName,
//                             );
//                             setState(() {}); // Actualizar el estado del diálogo
//                             if (onUpdate != null)
//                               onUpdate(); // Actualizar la vista de la carpeta
//                           }
//                         },
//                       ),
//                       onTap: () {
//                         if (!isInFolder) {
//                           appProvider.addAppToFolder(folder.id, app);
//                         } else {
//                           appProvider.removeAppFromFolder(
//                             folder.id,
//                             app.packageName,
//                           );
//                         }
//                         setState(() {}); // Actualizar el estado del diálogo
//                         if (onUpdate != null)
//                           onUpdate(); // Actualizar la vista de la carpeta
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }

// void _showResizeOptions(
//   BuildContext context,
//   WidgetInfo widget,
//   AppProvider appProvider,
// ) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.grey[900],
//         title: Text(
//           'Cambiar tamaño del widget',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Tamaño actual: ${widget.width}x${widget.height}',
//               style: TextStyle(color: Colors.grey),
//             ),
//             SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildSizeOption('1x1', 1, 1, widget, appProvider, context),
//                 _buildSizeOption('2x1', 2, 1, widget, appProvider, context),
//                 _buildSizeOption('2x2', 2, 2, widget, appProvider, context),
//                 _buildSizeOption('3x2', 3, 2, widget, appProvider, context),
//                 _buildSizeOption('4x2', 4, 2, widget, appProvider, context),
//                 _buildSizeOption('4x3', 4, 3, widget, appProvider, context),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildSizeOption(
//   String label,
//   int width,
//   int height,
//   WidgetInfo widget,
//   AppProvider appProvider,
//   BuildContext context,
// ) {
//   final isCurrentSize = widget.width == width && widget.height == height;

//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: isCurrentSize ? Colors.blue : Colors.grey[700],
//       foregroundColor: Colors.white,
//     ),
//     onPressed: isCurrentSize
//         ? null
//         : () {
//             // Crear widget actualizado
//             final updatedWidget = WidgetInfo(
//               id: widget.id,
//               name: widget.name,
//               packageName: widget.packageName,
//               className: widget.className,
//               width: width,
//               height: height,
//               nativeWidgetId: widget.nativeWidgetId,
//             );

//             // Actualizar en el provider
//             appProvider.updateWidget(updatedWidget);
//             Navigator.of(context).pop();
//           },
//     child: Text(label),
//   );
// }

// void _showImprovedWidgetOptions(
//   BuildContext context,
//   WidgetInfo widget,
//   AppProvider appProvider,
// ) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.grey[900],
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             'Opciones de Widget',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         ListTile(
//           leading: const Icon(Icons.aspect_ratio, color: Colors.blue),
//           title: const Text(
//             'Cambiar tamaño',
//             style: TextStyle(color: Colors.white),
//           ),
//           onTap: () {
//             Navigator.pop(context);
//             _showImprovedResizeDialog(context, widget, appProvider);
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.delete, color: Colors.red),
//           title: const Text(
//             'Eliminar widget',
//             style: TextStyle(color: Colors.white),
//           ),
//           onTap: () {
//             Navigator.pop(context);
//             appProvider.removeWidget(widget.id);
//           },
//         ),
//         const SizedBox(height: 16),
//       ],
//     ),
//   );
// }

// void _showImprovedResizeDialog(
//   BuildContext context,
//   WidgetInfo widget,
//   AppProvider appProvider,
// ) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: Colors.grey[900],
//       title: const Text(
//         'Cambiar tamaño del widget',
//         style: TextStyle(color: Colors.white),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Tamaño actual: ${widget.width}x${widget.height}',
//             style: const TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildSizeOption('1x1', 1, 1, widget, appProvider, context),
//               _buildSizeOption('2x1', 2, 1, widget, appProvider, context),
//               _buildSizeOption('2x2', 2, 2, widget, appProvider, context),
//               _buildSizeOption('3x2', 3, 2, widget, appProvider, context),
//               _buildSizeOption('4x2', 4, 2, widget, appProvider, context),
//               _buildSizeOption('4x3', 4, 3, widget, appProvider, context),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }

// void _showRenameFolderDialog(
//   BuildContext context,
//   FolderInfo folder,
//   AppProvider appProvider,
//   StateSetter setState,
// ) {
//   final controller = TextEditingController(text: folder.name);

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: Colors.grey[900],
//       title: const Text(
//         'Renombrar carpeta',
//         style: TextStyle(color: Colors.white),
//       ),
//       content: TextField(
//         controller: controller,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           hintText: 'Nombre de la carpeta',
//           hintStyle: TextStyle(color: Colors.grey),
//           enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey),
//           ),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.blue),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
//         ),
//         TextButton(
//           onPressed: () {
//             if (controller.text.trim().isNotEmpty) {
//               folder.name = controller.text.trim();
//               appProvider.notifyListeners();
//               setState(() {});
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Guardar', style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     ),
//   );
// }

// void _showFolderAppOptions(
//   BuildContext context,
//   AppInfo app,
//   FolderInfo folder,
//   AppProvider appProvider,
// ) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (context) => Container(
//       decoration: const BoxDecoration(
//         color: Colors.black87,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.info, color: Colors.white),
//             title: const Text(
//               'App Info',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               // Implementar mostrar info de la app
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.remove_circle, color: Colors.red),
//             title: const Text(
//               'Remove from Folder',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               appProvider.removeAppFromFolder(folder.id, app.packageName);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.home, color: Colors.white),
//             title: const Text(
//               'Move to Home',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               appProvider.removeAppFromFolder(folder.id, app.packageName);
//               // Encontrar posición vacía y agregar app
//               final emptyPosition = appProvider.findEmptyPosition(
//                 1,
//                 1,
//               ); // Apps ocupan 1x1
//               if (emptyPosition != null) {
//                 appProvider.addItemToHomeGridPosition(app, emptyPosition);
//               }
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

// void _openFolderImproved(
//   BuildContext context,
//   FolderInfo folder,
//   AppProvider appProvider,
// ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.grey[900],
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => StatefulBuilder(
//       builder: (context, setState) {
//         final updatedFolder = appProvider.folders.firstWhere(
//           (f) => f.id == folder.id,
//           orElse: () => folder,
//         );

//         return DraggableScrollableSheet(
//           initialChildSize: 0.7,
//           minChildSize: 0.5,
//           maxChildSize: 0.95,
//           expand: false,
//           builder: (context, scrollController) => Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         updatedFolder.name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.white),
//                           onPressed: () => _showRenameFolderDialog(
//                             context,
//                             updatedFolder,
//                             appProvider,
//                             setState,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.add, color: Colors.white),
//                           onPressed: () {
//                             _showAppSelectionDialog(
//                               context,
//                               updatedFolder,
//                               appProvider,
//                               () {
//                                 setState(() {});
//                               },
//                             );
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: updatedFolder.apps.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'Carpeta vacía\nArrasta aplicaciones aquí',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.grey, fontSize: 16),
//                         ),
//                       )
//                     : GridView.builder(
//                         controller: scrollController,
//                         padding: const EdgeInsets.all(16),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: updatedFolder.columns,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           childAspectRatio: 0.8,
//                         ),
//                         itemCount: updatedFolder.apps.length,
//                         itemBuilder: (context, index) {
//                           final app = updatedFolder.apps[index];
//                           return AppIcon(
//                             app: app,
//                             onTap: () {
//                               Navigator.pop(context);
//                               appProvider.launchApp(app.packageName);
//                             },
//                             onLongPress: () => _showFolderAppOptions(
//                               context,
//                               app,
//                               updatedFolder,
//                               appProvider,
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }

