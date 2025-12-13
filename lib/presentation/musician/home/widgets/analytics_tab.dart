import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:musikita/core/constants/app_dimensions.dart';

/// Analytics and reviews tab
class AnalyticsTab extends StatelessWidget {
  final String userId;

  const AnalyticsTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Analytics Cards
          _buildAnalyticsCard(
            context,
            icon: Icons.visibility,
            title: 'Profile Views',
            value: '0',
            subtitle: 'Last 30 days',
          ),
          const SizedBox(height: AppDimensions.radiusMedium),
          _buildAnalyticsCard(
            context,
            icon: Icons.music_note,
            title: 'Music Plays',
            value: '0',
            subtitle: 'Total plays',
          ),
          const SizedBox(height: AppDimensions.radiusMedium),
          _buildAnalyticsCard(
            context,
            icon: Icons.event_available,
            title: 'Events Booked',
            value: '0',
            subtitle: 'Total events',
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),

          // Reviews Section
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // No reviews placeholder
          _buildNoReviewsPlaceholder(context),

          const SizedBox(height: 80), // Bottom padding for navbar
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
      padding: const EdgeInsets.all(AppDimensions.radiusXLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
            padding: const EdgeInsets.all(AppDimensions.radiusMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.tabIconSize,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
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
                const SizedBox(height: AppDimensions.spacingXSmall),
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
      padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: const Offset(0, AppDimensions.cardShadowOffsetY),
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
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Complete events to receive reviews from organizers',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}