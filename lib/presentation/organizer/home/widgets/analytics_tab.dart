import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

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
            icon: Icons.event,
            title: 'Total Events',
            value: '0',
            subtitle: 'Events posted',
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          _buildAnalyticsCard(
            context,
            icon: Icons.people,
            title: 'Total Applications',
            value: '0',
            subtitle: 'Musicians applied',
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          _buildAnalyticsCard(
            context,
            icon: Icons.check_circle,
            title: 'Confirmed Bookings',
            value: '0',
            subtitle: 'Musicians booked',
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),

          // Reviews Section (Future)
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

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
      padding: const EdgeInsets.all(AppDimensions.spacingMedium + 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: Offset(0, AppDimensions.cardShadowOffsetY),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSmall),
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
            offset: Offset(0, AppDimensions.cardShadowOffsetY),
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
            'Reviews from musicians will appear here',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
