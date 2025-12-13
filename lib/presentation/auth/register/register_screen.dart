import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musikita/core/constants/app_dimensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_role.dart';
import '../../../data/services/auth_service.dart';
import '../../common/widgets/role_selection_card.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/constants/error_messages.dart';

/// Registration screen with role selection
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  UserRole? _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ErrorHandlerService.showWarning(
        context,
        'Please select your role (Musician or Organizer)',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appUser = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        role: _selectedRole!,
      );

      if (mounted) {
        ErrorHandlerService.showSuccess(
          context,
          '${AppStrings.registrationSuccess} Welcome, ${appUser.username}!',
        );
        // Navigate to auth gate (will redirect to home)
        context.go('/auth');
      }
    } catch (e, stackTrace){
      if(mounted){
        ErrorHandlerService.handleError(
          context,
          e,
          stackTrace: stackTrace,
          tag: 'RegisterScreen',
        );
      }
    }
    finally{
      if(mounted){
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signUp),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Role Selection
                  Text(
                    AppStrings.selectRole,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  RoleSelectionCard(
                    role: UserRole.musician,
                    isSelected: _selectedRole == UserRole.musician,
                    onTap: () => setState(() => _selectedRole = UserRole.musician),
                  ),
                  const SizedBox(height: AppDimensions.radiusMedium),

                  RoleSelectionCard(
                    role: UserRole.organizer,
                    isSelected: _selectedRole == UserRole.organizer,
                    onTap: () => setState(() => _selectedRole = UserRole.organizer),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: _selectedRole == UserRole.musician
                          ? AppStrings.artistName
                          : _selectedRole == UserRole.organizer
                          ? AppStrings.organizerName
                          : AppStrings.username,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: Validators.username,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: AppStrings.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) =>
                        Validators.confirmPassword(value, _passwordController.text),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRegister(),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Register Button
                  SizedBox(
                    height: AppDimensions.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                        height: AppDimensions.progressIndicatorMedium,
                        width: AppDimensions.progressIndicatorMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: AppDimensions.progressIndicatorStroke,
                          color: AppColors.white,
                        ),
                      )
                          : const Text(AppStrings.signUp),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Login Link
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
            ),
          ),
        ),
      ),
    );
  }
}