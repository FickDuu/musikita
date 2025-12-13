import 'package:flutter/material.dart';
import 'package:musikita/data/services/notification_service.dart';
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
    // Index mapping: 0=Music, 1=Events, 2=Skip(FAB), 3=Messages, 4=Profile
    if (location.contains('/discover/music')) {
      return 0; // Music
    } else if (location.contains('/discover/events') || location.contains('/discover')) {
      return 1; // Events
    } else if (location.contains('/messages') || location.contains('/chat')) {
      return 3; // Messages
    } else if (location.contains('/profile') || location.contains('/home')) {
      return 4; // Profile/Home
    }

    return 1; // Default to events
  }

  void _onItemTapped(BuildContext context, int index) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;

    LoggerService.debug('Navigation tapped: index=$index, role=$userRole', tag: _tag);

    // Index mapping: 0=Music, 1=Events, 2=Skip(FAB), 3=Messages, 4=Profile
    switch (index) {
      case 0: // Music
        context.go(AppRoutes.discoverMusic);
        break;
      case 1: // Events
        context.go(AppRoutes.discoverEvents);
        break;
      case 2: // Center FAB - handled separately
        // This case shouldn't be reached as FAB is separate
        break;
      case 3: // Messages
        context.go(AppRoutes.messages);
        break;
      case 4: // Profile
        context.go(userRole == 'musician'
            ? AppRoutes.musicianOwnProfile
            : AppRoutes.organizerOwnProfile);
        break;
    }
  }

  void _onFabTapped(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;
    final userId = authProvider.userId ?? '';

    LoggerService.debug('FAB tapped: role=$userRole', tag: _tag);

    if (userRole == 'musician') {
      // Navigate to post music screen for musicians
      context.push(AppRoutes.musicianPostMusic);
    } else if (userRole == 'organizer') {
      // Navigate to create event screen for organizers
      context.push(AppRoutes.organizerCreateEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onFabTapped(context),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: AppDimensions.bottomNavHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.music_note_outlined,
              selectedIcon: Icons.music_note,
              label: 'Music',
              index: 0,
              selectedIndex: selectedIndex,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.event_outlined,
              selectedIcon: Icons.event,
              label: 'Events',
              index: 1,
              selectedIndex: selectedIndex,
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              context: context,
              icon: Icons.message_outlined,
              selectedIcon: Icons.message,
              label: 'Messages',
              index: 3,
              selectedIndex: selectedIndex,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              index: 4,
              selectedIndex: selectedIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.userId ?? '';

    return DefaultTabController(
      length: 2,
      initialIndex: isEventsTab ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
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

        actions: [
          StreamBuilder<int>(
            stream: NotificationService().getUnreadCountStream(userId),
            builder: (context, snapshot){
              final unreadCount = snapshot.data ?? 0;
              return IconButton(
                icon: Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: Icon(Icons.notifications),
                ),
                onPressed: () => context.push(AppRoutes.notifications),
              );
            },
          ),
          ],
        ),
        body: child,
      ),
    );
  }
}
