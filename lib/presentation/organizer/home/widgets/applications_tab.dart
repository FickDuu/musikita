import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event_application.dart';
import '../../../../data/services/event_service.dart';
import 'organizer_application_card.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
class ApplicationsTab extends StatefulWidget{
  final String userId;

  const ApplicationsTab({
    super.key,
    required this.userId,
  });

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> with SingleTickerProviderStateMixin{
  final _eventService = EventService();
  late TabController _tabController;

  final List<String> _filterOptions = ['All', 'Pending', 'Accepted', 'Rejected'];
  int _selectedFilterIndex = 0;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: _filterOptions.length, vsync: this);
    _tabController.addListener(() {
      if(!_tabController.indexIsChanging){
        setState(() {
          _selectedFilterIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  String? get _statusFilter {
    switch (_selectedFilterIndex) {
      case 1:
        return 'pending';
      case 2:
        return 'accepted';
      case 3:
        return 'rejected';
      default:
        return null; //all
    }
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Container(
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

          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: _filterOptions.map((label){
              return Tab(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingXSmall),
                      _buildCountBadge(label),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: _buildApplicationsList(),
        ),
      ],
    );
  }
  Widget _buildCountBadge(String filterLabel) {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getOrganizerApplicationsStream(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final applications = snapshot.data!;
        int count;

        switch (filterLabel) {
          case 'All':
            count = applications.length;
            break;
          case 'Pending':
            count = applications.where((app) => app.isPending).length;
            break;
          case 'Accepted':
            count = applications.where((app) => app.isAccepted).length;
            break;
          case 'Rejected':
            count = applications.where((app) => app.isRejected).length;
            break;
          default:
            count = 0;
        }

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _selectedFilterIndex == _filterOptions.indexOf(filterLabel)
                ? AppColors.primary
                : AppColors.greyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: _selectedFilterIndex == _filterOptions.indexOf(filterLabel)
                  ? AppColors.white
                  : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsList() {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getOrganizerApplicationsStream(widget.userId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    'Error loading applications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<EventApplication> applications = snapshot.data ?? [];

        // Apply filter
        if (_statusFilter != null) {
          applications = applications
              .where((app) => app.status == _statusFilter)
              .toList();
        }

        // Sort by date (newest first)
        applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

        // Empty state
        if (applications.isEmpty) {
          return _buildEmptyState();
        }

        // Applications list
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: AppLimits.refreshThrottleDuration));
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return OrganizerApplicationCard(
                application: application,
                onStatusChanged: () {
                  // Refresh the list when status changes
                  setState(() {});
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (_selectedFilterIndex) {
      case 1: // Pending
        message = 'No pending applications';
        subtitle = 'Applications awaiting your review will appear here';
        icon = Icons.pending_actions;
        break;
      case 2: // Accepted
        message = 'No accepted applications';
        subtitle = 'Musicians you\'ve accepted will appear here';
        icon = Icons.check_circle_outline;
        break;
      case 3: // Rejected
        message = 'No rejected applications';
        subtitle = 'Applications you\'ve declined will appear here';
        icon = Icons.cancel_outlined;
        break;
      default: // All
        message = 'No applications yet';
        subtitle = 'When musicians apply to your events, they\'ll appear here';
        icon = Icons.people_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}