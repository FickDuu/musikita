import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../core/constants/app_colors.dart';
import '/../../core/theme/app_theme.dart';
import '/../../core/widgets/app_background.dart';
import '/../../data/providers/auth_provider.dart';
import '/../../data/services/profile_service.dart';
import '../widgets/collapsible_profile_header.dart';
import '../widgets/middle_navbar.dart';
import '../widgets/music_tab.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/analytics_tab.dart';

/// Musician home/profile screen
/// Shows profile header, middle navbar with tabs, and content
class MusicianHomeScreen extends StatefulWidget {
  final String userId;

  const MusicianHomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MusicianHomeScreen> createState() => _MusicianHomeScreenState();
}

class _MusicianHomeScreenState extends State<MusicianHomeScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  final _profileService = ProfileService();

  // Header collapse tracking
  bool _isHeaderCollapsed = false;
  static const double _collapseThreshold = 200.0;
  String? _bio;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _loadBio();
  }

  Future<void> _loadBio() async {
    final bio = await _profileService.getMusicianBio(widget.userId);
    if (mounted) {
      setState(() {
        _bio = bio;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldCollapse = _scrollController.offset > _collapseThreshold;
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = shouldCollapse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appUser = authProvider.appUser;

    return Scaffold(
      body: AppBackground(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Collapsible Profile Header
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints){
                    final top = constraints.biggest.height;
                    final isFullyCollapsed = top <= kToolbarHeight + 50;

                    return FlexibleSpaceBar(
                      background: CollapsibleProfileHeader(
                        userId: widget.userId,
                        profileImageUrl: appUser?.profileImageUrl,
                        username: appUser?.username ?? 'Artist Name',
                        bio: _bio ?? 'Welcome to my profile! Book me for your next events',
                        isCollapsed: isFullyCollapsed,
                      ),
                      titlePadding: EdgeInsets.zero,
                      title: null,
                    );
                  },
                ),
              ),

              // Middle Navbar (Tabs)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.music_note, size: 28)),
                      Tab(icon: Icon(Icons.calendar_today, size: 28)),
                      Tab(icon: Icon(Icons.analytics, size: 28)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              MusicTab(userId: widget.userId),
              CalendarTab(userId: widget.userId),
              AnalyticsTab(userId: widget.userId),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom delegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}