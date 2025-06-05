import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/launcher_service.dart';
import '../widgets/app_grid.dart';
import '../widgets/search_bar.dart';
import '../widgets/dock.dart';
import '../widgets/wallpaper_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  bool _isSearchVisible = false;
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
    
    // Cargar aplicaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadInstalledApps();
    });
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

  void _showWallpaperSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WallpaperSelector(),
    );
  }

  void _showSettings() {
    // TODO: Implementar pantalla de configuración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración - Próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Stack(
            children: [
              // Fondo de pantalla
              Container(
                decoration: BoxDecoration(
                  image: appProvider.currentWallpaper != null
                      ? DecorationImage(
                          image: FileImage(appProvider.currentWallpaper!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: appProvider.currentWallpaper == null
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue, Colors.purple],
                        )
                      : null,
                ),
              ),
              
              // Contenido principal
              SafeArea(
                child: Column(
                  children: [
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
                          
                          // Indicadores de página
                          if (!_isSearchVisible)
                            Row(
                              children: List.generate(
                                (appProvider.installedApps.length / 20).ceil(),
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Menú de opciones
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'wallpaper':
                                  _showWallpaperSelector();
                                  break;
                                case 'settings':
                                  _showSettings();
                                  break;
                                case 'widgets':
                                  // TODO: Implementar gestión de widgets
                                  break;
                              }
                            },
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'wallpaper',
                                child: Row(
                                  children: [
                                    Icon(Icons.wallpaper),
                                    SizedBox(width: 8),
                                    Text('Cambiar fondo'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'widgets',
                                child: Row(
                                  children: [
                                    Icon(Icons.widgets),
                                    SizedBox(width: 8),
                                    Text('Widgets'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 8),
                                    Text('Configuración'),
                                  ],
                                ),
                              ),
                            ],
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
                              itemCount: (appProvider.filteredApps.length / 20).ceil(),
                              itemBuilder: (context, pageIndex) {
                                final startIndex = pageIndex * 20;
                                final endIndex = (startIndex + 20).clamp(0, appProvider.filteredApps.length);
                                final pageApps = appProvider.filteredApps.sublist(startIndex, endIndex);
                                
                                return AppGrid(apps: pageApps);
                              },
                            ),
                    ),
                    
                    // Dock inferior
                    const Dock(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}