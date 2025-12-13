// Application limits and validation constants - Input limits, validation rules, and constraints
class AppLimits {
  AppLimits._();

  //TEXT INPUT LIMITS
  //Username minimum length
  static const int usernameMinLength = 3;

  //Username maximum length
  static const int usernameMaxLength = 30;

  //Bio maximum length
  static const int bioMaxLength = 500;

  //Event name minimum length
  static const int eventNameMinLength = 3;

  //Event name maximum length
  static const int eventNameMaxLength = 100;

  //Event description maximum length
  static const int eventDescriptionMaxLength = 1000;

  //Message maximum length
  static const int messageMaxLength = 1000;

  //Music post title maximum length
  static const int musicTitleMaxLength = 100;

  //Music post description maximum length
  static const int musicDescriptionMaxLength = 500;

  //Artist name maximum length
  static const int artistNameMaxLength = 50;

  //Company name maximum length
  static const int companyNameMaxLength = 100;

  //Venue name maximum length
  static const int venueNameMaxLength = 100;

  //Location maximum length
  static const int locationMaxLength = 200;

  //PASSWORD REQUIREMENTS
  //Password minimum length
  static const int passwordMinLength = 6;

  //Password maximum length
  static const int passwordMaxLength = 50;

  //EVENT CONSTRAINTS
  // Minimum slots for an event
  static const int eventMinSlots = 1;

  //Maximum slots for an event
  static const int eventMaxSlots = 100;

  //Minimum payment amount (RM)
  static const double eventMinPayment = 0.0;

  //Maximum payment amount (RM)
  static const double eventMaxPayment = 100000.0;

  //Maximum genres per event
  static const int maxGenresPerEvent = 10;

  // MUSICIAN CONSTRAINTS
  //Maximum genres per musician
  static const int maxGenresPerMusician = 10;

  // Maximum music posts per musician
  static const int maxMusicPostsPerMusician = 50;

  // FILE UPLOAD LIMITS
  //Maximum image file size in bytes (5MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  //Maximum audio file size in bytes (10MB)
  static const int maxAudioSizeBytes = 10 * 1024 * 1024;

  //Maximum profile image width
  static const int maxProfileImageWidth = 1024;

  //Maximum profile image height
  static const int maxProfileImageHeight = 1024;

  //Profile image quality (0-100)
  static const int profileImageQuality = 85;

  //PAGINATION
  // Events per page
  static const int eventsPerPage = 20;

  //Music posts per page
  static const int musicPostsPerPage = 20;

  //Messages per page
  static const int messagesPerPage = 50;

  //Applications per page
  static const int applicationsPerPage = 20;

  // DEBOUNCE & THROTTLE
  //Search debounce duration in milliseconds
  static const int searchDebounceDuration = 500;

  // Refresh throttle duration in milliseconds
  static const int refreshThrottleDuration = 1000;

  //TIMEOUTS
  //Network request timeout in seconds
  static const int networkTimeoutSeconds = 30;

  // Image loading timeout in seconds
  static const int imageLoadTimeoutSeconds = 15;

  // UI CONSTRAINTS
  // Maximum lines for bio preview
  static const int bioPreviewMaxLines = 3;

  //Maximum lines for event description preview
  static const int descriptionPreviewMaxLines = 3;

  // Maximum genres to display in card
  static const int maxGenresDisplayInCard = 5;

  //SNACKBAR & NOTIFICATIONS
  // Default snackbar duration in seconds
  static const int snackbarDurationSeconds = 3;

  //Error snackbar duration in seconds
  static const int errorSnackbarDurationSeconds = 4;

  //Success snackbar duration in seconds
  static const int successSnackbarDurationSeconds = 2;

  //CACHE
  //Image cache duration in days
  static const int imageCacheDays = 7;

  //Maximum cache size in MB
  static const int maxCacheSizeMB = 100;

  //==DATE CONSTRAINTS
  //Minimum days in advance to create event
  static const int minDaysInAdvanceForEvent = 1;

  //Maximum days in advance to create event
  static const int maxDaysInAdvanceForEvent = 365;

  //VALIDATION PATTERNS
  // Username pattern (alphanumeric, underscore, dot)
  static const String usernamePattern = r'^[a-zA-Z0-9_.]+$';

  // Email pattern (basic validation)
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Phone number pattern (Malaysian format)
  static const String phonePattern = r'^(\+?6?01)[0-46-9]-*[0-9]{7,8}$';

  // RETRY LOGIC
  //Maximum retry attempts
  static const int maxRetryAttempts = 3;

  //Retry delay in milliseconds
  static const int retryDelayMilliseconds = 1000;
}