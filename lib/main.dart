import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const BuildingManagerApp());
}

Future<void> _initializeServices() async {
  // Initialize Dio client
  final dio = Dio();
  
  // Configure Dio for development (update base URL for testing)
  dio.options.baseUrl = 'http://10.10.0.203:8000/api/v1';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Add request/response interceptors for logging (development only)
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
  }
  
  // Initialize auth service
  AuthService.instance.initialize(dio);
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
        homeBuilder: (context, user, building) => HomeScreen(
          user: user,
          building: building,
        ),
      ),
    );
  }
}
