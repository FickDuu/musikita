import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import 'collapsible_profile_header.dart';
import 'middle_navbar.dart';
import 'music_tab.dart';
import 'calendar_tab.dart';
import 'analytics_tab.dart';

//musician home profile screen
class MusicianHomeScreen extends StatefulWidget{
  final String userId;

  const MusicianHomeScreen({
    super.key,
    required this.userId,
  });

  @override State<MusicianHomeScreen> createState() => _MusicianHomeScreenState();
}

class _MusicianHomeScreenState extends State<MusicianHomeScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;

  bool _isHeaderCollapsed = false;
  static const double _collapseThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override void dispose() {
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
                flexibleSpace: FlexibleSpaceBar(
                  background: CollapsibleProfileHeader(
                    userId: widget.userId,

                    // TODO: Replace with actual data from Firebase
                    profileImageUrl: null,
                    username: 'Artist Name',
                    bio:'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Vestibulum viverra sapien at eleifend scelerisque.',
                  ),
                  titlePadding: EdgeInsets.zero,
                  title: _isHeaderCollapsed ? Text(
                    'Artist Name', // TODO: Replace with actual username
                    style: TextStyle(
                      fontFamily: AppTheme.artistUsernameFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                      : null,
                ),
              ),

              // middle navbar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    tabs: const[
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

//
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate{
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shinkOffset,
      bool overlapsContent,
      ) {
    return Container (
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate){
    return false;
  }
}