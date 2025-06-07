import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder_info.dart';
import '../models/app_info.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';

class FolderWidget extends StatelessWidget {
  final FolderInfo folder;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const FolderWidget({
    super.key,
    required this.folder,
    required this.size,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return GestureDetector(
          onTap: onTap ?? () => _openFolder(context),
          onLongPress: onLongPress,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: folder.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildFolderPreview(settings),
                ),
              ),
              if (settings.showFolderNames)
                Expanded(
                  flex: 1,
                  child: Text(
                    folder.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: settings.folderNameTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFolderPreview(SettingsProvider settings) {
    final previewApps = folder.apps.take(4).toList();
    
    if (previewApps.isEmpty) {
      return const Icon(
        Icons.folder,
        color: Colors.white70,
        size: 32,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index < previewApps.length) {
            final app = previewApps[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: app.icon != null
                  ? Image.memory(
                      app.icon!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[600],
                      child: const Icon(
                        Icons.android,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }
        },
      ),
    );
  }
  
  void _openFolder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FolderContentSheet(folder: folder),
    );
  }
}

class FolderContentSheet extends StatelessWidget {
  final FolderInfo folder;
  
  const FolderContentSheet({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AppProvider>(
      builder: (context, settings, appProvider, child) {
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
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        folder.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Apps grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: folder.columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: folder.apps.length,
                    itemBuilder: (context, index) {
                      final app = folder.apps[index];
                      return _buildFolderAppItem(context, app, appProvider, settings);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFolderAppItem(BuildContext context, AppInfo app, AppProvider appProvider, SettingsProvider settings) {
    return GestureDetector(
      onTap: () {
        appProvider.launchApp(app.packageName);
        Navigator.pop(context);
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
                        child: Icon(
                          Icons.android,
                          size: settings.folderIconSize * 0.6,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          ),
          if (settings.showAppNamesInFolders)
            Expanded(
              flex: 1,
              child: Text(
                app.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: settings.folderIconSize * 0.2,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}