import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../services/logger_service.dart';
import 'route_guards.dart';

// Screens
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/login/login_screen.dart';
import '../../presentation/auth/register/register_screen.dart';
import '../../presentation/common/navigation/main_navigation_shell.dart';

// Musician screens
import '../../presentation/musician/home/musician_home_screen.dart';
import '../../presentation/musician/profile/musician_profile_screen.dart';
import '../../presentation/musician/profile/edit_profile_screen.dart';
import '../../presentation/musician/music/post_music_screen.dart';

// Organizer screens
import '../../presentation/organizer/home/organizer_home_screen.dart';
import '../../presentation/organizer/home/organizer_profile_screen.dart';
import '../../presentation/organizer/events/create_event_screen.dart';

// Shared screens
import '../../presentation/shared/discover/discover_events_screen.dart';
import '../../presentation/shared/discover/discover_music_screen.dart';
import '../../presentation/shared/messaging/messages_screen.dart';
import '../../presentation/shared/messaging/chat_screen.dart';
import '../../presentation/shared/notifications/notifications_screen.dart';

/// GoRouter configuration for MUSIKITA
/// Uses unified navigation shell with role-aware routing
class AppRouter {
  AppRouter._();

  static const String _tag = 'AppRouter';

  /// The GoRouter instance
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: RouteGuards.authGuard,
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
    routes: [
      // PUBLIC ROUTES
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),

      // MAIN NAVIGATION SHELL (With bottom navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          // MUSICIAN ROUTES
          GoRoute(
            path: AppRoutes.musicianHome,
            name: 'musicianHome',
            builder: (context, state) {
              // Role guard
              if (!RouteGuards.canAccessMusicianRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return MusicianHomeScreen(userId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.musicianProfile,
            name: 'musicianProfile',
            builder: (context, state) {
              final musicianId = state.pathParameters['musicianId']!;
              return MusicianProfileScreen(musicianId: musicianId);
            },
          ),

          GoRoute(
            path: AppRoutes.musicianOwnProfile,
            name: 'musicianOwnProfile',
            builder: (context, state) {
              if (!RouteGuards.canAccessMusicianRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return MusicianProfileScreen(musicianId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.musicianEditProfile,
            name: 'musicianEditProfile',
            builder: (context, state) {
              if (!RouteGuards.canAccessMusicianRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }
              return const EditProfileScreen();
            },
          ),

          GoRoute(
            path: AppRoutes.musicianPostMusic,
            name: 'musicianPostMusic',
            builder: (context, state) {
              if (!RouteGuards.canAccessMusicianRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return PostMusicScreen(userId: userId);
            },
          ),

          // ORGANIZER ROUTES
          GoRoute(
            path: AppRoutes.organizerHome,
            name: 'organizerHome',
            builder: (context, state) {
              if (!RouteGuards.canAccessOrganizerRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return OrganizerHomeScreen(userId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.organizerProfile,
            name: 'organizerProfile',
            builder: (context, state) {
              final organizerId = state.pathParameters['organizerId']!;
              return OrganizerProfileScreen(organizerId: organizerId);
            },
          ),

          GoRoute(
            path: AppRoutes.organizerOwnProfile,
            name: 'organizerOwnProfile',
            builder: (context, state) {
              if (!RouteGuards.canAccessOrganizerRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return OrganizerProfileScreen(organizerId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.organizerEditProfile,
            name: 'organizerEditProfile',
            builder: (context, state) {
              if (!RouteGuards.canAccessOrganizerRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }
              return const EditProfileScreen();
            },
          ),

          GoRoute(
            path: AppRoutes.organizerCreateEvent,
            name: 'organizerCreateEvent',
            builder: (context, state) {
              if (!RouteGuards.canAccessOrganizerRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final userId = RouteGuards.getCurrentUserId(context);
              return CreateEventScreen(userId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.organizerEditEvent,
            name: 'organizerEditEvent',
            builder: (context, state) {
              if (!RouteGuards.canAccessOrganizerRoutes(context)) {
                RouteGuards.handleUnauthorizedAccess(context);
                return const SizedBox.shrink();
              }

              final eventId = state.pathParameters['eventId']!;
              final userId = RouteGuards.getCurrentUserId(context);
              return CreateEventScreen(
                userId: userId,
                eventId: eventId, // Pass eventId for edit mode
              );
            },
          ),

          // SHARED ROUTES (Both roles with role-aware behavior)
          GoRoute(
            path: AppRoutes.discoverEvents,
            name: 'discoverEvents',
            builder: (context, state) => const DiscoverEventsScreen(),
          ),

          GoRoute(
            path: AppRoutes.discoverMusic,
            name: 'discoverMusic',
            builder: (context, state) => const DiscoverMusicScreen(),
          ),

          GoRoute(
            path: AppRoutes.messages,
            name: 'messages',
            builder: (context, state) {
              final userId = RouteGuards.getCurrentUserId(context);
              return MessagesScreen(userId: userId);
            },
          ),

          GoRoute(
            path: AppRoutes.chat,
            name: 'chat',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              final userId = RouteGuards.getCurrentUserId(context);
              return ChatScreen(
                conversationId: conversationId,
                currentUserId: userId,
              );
            },
          ),

          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (context, state) {
              final userId = RouteGuards.getCurrentUserId(context);
              return NotificationsScreen(userId: userId);
            }
          )
        ],
      ),

      // ERROR ROUTES
      GoRoute(
        path: AppRoutes.notFound,
        name: 'notFound',
        builder: (context, state) => const _NotFoundScreen(),
      ),
    ],
  );

  // TRANSITION BUILDERS
  // Build page with fade transition
  static Page _buildPageWithFadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Build page with slide transition
  static Page _buildPageWithSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // NAVIGATION HELPERS
  /// Navigate to a route by path
  static void navigateTo(BuildContext context, String path) {
    LoggerService.debug('Navigating to: $path', tag: _tag);
    context.go(path);
  }

  /// Push a new route onto the stack
  static void pushRoute(BuildContext context, String path) {
    LoggerService.debug('Pushing route: $path', tag: _tag);
    context.push(path);
  }

  /// Replace the current route
  static void replaceRoute(BuildContext context, String path) {
    LoggerService.debug('Replacing route with: $path', tag: _tag);
    context.replace(path);
  }

  /// Go back to previous route
  static void goBack(BuildContext context) {
    LoggerService.debug('Going back', tag: _tag);
    context.pop();
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }
}

// ERROR SCREENS
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('An error occurred'),
            if (error != null) Text(error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
