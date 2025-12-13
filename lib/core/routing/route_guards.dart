import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_routes.dart';
import '../../data/providers/auth_provider.dart';
import '../services/logger_service.dart';

// Route guard utilities for handling authentication and authorization
class RouteGuards {
  RouteGuards._();
  static const String _tag = 'RouteGuards';

  // Redirect logic for authentication
  // Returns the redirect path if user should be redirected, null otherwise
  static String? authGuard(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final currentPath = state.uri.path;

    LoggerService.debug('Auth guard check - Path: $currentPath, Logged in: $isLoggedIn', tag: _tag);

    // If user is logged in and trying to access public routes
    if (isLoggedIn && _isPublicRoute(currentPath)) {
      final userRole = authProvider.userRole;
      LoggerService.info('Logged in user accessing public route, redirecting to role home', tag: _tag);
      return _getHomeRouteForRole(userRole);
    }

    // If user is not logged in and trying to access protected routes
    if (!isLoggedIn && !_isPublicRoute(currentPath)) {
      LoggerService.warning('Unauthenticated user accessing protected route, redirecting to login', tag: _tag);
      return AppRoutes.login;
    }

    // No redirect needed
    return null;
  }

  /// Check if a route is public (doesn't require authentication)
  static bool _isPublicRoute(String path) {
    return _publicRoutes.any((route) => path.startsWith(route));
  }

  /// Get home route based on user role
  static String _getHomeRouteForRole(String? role) {
    return AppRoutes.getHomeForRole(role);
  }

  /// List of routes that don't require authentication
  static const List<String> _publicRoutes = [
    AppRoutes.root,
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.help,
    AppRoutes.terms,
    AppRoutes.privacy,
    AppRoutes.about,
  ];

  /// Role-based access control guard
  /// Returns true if user has access to the route
  static bool roleGuard(BuildContext context, String requiredRole) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;

    final hasAccess = userRole == requiredRole;

    if (!hasAccess) {
      LoggerService.warning('Role guard failed - Required: $requiredRole, User role: $userRole', tag: _tag);
    }

    return hasAccess;
  }

  /// Check if user can access musician routes
  static bool canAccessMusicianRoutes(BuildContext context) {
    return roleGuard(context, 'musician');
  }

  /// Check if user can access organizer routes
  static bool canAccessOrganizerRoutes(BuildContext context) {
    return roleGuard(context, 'organizer');
  }

  /// Handle unauthorized access
  static void handleUnauthorizedAccess(BuildContext context) {
    LoggerService.error('Unauthorized access attempt detected', tag: _tag);

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ You do not have permission to access this page'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );

    // Redirect to appropriate home
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;
    context.go(_getHomeRouteForRole(userRole));
  }

  /// Get current user ID
  static String getCurrentUserId(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.userId ?? '';
  }
}