import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/launcher_service.dart';
import '../widgets/home_grid.dart';
import '../widgets/dock.dart';
import '../widgets/wallpaper_selector.dart';
import '../widgets/app_drawer.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;
  
  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Cargar aplicaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadInstalledApps();
    });
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    setState(() {
      _isDrawerOpen = true;
    });
    _drawerAnimationController.forward();
  }

  void _closeDrawer() {
    _drawerAnimationController.reverse().then((_) {
      setState(() {
        _isDrawerOpen = false;
      });
    });
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Detectar deslizamiento hacia arriba
                  if (details.delta.dy < -5 && !_isDrawerOpen) {
                    _openDrawer();
                  }
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      // Barra superior
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Indicador de tiempo
                            StreamBuilder(
                              stream: Stream.periodic(const Duration(minutes: 1)),
                              builder: (context, snapshot) {
                                final now = DateTime.now();
                                return Text(
                                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
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
                      
                      // Área principal con widgets/aplicaciones favoritas
                      const Expanded(
                        child: HomeGrid(),
                      ),
                      
                      // Indicador para deslizar hacia arriba
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                            Text(
                              'Desliza hacia arriba',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Dock inferior
                      const Dock(),
                    ],
                  ),
                ),
              ),
              
              // Cajón de aplicaciones
              if (_isDrawerOpen)
                GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              
              if (_isDrawerOpen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_drawerAnimation),
                    child: AppDrawer(onClose: _closeDrawer),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}