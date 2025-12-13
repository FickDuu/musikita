import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

//reusable background widget
class AppBackground extends StatelessWidget{
  final Widget child;
  final Color? backgroundColor;
  final double patternOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.patternOpacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.background,
      child: Stack(
        children: [
          //Dot pattern
          Positioned.fill(
            child: Opacity(
              opacity: patternOpacity,
              child: Image.asset(
                AppAssets.dotPattern,
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}