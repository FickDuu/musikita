import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class CollapsibleProfileHeader extends StatelessWidget{
  final String userId;
  final String? profileImageUrl;
  final String username;
  final String bio;

  const CollapsibleProfileHeader({
    super.key,
    required this.userId,
    this.profileImageUrl,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context){
    return Stack(
      fit: StackFit.expand,
      children:[
        _buildProfileImage(),

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

        //username and bio
        Positioned(
          left:24,
          right:24,
          bottom:24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:[
              Text( //username
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
              const SizedBox(height: 8),

              //bio
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

        //Edit button
        Positioned(
          top:48,
          right: 16,
          child: IconButton(
            onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile'),
                ),
              );
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
        ),
      ],
    );
  }

  Widget _buildProfileImage(){
    if(profileImageUrl != null && profileImageUrl!.isNotEmpty){
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