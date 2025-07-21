import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../navigation/navigation_provider.dart';
import '../shells/shells.dart';
import '../screens/settings_screen.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      return _handleRedirect(ref, state);
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _buildShell(context, ref, state, child);
        },
        routes: [
          // Dashboard routes
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Dashboard - Coming Soon')),
            ),
          ),
          
          // Defects routes
          GoRoute(
            path: '/defects',
            name: 'defects',
            builder: (context, state) => const DefectsListPage(),
            routes: [
              GoRoute(
                path: '/new',
                name: 'defects-new',
                builder: (context, state) => const NewDefectPage(),
              ),
              GoRoute(
                path: '/:id',
                name: 'defects-detail',
                builder: (context, state) {
                  final defectId = state.pathParameters['id']!;
                  return DefectDetailPage(defectId: defectId);
                },
              ),
            ],
          ),
          
          // Documents routes
          GoRoute(
            path: '/documents',
            name: 'documents',
            builder: (context, state) => const DocumentsPage(),
            routes: [
              GoRoute(
                path: '/:id',
                name: 'document-detail',
                builder: (context, state) {
                  final documentId = state.pathParameters['id']!;
                  return DocumentDetailPage(documentId: documentId);
                },
              ),
            ],
          ),
          
          // Messaging routes
          GoRoute(
            path: '/messaging',
            name: 'messaging',
            builder: (context, state) => const MessagingPage(),
            routes: [
              GoRoute(
                path: '/compose',
                name: 'messaging-compose',
                builder: (context, state) => const ComposeMessagePage(),
              ),
              GoRoute(
                path: '/:id',
                name: 'message-detail',
                builder: (context, state) {
                  final messageId = state.pathParameters['id']!;
                  return MessageDetailPage(messageId: messageId);
                },
              ),
            ],
          ),
          
          // Intercom routes
          GoRoute(
            path: '/intercom',
            name: 'intercom',
            builder: (context, state) => const IntercomPage(),
          ),
          
          // Calendar/Booking routes
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarPage(),
            routes: [
              GoRoute(
                path: '/book',
                name: 'calendar-book',
                builder: (context, state) => const BookAmenityPage(),
              ),
            ],
          ),
          
          
          // Settings routes
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          
          // Contact/Support routes
          GoRoute(
            path: '/contact',
            name: 'contact',
            builder: (context, state) => const ContactPage(),
          ),
          
          // Admin specific routes
          GoRoute(
            path: '/admin',
            name: 'admin',
            routes: [
              GoRoute(
                path: '/audit-log',
                name: 'admin-audit-log',
                builder: (context, state) => const AuditLogPage(),
              ),
              GoRoute(
                path: '/system-status',
                name: 'admin-system-status',
                builder: (context, state) => const SystemStatusPage(),
              ),
            ],
          ),
        ],
      ),
      
      // Auth routes (outside shell)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

/// Handle route redirects based on user role and capabilities
String? _handleRedirect(ProviderRef ref, GoRouterState state) {
  final navigationState = ref.read(navigationProvider);
  final location = state.matchedLocation;
  
  // Check if user has access to the requested route
  if (!_canAccessRoute(location, navigationState)) {
    // Redirect to appropriate default route based on role
    switch (navigationState.userRole) {
      case UserRole.admin:
        return '/dashboard';
      case UserRole.buildingManager:
        return '/dashboard';
      case UserRole.resident:
        return '/dashboard';
      case UserRole.defectUser:
        return '/defects';
      case UserRole.staff:
        return '/dashboard';
    }
  }
  
  return null; // No redirect needed
}

/// Check if user can access the given route
bool _canAccessRoute(String route, NavigationState navigationState) {
  final userRole = navigationState.userRole;
  final capabilities = navigationState.availableCapabilities;
  
  // All routes are now capability-based, no admin system routes bypass
  
  // Define route access rules for building capabilities
  final routeRules = <String, List<String>>{
    '/dashboard': [], // Available to all
    '/defects': ['defects'],
    '/documents': ['documents'],
    '/messaging': ['messaging'],
    '/intercom': ['intercom'],
    '/calendar': ['calendar_booking'],
    '/settings': [], // Available to all
    '/contact': [], // Available to all
  };
  
  // All routes now use capability-based access control
  
  // Check if route requires specific capabilities
  for (final ruleRoute in routeRules.keys) {
    if (route.startsWith(ruleRoute)) {
      final requiredCapabilities = routeRules[ruleRoute]!;
      
      // If no capabilities required, allow access
      if (requiredCapabilities.isEmpty) return true;
      
      // Check if user has required capabilities
      return requiredCapabilities.every((cap) => capabilities.contains(cap));
    }
  }
  
  // Special case for defect users - only allow defect routes
  if (userRole == UserRole.defectUser) {
    return route.startsWith('/defects') || 
           route.startsWith('/dashboard') || 
           route.startsWith('/settings');
  }
  
  return true; // Allow access by default
}


/// Build the appropriate shell based on user role
Widget _buildShell(BuildContext context, ProviderRef ref, GoRouterState state, Widget child) {
  final navigationState = ref.watch(navigationProvider);
  final currentRoute = state.matchedLocation;
  
  // Update current route in navigation state
  ref.read(navigationProvider.notifier).setCurrentRoute(currentRoute);
  
  switch (navigationState.userRole) {
    case UserRole.admin:
      return ResidentShell( // Admin users now use resident shell, admin features handled within capabilities
        currentRoute: currentRoute,
        child: child,
      );
    case UserRole.buildingManager:
      return ResidentShell( // Building managers use resident shell, admin features handled within capabilities
        currentRoute: currentRoute,
        child: child,
      );
    case UserRole.resident:
      return ResidentShell(
        currentRoute: currentRoute,
        child: child,
      );
    case UserRole.defectUser:
      return DefectUserShell(
        currentRoute: currentRoute,
        child: child,
      );
    case UserRole.staff:
      return ResidentShell( // Staff use resident shell with limited capabilities
        currentRoute: currentRoute,
        child: child,
      );
  }
}

/// Stream wrapper for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(ProviderRef ref) {
    notifyListeners();
    _subscription = ref.listen(navigationProvider, (previous, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<NavigationState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

// Placeholder pages - these would be implemented in the main app
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Dashboard'));
}

class DefectsListPage extends StatelessWidget {
  const DefectsListPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Defects List'));
}

class NewDefectPage extends StatelessWidget {
  const NewDefectPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('New Defect'));
}

class DefectDetailPage extends StatelessWidget {
  final String defectId;
  const DefectDetailPage({super.key, required this.defectId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Defect $defectId'));
}

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Documents'));
}

class DocumentDetailPage extends StatelessWidget {
  final String documentId;
  const DocumentDetailPage({super.key, required this.documentId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Document $documentId'));
}

class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Messaging'));
}

class ComposeMessagePage extends StatelessWidget {
  const ComposeMessagePage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Compose Message'));
}

class MessageDetailPage extends StatelessWidget {
  final String messageId;
  const MessageDetailPage({super.key, required this.messageId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Message $messageId'));
}

class IntercomPage extends StatelessWidget {
  const IntercomPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Intercom'));
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Calendar'));
}

class BookAmenityPage extends StatelessWidget {
  const BookAmenityPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Book Amenity'));
}



class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Contact'));
}

class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Audit Log'));
}

class SystemStatusPage extends StatelessWidget {
  const SystemStatusPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('System Status'));
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login')));
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Register')));
}

class ErrorPage extends StatelessWidget {
  final Exception? error;
  const ErrorPage({super.key, this.error});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Error: $error')));
}