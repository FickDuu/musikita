/// Centralized error messages for the app
class ErrorMessages {
  ErrorMessages._(); // Private constructor to prevent instantiation

  // Authentication Errors
  static const String authEmailInvalid = 'Please enter a valid email address';
  static const String authPasswordWeak = 'Password must be at least 6 characters';
  static const String authEmailExists = 'An account with this email already exists';
  static const String authInvalidCredentials = 'Invalid email or password';
  static const String authUserNotFound = 'No account found with this email';
  static const String authTooManyRequests = 'Too many failed attempts. Please try again later';
  static const String authNetworkError = 'Network error. Please check your connection';
  static const String authUnknown = 'Authentication failed. Please try again';

  // Profile Errors
  static const String profileUpdateFailed = 'Failed to update profile';
  static const String profileImageUploadFailed = 'Failed to upload profile image';
  static const String profileLoadFailed = 'Failed to load profile';
  static const String profileNotFound = 'Profile not found';

  // Event Errors
  static const String eventCreateFailed = 'Failed to create event';
  static const String eventUpdateFailed = 'Failed to update event';
  static const String eventDeleteFailed = 'Failed to delete event';
  static const String eventLoadFailed = 'Failed to load events';
  static const String eventNotFound = 'Event not found';
  static const String eventApplicationFailed = 'Failed to submit application';
  static const String eventApplicationUpdateFailed = 'Failed to update application status';

  // Music Errors
  static const String musicUploadFailed = 'Failed to upload music';
  static const String musicDeleteFailed = 'Failed to delete music';
  static const String musicLoadFailed = 'Failed to load music';
  static const String audioFileInvalid = 'Invalid audio file. Please select an MP3 file';
  static const String audioFileTooLarge = 'Audio file is too large (max 10MB)';
  static const String audioPlaybackFailed = 'Failed to play audio';

  // Messaging Errors
  static const String messageSendFailed = 'Failed to send message';
  static const String messageLoadFailed = 'Failed to load messages';
  static const String conversationCreateFailed = 'Failed to create conversation';
  static const String conversationLoadFailed = 'Failed to load conversations';

  // File Upload Errors
  static const String filePickFailed = 'Failed to select file';
  static const String fileUploadFailed = 'Failed to upload file';
  static const String fileInvalidFormat = 'Invalid file format';
  static const String fileTooLarge = 'File is too large';
  static const String imageInvalidFormat = 'Invalid image format. Please select a JPG or PNG';

  // Network Errors
  static const String networkNoConnection = 'No internet connection';
  static const String networkTimeout = 'Request timed out. Please try again';
  static const String networkServerError = 'Server error. Please try again later';
  static const String networkUnknown = 'Network error occurred';

  // Permission Errors
  static const String permissionDenied = 'Permission denied';
  static const String permissionStorageDenied = 'Storage permission denied';
  static const String permissionCameraDenied = 'Camera permission denied';

  // Validation Errors
  static const String validationRequired = 'This field is required';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPasswordShort = 'Password must be at least 6 characters';
  static const String validationUsernameShort = 'Username must be at least 3 characters';
  static const String validationUsernameLong = 'Username is too long';
  static const String validationPhoneInvalid = 'Please enter a valid phone number';

  // Generic Errors
  static const String genericUnknown = 'Something went wrong. Please try again';
  static const String genericTryAgain = 'Please try again';
  static const String genericNoData = 'No data available';
  static const String genericLoadingFailed = 'Failed to load data';

  // Success Messages
  static const String successProfileUpdated = 'Profile updated successfully!';
  static const String successEventCreated = 'Event created successfully!';
  static const String successEventUpdated = 'Event updated successfully!';
  static const String successEventDeleted = 'Event deleted successfully!';
  static const String successMusicUploaded = 'Music uploaded successfully!';
  static const String successMusicDeleted = 'Music deleted successfully!';
  static const String successApplicationSubmitted = 'Application submitted successfully!';
  static const String successApplicationUpdated = 'Application updated successfully!';
  static const String successMessageSent = 'Message sent!';
  static const String successPasswordReset = 'Password reset email sent!';
}