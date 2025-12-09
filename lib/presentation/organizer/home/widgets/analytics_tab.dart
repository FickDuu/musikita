import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Analytics tab for organizers
class OrganizerAnalyticsTab extends StatelessWidget {
  final String userId;

  const OrganizerAnalyticsTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Analytics Cards
          _buildAnalyticsCard(
            context,
            icon: Icons.event,
            title: 'Total Events',
            value: '0',
            subtitle: 'Events posted',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsCard(
            context,
            icon: Icons.people,
            title: 'Total Applications',
            value: '0',
            subtitle: 'Musicians applied',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsCard(
            context,
            icon: Icons.check_circle,
            title: 'Confirmed Bookings',
            value: '0',
            subtitle: 'Musicians booked',
          ),
          const SizedBox(height: 32),

          // Reviews Section (Future)
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          _buildNoReviewsPlaceholder(context),

          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required String subtitle,
      }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews from musicians will appear here',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
