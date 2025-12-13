// Centralized route path constants for MUSIKITA
// Simplified unified routes with role-aware navigation
class AppRoutes {
  AppRoutes._();

  // ========================================================
  // ROOT & SPLASH
  // ========================================================
  static const String root = '/';
  static const String splash = '/splash';

  // ========================================================
  // AUTHENTICATION ROUTES
  // ========================================================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  // ========================================================
  // MUSICIAN ROUTES
  // ========================================================
  static const String musicianHome = '/musician/home';
  static const String musicianProfile = '/musician/profile/:musicianId';
  static const String musicianOwnProfile = '/musician/profile'; // Own profile
  static const String musicianEditProfile = '/musician/edit-profile';

  // ========================================================
  // ORGANIZER ROUTES
  // ========================================================
  static const String organizerHome = '/organizer/home';
  static const String organizerProfile = '/organizer/profile/:organizerId';
  static const String organizerOwnProfile = '/organizer/profile'; // Own profile
  static const String organizerEditProfile = '/organizer/edit-profile';
  static const String organizerCreateEvent = '/organizer/create-event';
  static const String organizerEditEvent = '/organizer/edit-event/:eventId';

  // ========================================================
  // SHARED ROUTES (Both Roles)
  // ========================================================

  // Discover (unified for both roles, behavior differs internally)
  static const String discoverEvents = '/discover/events';
  static const String discoverMusic = '/discover/music';

  // Messaging (shared by both roles)
  static const String messages = '/messages';
  static const String chat = '/chat/:conversationId';

  // Settings & Notifications (role-aware)
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // ========================================================
  // COMMON/PUBLIC ROUTES
  // ========================================================
  static const String help = '/help';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String about = '/about';

  // ========================================================
  // ERROR ROUTES
  // ========================================================
  static const String notFound = '/404';
  static const String error = '/error';
  static const String unauthorized = '/unauthorized';

  // ========================================================
  // HELPER METHODS
  // ========================================================

  /// Generate musician profile route with ID
  static String musicianProfilePath(String musicianId) {
    return musicianProfile.replaceAll(':musicianId', musicianId);
  }

  /// Generate organizer profile route with ID
  static String organizerProfilePath(String organizerId) {
    return organizerProfile.replaceAll(':organizerId', organizerId);
  }

  /// Generate organizer edit event route with ID
  static String organizerEditEventPath(String eventId) {
    return organizerEditEvent.replaceAll(':eventId', eventId);
  }

  /// Generate chat route with ID
  static String chatPath(String conversationId) {
    return chat.replaceAll(':conversationId', conversationId);
  }

  /// Check if route is a musician route
  static bool isMusicianRoute(String route) {
    return route.startsWith('/musician');
  }

  /// Check if route is an organizer route
  static bool isOrganizerRoute(String route) {
    return route.startsWith('/organizer');
  }

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    return !_publicRoutes.contains(route);
  }

  /// Get home route based on user role
  static String getHomeForRole(String? role) {
    switch (role) {
      case 'musician':
        return musicianHome;
      case 'organizer':
        return organizerHome;
      default:
        return login;
    }
  }

  // ========================================================
  // PUBLIC ROUTES (No authentication required)
  // ========================================================
  static const List<String> _publicRoutes = [
    root,
    splash,
    login,
    register,
    forgotPassword,
    resetPassword,
    help,
    terms,
    privacy,
    about,
  ];
}
