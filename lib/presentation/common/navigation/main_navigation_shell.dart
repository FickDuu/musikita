import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/providers/auth_provider.dart';

/// Main navigation shell with bottom navigation bar
/// Adapts navigation items based on user role (musician/organizer)
class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  static const String _tag = 'MainNavigationShell';

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;

    LoggerService.debug('Current location: $location, Role: $userRole', tag: _tag);

    // Determine selected index based on current route
    if (location.contains('/home')) {
      return 0; // Home
    } else if (location.contains('/discover')) {
      return 1; // Discover
    } else if (location.contains('/messages') || location.contains('/chat')) {
      return 2; // Messages
    } else if (location.contains('/profile')) {
      return 3; // Profile
    }

    return 0; // Default to home
  }

  void _onItemTapped(BuildContext context, int index) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;

    LoggerService.debug('Navigation tapped: index=$index, role=$userRole', tag: _tag);

    switch (index) {
      case 0: // Home
        context.go(userRole == 'musician'
            ? AppRoutes.musicianHome
            : AppRoutes.organizerHome);
        break;
      case 1: // Discover
        context.go(AppRoutes.discoverEvents);
        break;
      case 2: // Messages
        context.go(AppRoutes.messages);
        break;
      case 3: // Profile
        context.go(userRole == 'musician'
            ? AppRoutes.musicianOwnProfile
            : AppRoutes.organizerOwnProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        height: AppDimensions.bottomNavHeight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Discover tab shell with sub-navigation between Events and Music
class DiscoverShell extends StatelessWidget {
  final Widget child;

  const DiscoverShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isEventsTab = location.contains('/events');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: null,
          isScrollable: false,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Music'),
          ],
          onTap: (index) {
            if (index == 0) {
              context.go(AppRoutes.discoverEvents);
            } else {
              context.go(AppRoutes.discoverMusic);
            }
          },
        ),
      ),
      body: child,
    );
  }
}
