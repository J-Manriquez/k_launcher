import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/launcher_service.dart';
import 'home_settings_screen.dart';
import 'drawer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDefaultLauncher = false;
  bool _isCheckingLauncher = false;

  @override
  void initState() {
    super.initState();
    _checkDefaultLauncher();
  }

  Future<void> _checkDefaultLauncher() async {
    setState(() {
      _isCheckingLauncher = true;
    });
    
    try {
      final isDefault = await LauncherService.isDefaultLauncher();
      setState(() {
        _isDefaultLauncher = isDefault;
      });
    } catch (e) {
      print('Error verificando launcher por defecto: $e');
    } finally {
      setState(() {
        _isCheckingLauncher = false;
      });
    }
  }

  Future<void> _setAsDefaultLauncher() async {
    try {
      await LauncherService.setAsDefaultLauncher();
      await Future.delayed(const Duration(seconds: 1));
      await _checkDefaultLauncher();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error configurando launcher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Configuración de Launcher por Defecto
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.white),
                      title: const Text(
                        'Launcher por Defecto',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _isDefaultLauncher 
                            ? 'K Launcher está configurado como launcher por defecto'
                            : 'K Launcher no es el launcher por defecto',
                        style: TextStyle(
                          color: _isDefaultLauncher ? Colors.green : Colors.orange,
                        ),
                      ),
                      trailing: _isCheckingLauncher
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isDefaultLauncher ? Icons.check_circle : Icons.warning,
                              color: _isDefaultLauncher ? Colors.green : Colors.orange,
                            ),
                    ),
                    if (!_isDefaultLauncher)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _setAsDefaultLauncher,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Configurar como Launcher por Defecto'),
                        ),
                      ),
                    if (_isDefaultLauncher)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _checkDefaultLauncher,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Verificar Estado'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await LauncherService.resetDefaultLauncher();
                                  await Future.delayed(const Duration(seconds: 1));
                                  await _checkDefaultLauncher();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Cambiar Launcher'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configuración del Grid Principal (simplificada)
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Grid Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Modo Edición', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Permite mover y reorganizar aplicaciones en el grid principal', style: TextStyle(color: Colors.grey)),
                      value: settings.homeGridEditMode,
                      onChanged: (value) {
                        settings.setHomeGridEditMode(value);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Navegación a configuraciones específicas
              Card(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.white),
                      title: const Text('Configuración Pantalla Principal', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Grid, apariencia y comportamiento', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                      leading: const Icon(Icons.apps, color: Colors.white),
                      title: const Text('Configuración Cajón de Aplicaciones', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Grid, apariencia y comportamiento', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrawerSettingsScreen(),
                          ),
                        );
                      },
                    ),
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