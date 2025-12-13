import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_background.dart';
import 'package:musikita/core/constants/app_dimensions.dart';

/// Welcome screen with tiled logo background
/// Entry point after splash screen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top spacing
                const Spacer(flex: 2),

                // Logo and text content
                Column(
                  children: [
                    // Main logo
                    Image.asset(
                      AppAssets.logo,
                      width: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppDimensions.spacingXLarge),

                    // Title
                    Text(
                      AppStrings.welcomeTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),

                    // Subtitle
                    Text(
                      AppStrings.welcomeSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // Buttons
                Column(
                  children: [
                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(AppStrings.getStarted),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),

                    // Login text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(AppStrings.login),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}