/// Application configuration - App-wide settings and configuration values
class AppConfig {
  AppConfig._();

  //App info
  //Application name
  static const String appName = 'MUSIKITA';

  // Application version
  static const String appVersion = '1.0.0';

  // Application build number
  static const int buildNumber = 1;

  // Feature Flags
  //Enable debug mode
  static const bool debugMode = true;

  // Enable analytics
  static const bool analyticsEnabled = false;

  // Enable crash reporting
  static const bool crashReportingEnabled = false;

  // Enable notifications
  static const bool notificationsEnabled = true;

  // Enable messaging feature
  static const bool messagingEnabled = true;

  // Enable music upload feature
  static const bool musicUploadEnabled = true;

  //Firebase
  //Firestore events collection name
  static const String eventsCollection = 'events';

  // Firestore users collection name
  static const String usersCollection = 'users';

  // Firestore musicians collection name
  static const String musiciansCollection = 'musicians';

  // Firestore organizers collection name
  static const String organizersCollection = 'organizers';

  // Firestore music posts collection name
  static const String musicPostsCollection = 'music_posts';

  // Firestore conversations collection name
  static const String conversationsCollection = 'conversations';

  // Firestore messages collection name
  static const String messagesCollection = 'messages';

  // Firestore event applications collection name
  static const String eventApplicationsCollection = 'event_applications';

  // Firestore notifications collection name
  static const String notificationsCollection = 'notifications';

  // Firebase Storage profile images path
  static const String profileImagesPath = 'profile_images';

  // Firebase Storage music files path
  static const String musicFilesPath = 'music_files';

  //UI Settings
  //Show splash screen
  static const bool showSplashScreen = true;

  // Splash screen duration in seconds
  static const int splashScreenDuration = 2;

  // Enable haptic feedback
  static const bool hapticFeedbackEnabled = true;

  // Enable animations
  static const bool animationsEnabled = true;

  // Animation duration in milliseconds
  static const int animationDuration = 300;

  //Date and Time
  //Date format for display
  static const String dateFormat = 'MMM d, y';

  // Time format for display (e.g., "2:30 PM")
  static const String timeFormat = 'h:mm a';

  // DateTime format for display (e.g., "Jan 15, 2024 at 2:30 PM")
  static const String dateTimeFormat = 'MMM d, y \'at\' h:mm a';

  //Supported Values
  //Supported music genres
  static const List<String> supportedGenres = [
    'Rock',
    'Pop',
    'Jazz',
    'Classical',
    'Hip Hop',
    'Electronic',
    'R&B',
    'Country',
    'Folk',
    'Blues',
    'Reggae',
    'Metal',
    'Indie',
    'Soul',
    'Funk',
    'Latin',
    'World Music',
    'Acoustic',
  ];

  //Supported experience levels
  static const List<String> experienceLevels = [
    'Beginner (< 1 year)',
    'Intermediate (1-3 years)',
    'Advanced (3-5 years)',
    'Professional (5+ years)',
    'Expert (10+ years)',
  ];

  //Supported business types for organizers
  static const List<String> businessTypes = [
    'Restaurant',
    'Bar',
    'Club',
    'Hotel',
    'Event Company',
    'Wedding Planner',
    'Corporate Events',
    'Private Events',
    'Other',
  ];

  //Payment
  //Currency symbol
  static const String currencySymbol = 'RM';

  // Currency code
  static const String currencyCode = 'MYR';

  //Contact and Support
  //Support email
  static const String supportEmail = 'support@musikita.com';

  // Website URL
  static const String websiteUrl = 'https://musikita.com';

  // Terms of Service URL
  static const String termsUrl = 'https://musikita.com/terms';

  // Privacy Policy URL
  static const String privacyUrl = 'https://musikita.com/privacy';

  //SocialMedia
  //Facebook page URL
  static const String facebookUrl = 'https://facebook.com/musikita';

  // Instagram profile URL
  static const String instagramUrl = 'https://instagram.com/musikita';

  // Twitter profile URL
  static const String twitterUrl = 'https://twitter.com/musikita';

  //Development
  //Enable verbose logging
  static const bool verboseLogging = true;

  //Log API requests
  static const bool logApiRequests = true;

  //Log navigation
  static const bool logNavigation = true;
}