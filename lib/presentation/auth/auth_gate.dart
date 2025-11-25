import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user_role.dart';
import '../common/main_navigation.dart';
import '../welcome/welcome_screen.dart';

/// Auth gate that directs users to appropriate screen based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, show home screen
        if (authProvider.isAuthenticated && authProvider.appUser != null) {
          return MainNavigation(
            userRole: authProvider.appUser!.role,
            userId: authProvider.appUser!.uid,
          );
        }

        // If not authenticated, show welcome screen
        return const WelcomeScreen();
      },
    );
  }
}