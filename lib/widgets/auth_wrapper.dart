import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/building_selection_screen.dart';

/// Auth wrapper that manages authentication state and navigation
/// 
/// Listens to authentication state changes and navigates between
/// splash, login, building selection, and main app screens based
/// on the current authentication state.
class AuthWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, User user, Building building, List<Building> buildings) homeBuilder;

  const AuthWrapper({
    super.key,
    required this.homeBuilder,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService.instance;
  AuthState _authState = AuthState.unknown;
  User? _currentUser;
  Building? _selectedBuilding;
  List<Building>? _userBuildings;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _setupAuthListeners();
  }

  @override
  void dispose() {
    // Don't dispose the auth service here since it's a singleton
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check current authentication state
      final authState = await _authService.getAuthState();
      final user = await _authService.getCurrentUser();
      final selectedBuilding = await _authService.getSelectedBuilding();
      final buildings = await _authService.getBuildings();

      setState(() {
        _authState = authState;
        _currentUser = user;
        _selectedBuilding = selectedBuilding;
        _userBuildings = buildings;
        _isInitializing = false;
      });

      // Validate token if authenticated
      if (authState == AuthState.authenticated && user != null) {
        final isValid = await _authService.validateToken();
        if (!isValid) {
          // Token is invalid, logout user
          await _authService.logout();
        }
      }
    } catch (e) {
      // If there's an error during initialization, assume unauthenticated
      setState(() {
        _authState = AuthState.unauthenticated;
        _currentUser = null;
        _selectedBuilding = null;
        _userBuildings = null;
        _isInitializing = false;
      });
    }
  }

  void _setupAuthListeners() {
    // Listen to auth state changes
    _authService.authStateStream.listen((authState) {
      if (mounted) {
        setState(() {
          _authState = authState;
        });
      }
    });

    // Listen to user changes
    _authService.userStream.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });

    // Listen to selected building changes
    _authService.selectedBuildingStream.listen((building) {
      if (mounted) {
        setState(() {
          _selectedBuilding = building;
        });
        _loadUserBuildings();
      }
    });
  }

  Future<void> _loadUserBuildings() async {
    try {
      final buildings = await _authService.getBuildings();
      if (mounted) {
        setState(() {
          _userBuildings = buildings;
        });
      }
    } catch (e) {
      // Handle error loading buildings
      debugPrint('Error loading user buildings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while initializing
    if (_isInitializing) {
      return const SplashScreen();
    }

    // Show appropriate screen based on auth state
    switch (_authState) {
      case AuthState.unauthenticated:
        return const LoginScreen();

      case AuthState.authenticated:
        // Check if user has selected a building
        if (_currentUser == null) {
          // This shouldn't happen, but handle gracefully
          return const LoginScreen();
        }

        // If user has multiple buildings but none selected, show building selection
        if (_userBuildings != null && 
            _userBuildings!.length > 1 && 
            _selectedBuilding == null) {
          return BuildingSelectionScreen(
            buildings: _userBuildings!,
            user: _currentUser!,
          );
        }

        // If user has only one building, auto-select it
        if (_userBuildings != null && 
            _userBuildings!.length == 1 && 
            _selectedBuilding == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _authService.selectBuilding(_userBuildings!.first);
          });
          return const SplashScreen();
        }

        // If user and building are selected, show main app
        if (_selectedBuilding != null && _userBuildings != null) {
          return widget.homeBuilder(context, _currentUser!, _selectedBuilding!, _userBuildings!);
        }

        // Fallback: show building selection or splash
        if (_userBuildings != null && _userBuildings!.isNotEmpty) {
          return BuildingSelectionScreen(
            buildings: _userBuildings!,
            user: _currentUser!,
          );
        }

        // If no buildings available, show error state
        return _NoAccessScreen(user: _currentUser!);

      case AuthState.unknown:
      default:
        return const SplashScreen();
    }
  }
}

/// Screen shown when user has no building access
class _NoAccessScreen extends StatelessWidget {
  final User user;

  const _NoAccessScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('No Access'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.logout();
            },
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.no_accounts_outlined,
                  size: 80,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'No Building Access',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Hello ${user.displayName},\n\nYou don\'t currently have access to any buildings. Please contact your building administrator to request access.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.instance.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}