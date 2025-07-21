import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import 'package:app_shell/app_shell.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const ProviderScope(child: BuildingManagerApp()));
}

Future<void> _initializeServices() async {
  // Initialize API client with development URL
  ApiClient.instance.initialize(
    baseUrl: 'http://10.10.0.203:8000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    enableLogging: true, // Enable logging for development
    maxRetries: 3,
  );
}

class BuildingManagerApp extends StatelessWidget {
  const BuildingManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Building Manager',
      debugShowCheckedModeBanner: false,
      theme: NWAppTheme.lightTheme,
      darkTheme: NWAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        homeBuilder: (context, user, building, buildings) => AppShell(
          user: user,
          currentBuilding: building,
          availableBuildings: buildings,
        ),
      ),
    );
  }
}
