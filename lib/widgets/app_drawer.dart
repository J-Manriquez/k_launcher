import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k_launcher/screens/settings_general_screen.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'app_icon.dart';
import 'search_bar.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const AppDrawer({super.key, required this.onClose});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  bool _isSearchVisible = false;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  void _showAppOptions(BuildContext context, AppInfo app, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Colors.white),
              title: const Text('Añadir a inicio', style: TextStyle(color: Colors.white)),
              onTap: () {
                widget.onClose();
    
    // Agregar app a home screen en la primera posición disponible
    appProvider.addToHomeScreen(app);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('Información de la app', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Abrir configuración de Android para la app
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Desinstalar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Desinstalar aplicación
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        // Registrar posición inicial
      },
      onVerticalDragUpdate: (details) {
        // Mejorar la detección del gesto hacia abajo
        if (details.delta.dy > 3) {
          // Solo cerrar si el gesto es consistente hacia abajo
          final velocity = details.primaryDelta ?? 0;
          if (velocity > 5) {
            widget.onClose();
          }
        }
      },
      onVerticalDragEnd: (details) {
        // Detectar velocidad del gesto para cerrar más rápido
        if (details.primaryVelocity != null && 
            details.primaryVelocity! > 500) {
          widget.onClose();
        }
      },
      // Prevenir conflictos con scroll interno
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Consumer2<AppProvider, SettingsProvider>(
          builder: (context, appProvider, settingsProvider, child) {
    // Establecer la referencia
    appProvider.setSettingsProvider(settingsProvider);
            final appsPerPage = settingsProvider.drawerGridColumns * settingsProvider.drawerGridRows;
            final totalPages = (appProvider.filteredApps.length / appsPerPage).ceil();

            return Column(
              children: [
                // Handle del drawer
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Barra superior modificada
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón de búsqueda
                      IconButton(
                        onPressed: _toggleSearch,
                        icon: Icon(
                          _isSearchVisible ? Icons.close : Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      // Título
                      if (!_isSearchVisible)
                        const Text(
                          'Aplicaciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      // Spacer para centrar el título
                      if (!_isSearchVisible) const Spacer(),

                      // Botón de configuración
                      if (!_isSearchVisible)
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                      // Botón cerrar
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Barra de búsqueda
                AnimatedBuilder(
                  animation: _searchAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _searchAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SearchBar(
                          onChanged: (query) {
                            appProvider.filterApps(query);
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Grid de aplicaciones
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: totalPages,
                    itemBuilder: (context, pageIndex) {
                      final startIndex = pageIndex * appsPerPage;
                      final endIndex = (startIndex + appsPerPage).clamp(0, appProvider.filteredApps.length);
                      final pageApps = appProvider.filteredApps.sublist(startIndex, endIndex);

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: settingsProvider.drawerGridColumns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: pageApps.length,
                          itemBuilder: (context, index) {
                            final app = pageApps[index];
                            return _buildAppItem(app, appProvider);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppItem(AppInfo app, AppProvider appProvider) {
    return GestureDetector(
      onTap: () {
        // Click simple: abrir aplicación
        appProvider.launchApp(app.packageName);
      },
      onLongPressStart: (details) {
        // Iniciar timer para detectar el tipo de long press
        _handleLongPress(app, details.globalPosition, appProvider);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: app.icon != null
                    ? Image.memory(
                        app.icon!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.android,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          ),
          if (context.watch<SettingsProvider>().showAppNamesDrawer)
            Expanded(
              flex: 1,
              child: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Container(
                    height: settings.drawerAppNameTextSize * 2.5, // Espacio para 2 líneas
                    alignment: Alignment.center,
                    child: Text(
                      app.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: settings.drawerAppNameTextSize,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _handleLongPress(AppInfo app, Offset globalPosition, AppProvider appProvider) {
    // Implementar lógica para detectar si es drag o long press estático
    bool hasMoved = false;
    Offset initialPosition = globalPosition;
    
    // Timer para long press estático (1.3 segundos)
    Timer? longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (!hasMoved) {
        _showAppOptions(context, app, appProvider);
      }
    });
  }
  
}
