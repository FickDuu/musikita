import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_role.dart';
import '../musician/home/widgets/musician_home_screen.dart';
import '../musician/discover_music/discover_music_screen.dart';
import '../musician/discover_events/discover_events_screen.dart';
import '../musician/post_music/post_music_screen.dart';
import '../musician/messages/messages_screen.dart';

class MainNavigation extends StatefulWidget{
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
  int _currentIndex = 0;

  late final List<Widget> _musicianScreens;

  @override
  void initState() {
    super.initState();
    _musicianScreens = [
      DiscoverMusicScreen(userId: widget.userId),
      DiscoverEventsScreen(userId: widget.userId),
      PostMusicScreen(userId: widget.userId),
      MessagesScreen(userId: widget.userId),
      MusicianHomeScreen(userId: widget.userId),
    ];
  }

  List <Widget> get _screens {
    return _musicianScreens;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(){
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

        child:BottomAppBar(
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
                  label: 'Discover',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
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
        )
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
        child : Column(
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

  Widget _buildFloatingActionButton(){
    final isSelected = _currentIndex == 2;
    return FloatingActionButton(
      onPressed: () => setState(() => _currentIndex = 2),
      backgroundColor: isSelected ? AppColors.primaryDark : AppColors.grey,
      elevation: 4,
      child: const Icon(
        Icons.add,
        color: AppColors.white,
        size: 32,
      ),
    );
  }
}