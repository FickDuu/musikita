import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers/auth_provider.dart';

/// Collapsible profile header with image, username, and bio
/// Similar to Spotify artist page header
class CollapsibleProfileHeader extends StatelessWidget {
  final String userId;
  final String? profileImageUrl;
  final String username;
  final String bio;
  final bool isCollapsed;

  const CollapsibleProfileHeader({
    super.key,
    required this.userId,
    this.profileImageUrl,
    required this.username,
    required this.bio,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Profile Image
        _buildProfileImage(),

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
          left: 24,
          right: 24,
          bottom: 24,
          child: AnimatedOpacity(
            opacity: isCollapsed ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username with custom font
                if(!isCollapsed)
                  Text(
                    username,
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
                if(!isCollapsed)
                  const SizedBox(height: 8),

                // Bio
                if(!isCollapsed)
                  Text(
                    bio,
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),

        // Edit Profile & Logout Buttons (top right)
        Positioned(
          top: 48,
          right: 16,
          child: Row(
            children: [
              // Logout button
              IconButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.go('/auth');
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

  Widget _buildProfileImage() {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return Image.network(
        profileImageUrl!,
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
        Icons.person,
        size: 120,
        color: AppColors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}