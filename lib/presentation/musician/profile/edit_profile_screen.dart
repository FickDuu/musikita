import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/profile_service.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/constants/error_messages.dart';

/// Profile editing screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appUser = authProvider.appUser;

    _usernameController = TextEditingController(text: appUser?.username ?? '');
    _bioController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppLimits.maxProfileImageWidth.toDouble(),
        maxHeight: AppLimits.maxProfileImageHeight.toDouble(),
        imageQuality: AppLimits.profileImageQuality,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ErrorHandlerService.handleError(
          context,
          e,
          customMessage: ErrorMessages.filePickFailed,
          stackTrace: stackTrace,
          tag: 'EditProfileScreen',
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.appUser?.uid;

      if (userId == null) {
        throw Exception('User not found');
      }

      // Upload profile image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _profileService.uploadProfileImage(
          userId: userId,
          imageFile: _selectedImage!,
        );
      }

      // Update profile data
      await _profileService.updateProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        profileImageUrl: imageUrl,
      );

      // Refresh auth provider
      await authProvider.refreshUserData();

      if (mounted) {
        // Show success message
        ErrorHandlerService.showSuccess(
          context,
          ErrorMessages.successProfileUpdated,
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      if (mounted) {
        // Use centralized error handler
        ErrorHandlerService.handleError(
          context,
          e,
          stackTrace: stackTrace,
          tag: 'EditProfileScreen',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appUser = authProvider.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                  // Profile Image
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: AppDimensions.avatarRadiusXLarge,
                          backgroundColor: AppColors.greyLight,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (appUser?.profileImageUrl != null
                              ? NetworkImage(appUser!.profileImageUrl!)
                              : null) as ImageProvider?,
                          child: _selectedImage == null &&
                              appUser?.profileImageUrl == null
                              ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.grey,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: AppDimensions.iconSmall,
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: AppDimensions.iconSmall,
                                color: AppColors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: Validators.username,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Bio Field
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.info_outline),
                      hintText: 'Tell people about yourself...',
                    ),
                    maxLines: 4,
                    maxLength: AppLimits.bioMaxLength,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const SizedBox(
                        height: AppDimensions.iconMedium,
                        width: AppDimensions.iconMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: AppDimensions.progressIndicatorStroke,
                          color: AppColors.white,
                        ),
                      )
                          : const Text('Save Changes'),
                    ),
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