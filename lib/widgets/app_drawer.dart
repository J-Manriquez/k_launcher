import 'package:flutter/material.dart';
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
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Consumer2<AppProvider, SettingsProvider>(
        builder: (context, appProvider, settings, child) {
          final appsPerPage = settings.gridColumns * settings.gridRows;
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
              
              // Barra superior
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
                    
                    // Indicadores de página
                    if (!_isSearchVisible && totalPages > 1)
                      Row(
                        children: List.generate(
                          totalPages,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    
                    // Botón cerrar
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Barra de búsqueda animada
              AnimatedBuilder(
                animation: _searchAnimation,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _searchAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomSearchBar(
                        onSearch: (query) {
                          appProvider.filterApps(query);
                        },
                      ),
                    ),
                  );
                },
              ),
              
              // Grid de aplicaciones
              Expanded(
                child: appProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : PageView.builder(
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
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: settings.gridColumns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: pageApps.length,
                              itemBuilder: (context, index) {
                                final app = pageApps[index];
                                return AppIcon(
                                  app: app,
                                  onTap: () {
                                    appProvider.launchApp(app.packageName);
                                    widget.onClose();
                                  },
                                  onLongPress: () {
                                    _showAppOptions(context, app);
                                  },
                                );
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
    );
  }

  void _showAppOptions(BuildContext context, AppInfo app) {
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
              context.read<AppProvider>().isFavorite(app.packageName)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.white,
            ),
            title: Text(
              context.read<AppProvider>().isFavorite(app.packageName)
                  ? 'Quitar de favoritos'
                  : 'Añadir a favoritos',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              if (context.read<AppProvider>().isFavorite(app.packageName)) {
                context.read<AppProvider>().removeFromFavorites(app.packageName);
              } else {
                context.read<AppProvider>().addToFavorites(app);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_to_home_screen, color: Colors.white),
            title: const Text('Añadir a pantalla principal', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Añadir a pantalla principal
            },
          ),
        ],
      ),
    );
  }
}