import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/music_service.dart';
import '../../../data/models/music_post.dart';

/// Post music screen - for uploading new music
class PostMusicScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onMusicPosted;

  const PostMusicScreen({
    super.key,
    required this.userId,
    this.onMusicPosted,
  });

  @override
  State<PostMusicScreen> createState() => _PostMusicScreenState();
}

class _PostMusicScreenState extends State<PostMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _musicService = MusicService();
  final _titleController = TextEditingController();

  File? _selectedAudioFile;
  String? _selectedGenre;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (10MB limit)
        if (fileSize > 10 * 1024 * 1024) {
          _showError('File size exceeds 10MB limit');
          return;
        }

        setState(() {
          _selectedAudioFile = file;
        });
      }
    } catch (e) {
      _showError('Failed to pick file: ${e.toString()}');
    }
  }

  Future<void> _uploadMusic() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAudioFile == null) {
      _showError('Please select an audio file');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appUser = authProvider.appUser;

      if (appUser == null) {
        throw Exception('User not found');
      }

      // Upload audio file
      setState(() => _uploadProgress = 0.5);
      final audioUrl = await _musicService.uploadAudioFile(
        userId: widget.userId,
        audioFile: _selectedAudioFile!,
      );

      // Create music post
      setState(() => _uploadProgress = 0.8);
      await _musicService.createMusicPost(
        userId: widget.userId,
        artistName: appUser.username,
        title: _titleController.text.trim(),
        genre: _selectedGenre == 'Not Tagged' ? null : _selectedGenre,
        audioUrl: audioUrl,
      );

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Music uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Call the callback if provided
        widget.onMusicPosted?.call();

        // If no callback (opened directly), just pop
        if (widget.onMusicPosted == null) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Post Music'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Upload Your Music',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Audio File Picker
                  GestureDetector(
                    onTap: _isUploading ? null : _pickAudioFile,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedAudioFile != null
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedAudioFile != null
                                ? Icons.audio_file
                                : Icons.upload_file,
                            size: 64,
                            color: _selectedAudioFile != null
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedAudioFile != null
                                ? _selectedAudioFile!.path.split('/').last
                                : 'Tap to select MP3 file',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedAudioFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Max 10MB',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Song Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Song Title',
                      prefixIcon: Icon(Icons.music_note),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a song title';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Genre Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGenre,
                    decoration: const InputDecoration(
                      labelText: 'Genre (Optional)',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: MusicGenres.genres.map((genre) {
                      return DropdownMenuItem(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: _isUploading ? null : (value) {
                      setState(() => _selectedGenre = value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Upload Progress
                  if (_isUploading) ...[
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: AppColors.greyLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Uploading... ${(_uploadProgress * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Upload Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadMusic,
                      child: _isUploading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                          : const Text('Upload Music'),
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