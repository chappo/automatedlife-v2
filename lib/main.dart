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
  // Initialize SharedPreferences service
  await PreferencesService.instance.initialize();
  
  // Initialize API client with development URL
  ApiClient.instance.initialize(
    baseUrl: 'http://10.10.0.203:8000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    enableLogging: true, // Enable logging for development
    maxRetries: 3,
  );
}

class BuildingManagerApp extends StatefulWidget {
  const BuildingManagerApp({super.key});

  @override
  State<BuildingManagerApp> createState() => _BuildingManagerAppState();
}

class _BuildingManagerAppState extends State<BuildingManagerApp> {
  bool _darkModeEnabled = false;
  double _textSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    
    // Listen for preference changes
    PreferencesService.instance.preferencesNotifier.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    PreferencesService.instance.preferencesNotifier.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (!mounted) return;
    
    final preferences = PreferencesService.instance.preferencesNotifier.value;
    debugPrint('Main App: Preferences changed: $preferences');
    setState(() {
      _darkModeEnabled = preferences['dark_mode_enabled'] ?? false;
      _textSize = preferences['text_size'] ?? 1.0;
      debugPrint('Main App: Updated theme state - darkMode: $_darkModeEnabled, textSize: $_textSize');
    });
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await PreferencesService.instance.getAllPreferences();
      setState(() {
        _darkModeEnabled = preferences['dark_mode_enabled'] ?? false;
        _textSize = preferences['text_size'] ?? 1.0;
      });
      
      // Initialize the notifier with loaded preferences
      PreferencesService.instance.preferencesNotifier.value = preferences;
    } catch (e) {
      // Use defaults on error
      setState(() {
        _darkModeEnabled = false;
        _textSize = 1.0;
      });
    }
  }

  ThemeData _buildTheme(ThemeData baseTheme) {
    if (_textSize == 1.0) {
      debugPrint('Main App: Using base theme (textSize = 1.0)');
      return baseTheme;
    }
    
    debugPrint('Main App: Building scaled theme with textSize = $_textSize');
    
    // Safely apply text scaling by ensuring we don't modify null fontSize styles
    final textTheme = baseTheme.textTheme;
    final scaledTextTheme = TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: (textTheme.displayLarge?.fontSize ?? 57) * _textSize,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontSize: (textTheme.displayMedium?.fontSize ?? 45) * _textSize,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: (textTheme.displaySmall?.fontSize ?? 36) * _textSize,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * _textSize,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * _textSize,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * _textSize,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: (textTheme.titleLarge?.fontSize ?? 22) * _textSize,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: (textTheme.titleMedium?.fontSize ?? 16) * _textSize,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: (textTheme.titleSmall?.fontSize ?? 14) * _textSize,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * _textSize,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * _textSize,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: (textTheme.bodySmall?.fontSize ?? 12) * _textSize,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: (textTheme.labelLarge?.fontSize ?? 14) * _textSize,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: (textTheme.labelMedium?.fontSize ?? 12) * _textSize,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: (textTheme.labelSmall?.fontSize ?? 11) * _textSize,
      ),
    );
    
    return baseTheme.copyWith(textTheme: scaledTextTheme);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = _darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    debugPrint('Main App: Building MaterialApp with themeMode: $themeMode, darkMode: $_darkModeEnabled, textSize: $_textSize');
    
    return MaterialApp(
      title: 'Building Manager',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(NWAppTheme.lightTheme),
      darkTheme: _buildTheme(NWAppTheme.darkTheme),
      themeMode: themeMode,
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
