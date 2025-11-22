//centralise all strings
class AppStrings {
  AppStrings._();

  //App Info
  static const String appName = 'Musikita';
  static const String appTagline = 'yabadabadoo';

  //Welcome Screen
  static const String welcomeTitle = 'Welcome to Musikita';
  static const String welcomeSubtitle = 'HEHEHEHEHE';
  static const String getStarted = 'Get Started';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String login = 'Login';

  //authentication
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String username = 'Username';
  static const String artistName = 'Artist Name';
  static const String organizerName = 'Organizer Name';
  static const String forgotPassword = 'Forgot Password';
  static const String dontHaveAccount = "Don't have an Account?";
  static const String signUpHere = 'Sign up Here';

  //user roles
  static const String selectRole = 'I am a ...';
  static const String musician = 'Musician';
  static const String organizer = 'Event Organizer';
  static const String musicianDesc = 'Looking for gigs';
  static const String organizerDesc = 'Looking to book';

  //Validation Messages
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';

  //Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection';
  static const String authError = 'Authentication failed. Please try again';
  static const String emailExists = 'An account with this email already exists';
  static const String invalidCredentials = 'Invalid email or password';

  //Success Messages
  static const String registrationSuccess = 'Registration successful';
  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logout successful';
  static const String passwordResetSuccess = 'Password reset email sent';

  //Loading Messages
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';
}