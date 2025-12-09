import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_role.dart';
import '../musician/home/widgets/musician_home_screen.dart';
import '../musician/discover_music/discover_music_screen.dart';
import '../musician/discover_events/discover_events_screen.dart';
import '../musician/post_music/post_music_screen.dart';
import '../musician/messages/messages_screen.dart';
import '../organizer/home/organizer_home_screen.dart';
import '../organizer/discover_music/organizer_discover_music_screen.dart';
import '../organizer/discover_events/organizer_discover_events_screen.dart';
import '../organizer/create_event/create_event_screen.dart';

/// Main navigation with bottom navbar and modal action button
class MainNavigation extends StatefulWidget {
  final UserRole userRole;
  final String userId;

  const MainNavigation({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Start with discover music

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens based on user role
    if (widget.userRole == UserRole.musician) {
      _screens = [
        DiscoverMusicScreen(userId: widget.userId),    // 0
        DiscoverEventsScreen(userId: widget.userId),   // 1
        // Index 2 is for action button modal (not in stack)
        MessagesScreen(userId: widget.userId),         // 2 (maps to nav index 3)
        MusicianHomeScreen(userId: widget.userId),     // 3 (maps to nav index 4)
      ];
    } else {
      _screens = [
        OrganizerDiscoverMusicScreen(userId: widget.userId),  // 0
        OrganizerDiscoverEventsScreen(userId: widget.userId), // 1
        // Index 2 is for action button modal (not in stack)
        MessagesScreen(userId: widget.userId),                // 2 (maps to nav index 3)
        OrganizerHomeScreen(userId: widget.userId),           // 3 (maps to nav index 4)
      ];
    }
  }

  /// Get screen index (accounting for the action button gap at index 2)
  int get _screenIndex {
    if (_currentIndex >= 3) {
      return _currentIndex - 1; // Shift down because index 2 doesn't exist in stack
    }
    return _currentIndex;
  }

  /// Handle action button tap - opens modal
  void _onActionButtonPressed() {
    if (widget.userRole == UserRole.musician) {
      _showPostMusicModal();
    } else {
      _showCreateEventModal();
    }
  }

  /// Show post music modal for musicians
  void _showPostMusicModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PostMusicScreen(
        userId: widget.userId,
        onMusicPosted: () {
          // Close modal and navigate to Discover Music
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    );
  }

  /// Show create event modal for organizers
  void _showCreateEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEventScreen(
        userId: widget.userId,
        onEventCreated: () {
          // Close modal and navigate to Discover Events
          Navigator.pop(context);
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _screenIndex,
        children: _screens,
      ),
      bottomNavigationBar: widget.userRole == UserRole.musician
          ? _buildMusicianNavBar() : _buildOrganizerNavBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Musician Navigation Bar
  Widget _buildMusicianNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.white,
        elevation: 0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.music_note,
                label: 'Music',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.event,
                label: 'Events',
                index: 1,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                icon: Icons.message,
                label: 'Messages',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Organizer Navigation Bar
  Widget _buildOrganizerNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.white,
        elevation: 0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.music_note,
                label: 'Music',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.event,
                label: 'Events',
                index: 1,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                icon: Icons.message,
                label: 'Messages',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB - Opens modal instead of changing index
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _onActionButtonPressed,
      backgroundColor: AppColors.primary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        color: AppColors.white,
        size: 32,
      ),
    );
  }
}