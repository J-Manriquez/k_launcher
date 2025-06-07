import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/wallpaper_service.dart';

class WallpaperSelector extends StatefulWidget {
  const WallpaperSelector({super.key});

  @override
  State<WallpaperSelector> createState() => _WallpaperSelectorState();
}

class _WallpaperSelectorState extends State<WallpaperSelector> {
  List<String> _galleryImages = [];
  List<String> _defaultWallpapers = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }
  
  Future<void> _loadWallpapers() async {
    try {
      final gallery = await WallpaperService.getGalleryImages();
      final defaults = await WallpaperService.getDefaultWallpapers();
      
      setState(() {
        _galleryImages = gallery;
        _defaultWallpapers = defaults;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _setWallpaper(String imagePath) async {
    try {
      await context.read<AppProvider>().setWallpaper(imagePath);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fondo de pantalla cambiado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cambiando fondo: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Seleccionar Fondo de Pantalla',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Galería'),
                            Tab(text: 'Por defecto'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildGalleryTab(),
                              _buildDefaultTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGalleryTab() {
    if (_galleryImages.isEmpty) {
      return const Center(
        child: Text('No se encontraron imágenes en la galería'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _galleryImages.length,
      itemBuilder: (context, index) {
        final imagePath = _galleryImages[index];
        return GestureDetector(
          onTap: () => _setWallpaper(imagePath),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDefaultTab() {
    if (_defaultWallpapers.isEmpty) {
      return const Center(
        child: Text('No se encontraron fondos por defecto'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _defaultWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaperPath = _defaultWallpapers[index];
        return GestureDetector(
          onTap: () => _setWallpaper(wallpaperPath),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                wallpaperPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}