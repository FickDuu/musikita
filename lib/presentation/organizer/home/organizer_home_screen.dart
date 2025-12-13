import 'package:flutter/material.dart';
import 'package:musikita/data/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/profile_service.dart';
import 'widgets/events_tab.dart';
import 'widgets/analytics_tab.dart';
import 'widgets/applications_tab.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';

/// Organizer home screen with create event FAB
class OrganizerHomeScreen extends StatefulWidget {
  final String userId;

  const OrganizerHomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  final _profileService = ProfileService();

  bool _isHeaderCollapsed = false;
  static const double _collapseThreshold = AppDimensions.headerCollapseThreshold;
  String? _bio;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _loadBio();
  }

  Future<void> _loadBio() async {
    final bio = await _profileService.getOrganizerBio(widget.userId);
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
                expandedHeight: AppDimensions.headerExpandedHeight,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(appUser),
                  titlePadding: EdgeInsets.zero,
                  title: null,
                ),
              ),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.event, size: AppDimensions.tabIconSize)),
                      Tab(icon: Icon(Icons.people, size: AppDimensions.tabIconSize)),
                      Tab(icon: Icon(Icons.analytics, size: AppDimensions.tabIconSize)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              EventsTab(userId: widget.userId),
              ApplicationsTab(userId: widget.userId),
              OrganizerAnalyticsTab(userId: widget.userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser? appUser) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Profile Image
        _buildProfileImage(appUser?.profileImageUrl),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Username and Bio Overlay
        Positioned(
          left: AppDimensions.spacingLarge,
          right: AppDimensions.spacingLarge,
          bottom: AppDimensions.spacingLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username with custom font
              Text(
                appUser?.username ?? 'Organizer',
                style: const TextStyle(
                  fontFamily: AppTheme.artistUsernameFont,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),

              // Bio
              Text(
                _bio ?? 'Welcome! We organize amazing events.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  height: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: AppLimits.bioPreviewMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Edit Profile & Logout Buttons (top right)
        Positioned(
          top: 48,
          right: AppDimensions.spacingMedium,
          child: Row(
            children: [
              // Logout button
              IconButton(
                onPressed: () async {
                  final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if(mounted) {
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  }
                },
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Edit Profile Button
              IconButton(
                onPressed: () {
                  context.push('/edit-profile');
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String? profileImageUrl) {
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.greyLight,
      child: Icon(
        Icons.business,
        size: 120,
        color: AppColors.grey.withValues(alpha: 0.5),
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