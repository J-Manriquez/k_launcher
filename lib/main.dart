import 'package:flutter/material.dart';
import 'package:k_launcher/providers/app_provider.dart';
import 'package:k_launcher/providers/settings_provider.dart';
import 'package:k_launcher/screens/home_screen.dart';
import 'package:k_launcher/services/launcher_service.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/permission_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await PermissionService.initialize();
  await LauncherService.initialize();
  
  runApp(const KLauncherApp());
}

class KLauncherApp extends StatelessWidget {
  const KLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'K Launcher',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const PermissionCheckScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({super.key});

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  bool _isCheckingPermissions = true;
  List<String> _missingPermissions = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final missing = await PermissionService.checkAllPermissions();
    setState(() {
      _missingPermissions = missing;
      _isCheckingPermissions = false;
    });
    
    if (missing.isEmpty) {
      _navigateToHome();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isCheckingPermissions = true);
    
    final granted = await PermissionService.requestAllPermissions();
    
    if (granted) {
      _navigateToHome();
    } else {
      await _checkPermissions();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rocket_launch,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'K Launcher',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Launcher personalizado para Android',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (_isCheckingPermissions)
                  const CircularProgressIndicator(color: Colors.white)
                else if (_missingPermissions.isNotEmpty) ...
                  [
                    const Text(
                      'Permisos requeridos:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _missingPermissions
                            .map((permission) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, 
                                          color: Colors.orange, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          permission,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Conceder Permisos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
