import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:k_launcher/models/app_info.dart';
import 'package:k_launcher/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/launcher_service.dart';
import '../widgets/home_grid.dart';
import '../widgets/wallpaper_selector.dart';
import '../widgets/app_drawer.dart';
import 'settings_general_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerAnimation;
  late PageController _homePageController;
  bool _isDrawerOpen = false;
  int _currentHomePage = 0;

  @override
  void initState() {
    super.initState();
    _homePageController = PageController();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Cargar aplicaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadInstalledApps();
    });
  }

  @override
  void dispose() {
    _homePageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AppProvider, SettingsProvider>(
        builder: (context, appProvider, settingsProvider, child) {
          // Establecer la referencia
          appProvider.setSettingsProvider(settingsProvider);
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
                  if (details.delta.dy < -5 && !_isDrawerOpen) {
                    _openDrawer();
                  }
                },
                child: Column(
                  children: [
                    // Grid principal - usar solo HomeGrid
                    Expanded(
                      child: HomeGrid(
                        onAppTap: (app) =>
                            appProvider.launchApp(app.packageName),
                        onAppLongPress: (app) =>
                            _showHomeAppOptions(context, app),
                      ),
                    ),
                  ],
                ),
              ),

              // App Drawer
              if (_isDrawerOpen)
                AnimatedBuilder(
                  animation: _drawerAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(_drawerAnimation),
                      child: AppDrawer(onClose: _closeDrawer),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  // void _showWallpaperSelector() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const WallpaperSelector(),
  //   );
  // }

  // void _showSettings() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const SettingsScreen()),
  //   );
  // }

  void _showHomeAppOptions(BuildContext context, AppInfo app) {
    // TODO: Implement home screen app options (move, remove, create folder)
  }
}
