# MUSIKITA Project - Claude Code Context

> **Auto-loaded context for Claude Code sessions**

---

## 🎯 Project Overview

**MUSIKITA** is a Flutter mobile application connecting musicians with event organizers for live performance bookings.

- **Musicians** showcase talent, upload music samples, apply to events
- **Organizers** post events, discover musicians, manage bookings

---

## 🏗️ Tech Stack

### Core Framework
- **Framework:** Flutter (Dart SDK ^3.10.0)
- **State Management:** Provider pattern (AuthProvider, NotificationProvider)
- **Routing:** GoRouter (13.2.5) with custom guards and transitions

### Firebase Backend
- **Authentication:** Firebase Auth (6.1.2)
- **Database:** Cloud Firestore (6.1.0)
- **File Storage:** Firebase Storage (13.0.4)
- **Notifications:** Firebase Cloud Messaging (FCM)

### Key Libraries
- **Audio:** just_audio (0.10.5) - Music playback
- **Maps:** Google Maps Flutter + Geolocator (13.0.2)
- **Calendar:** table_calendar (3.0.9)
- **File Handling:** image_picker, file_picker
- **UI:** Google Fonts, Material Design 3
- **Utilities:** intl, url_launcher

---

## 📊 Current Project Status

### 🎉 Recent Accomplishments

The project has completed three major phases of development:
- ✅ **Constants & Configuration** - Centralized all magic numbers and config values
- ✅ **Error Handling System** - Comprehensive logging and user feedback
- ✅ **Routing & Navigation** - Full GoRouter implementation with guards and role-based access

**Recent Work (Latest Commits):**
- Completed routing restructuring with unified navigation shell
- Built notification system with real-time updates
- Fixed and optimized routing guards
- Consolidated duplicate screens (discover routes now shared)
- Improved error handling throughout the app

**Current Status:** The app is functionally complete with all major features implemented. Now focusing on code quality, testing, and polish.

---

### ✅ Completed Work

#### Phase 1: Constants Implementation (COMPLETE)
**Status:** 52 files updated, ~1,082 changes

**Created Files:**
- `lib/core/constants/app_dimensions.dart` - All spacing, sizing, radii
- `lib/core/constants/app_limits.dart` - Validation limits, durations
- `lib/core/config/app_config.dart` - Configuration, collection names

**Key Constants:**
```dart
// AppDimensions - All UI measurements
spacingXSmall: 4, spacingSmall: 8, spacingMedium: 16, spacingLarge: 24, spacingXLarge: 32
radiusSmall: 8, radiusMedium: 12, radiusLarge: 16, radiusXLarge: 20
iconSmall: 20, iconMedium: 24, tabIconSize: 28
avatarRadiusSmall: 16, avatarRadiusMedium: 24, avatarRadiusXLarge: 60
buttonHeight: 56, cardShadowBlur: 8, progressStroke: 2

// AppLimits - Validation
eventNameMinLength: 3, eventNameMaxLength: 100
bioMaxLength: 500, maxAudioSizeBytes: 10*1024*1024
snackbarSuccessDuration: 2s, snackbarErrorDuration: 4s

// AppConfig - Configuration
eventsCollection, usersCollection, musiciansCollection, organizersCollection
supportedGenres, experienceLevels, businessTypes
```

---

#### Phase 2: Error Handling Service (COMPLETE)
**Status:** 16 files updated, ~800 changes

**Created Files:**
- `lib/core/constants/error_messages.dart` - Centralized error messages
- `lib/core/exceptions/app_exception.dart` - Custom exception types
- `lib/core/exceptions/firebase_exceptions.dart` - Firebase error handlers
- `lib/core/services/logger_service.dart` - Colored logging with tags
- `lib/core/services/error_handler_service.dart` - User feedback system

**Updated Services (ALL):**
- auth_service.dart, profile_service.dart, music_service.dart
- event_service.dart, messaging_service.dart
- musician_discovery_service.dart, organizer_service.dart

**Updated Screens:**
- login_screen.dart, register_screen.dart
- post_music_screen.dart, edit_profile_screen.dart

---

#### Phase 3: Routing & Navigation (COMPLETE)
**Status:** Comprehensive routing system implemented

**Created Files:**
- `lib/core/routing/app_router.dart` - Complete GoRouter configuration with 20+ routes
- `lib/core/routing/route_guards.dart` - Auth and role-based guards
- `lib/core/constants/app_routes.dart` - Centralized route path constants

**Implemented Routes:**
- **Authentication:** `/login`, `/register`, `/splash`
- **Musician Routes:** Home, profile, edit profile, post music (with role guards)
- **Organizer Routes:** Home, profile, edit profile, create/edit events (with role guards)
- **Shared Routes:** Discover events, discover music, messages, chat, notifications
- **Navigation Shell:** Bottom navigation with role-aware tabs

**Key Features:**
- Authentication guards (redirect to login if not authenticated)
- Role-based access control (musician/organizer routes protected)
- Custom page transitions (fade for login, slide for register)
- Path parameter support (`:musicianId`, `:organizerId`, `:conversationId`, `:eventId`)
- Unauthorized access handling with user feedback
- Helper methods for navigation (navigateTo, pushRoute, replaceRoute, goBack)

---

### 🚧 Pending Work

#### Phase 4: Code Quality & Cleanup (~2 hours) ⬅️ NEXT
**Current Issues:** 13 linting warnings/info messages

**Tasks:**
1. Clean up unused imports (7 warnings)
   - notification_provider.dart, profile_service.dart, artist_info_bottom_sheet.dart, post_music_screen.dart, organizer_application_card.dart
   - firebase_exceptions.dart (2 unnecessary imports)
2. Remove unused variables (3 warnings)
   - main_navigation_shell.dart: userId, userRole
   - event_application_card.dart: _isProcessing
   - create_event_screen.dart: _isLoadingEvent
   - chat_screen.dart: _conversation
3. Fix async context usage (1 info)
   - event_card.dart:73 - use_build_context_synchronously

**Completion Criteria:**
- Run `dart fix --apply` to auto-fix issues
- Verify `flutter analyze` shows 0 issues
- Test app functionality after cleanup

---

#### Phase 5: Service Refactoring (~3 hours)
**Problem:** Some services are too large and handle multiple concerns

**Target Files:**
- `event_service.dart` - Could be split into event_service and event_application_service
- Consider splitting messaging_service if needed

**Approach:**
- Evaluate service size and responsibilities
- Split only if genuinely needed for maintainability
- Ensure backward compatibility

---

#### Phase 6: Additional Features & Polish (~ongoing)
**Potential Enhancements:**
- Settings screen implementation
- Password reset functionality
- Pagination for large lists
- Image caching optimization
- Loading skeletons for better UX
- Additional notification types
- Search and filtering improvements

---

#### Phase 7: Testing (~ongoing)
**Testing Strategy:**
- Unit tests for core services (auth, events, messaging)
- Widget tests for critical screens
- Integration tests for key user flows
- Manual testing on real devices

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart      ✅ [PHASE 1]
│   │   ├── app_limits.dart          ✅ [PHASE 1]
│   │   ├── app_routes.dart          ✅ [PHASE 3]
│   │   ├── app_strings.dart
│   │   └── error_messages.dart      ✅ [PHASE 2]
│   ├── config/
│   │   └── app_config.dart          ✅ [PHASE 1]
│   ├── exceptions/
│   │   ├── app_exception.dart       ✅ [PHASE 2]
│   │   └── firebase_exceptions.dart ✅ [PHASE 2]
│   ├── routing/
│   │   ├── app_router.dart          ✅ [PHASE 3]
│   │   └── route_guards.dart        ✅ [PHASE 3]
│   ├── services/
│   │   ├── error_handler_service.dart ✅ [PHASE 2]
│   │   ├── fcm_service.dart
│   │   └── logger_service.dart        ✅ [PHASE 2]
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── validators.dart
│   └── widgets/
│       └── gradient_background.dart
├── data/
│   ├── models/
│   │   ├── app_user.dart
│   │   ├── musician.dart
│   │   ├── organizer.dart
│   │   ├── event.dart
│   │   ├── event_application.dart
│   │   ├── music_post.dart
│   │   ├── conversation.dart
│   │   ├── message.dart
│   │   ├── notification.dart
│   │   └── user_role.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── notification_provider.dart
│   └── services/
│       ├── auth_service.dart            ✅ [PHASE 2]
│       ├── profile_service.dart         ✅ [PHASE 2]
│       ├── music_service.dart           ✅ [PHASE 2]
│       ├── event_service.dart           ✅ [PHASE 2]
│       ├── messaging_service.dart       ✅ [PHASE 2]
│       ├── notification_service.dart
│       ├── musician_discovery_service.dart ✅ [PHASE 2]
│       └── organizer_service.dart       ✅ [PHASE 2]
└── presentation/
    ├── splash/
    │   └── splash_screen.dart
    ├── auth/
    │   ├── login/
    │   └── register/
    ├── common/
    │   ├── navigation/
    │   │   └── main_navigation_shell.dart ✅ [PHASE 3]
    │   └── widgets/
    ├── musician/
    │   ├── home/
    │   ├── profile/
    │   ├── music/
    │   └── discover/
    ├── organizer/
    │   ├── home/
    │   ├── profile/
    │   ├── events/
    │   └── discover/
    └── shared/
        ├── discover/        ✅ [Unified discovery]
        ├── messaging/       ✅ [Real-time chat]
        └── notifications/   ✅ [Notification center]
```

---

## 🎯 Core Features

### Authentication & User Management
- Email/password authentication with Firebase
- Dual role system (Musician vs Organizer)
- Role-based routing and access control
- Profile creation and editing with image uploads
- Session persistence

### For Musicians
- **Profile Management:** Artist name, bio, genres, experience level, contact info
- **Music Sharing:** Upload and showcase music samples with metadata
- **Event Discovery:** Browse and filter available gigs
- **Event Applications:** Apply to events, track application status
- **Calendar View:** See upcoming events and avoid time clashes
- **Analytics:** Track profile views, applications, and engagement

### For Organizers
- **Event Management:** Create, edit, and manage events
- **Event Details:** Location (Google Maps), date/time, genres, payment, slots
- **Musician Discovery:** Browse musicians by genre and experience
- **Application Management:** Review and respond to musician applications
- **Analytics:** Track event views, applications received
- **Business Profile:** Company info, business type, contact details

### Shared Features
- **Real-time Messaging:** Chat between musicians and organizers
- **Notifications:** Event applications, acceptances, rejections, messages
- **Discovery:** Unified discover screen for events and music
- **Navigation:** Role-aware bottom navigation with smooth transitions
- **Error Handling:** User-friendly error messages and logging

### Technical Features
- **Authentication Guards:** Auto-redirect based on auth state
- **Role Guards:** Prevent unauthorized access to role-specific routes
- **FCM Integration:** Push notifications for important updates
- **Firestore Real-time:** Live updates for messages and notifications
- **Image Optimization:** Compressed uploads to Firebase Storage
- **Form Validation:** Comprehensive input validation with limits
- **Time Clash Detection:** Prevent double-booking for musicians

---

## 🎨 Architecture Patterns

### Service Layer Pattern
```dart
class SomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<Result> doOperation() async {
    try {
      LoggerService.info('Starting operation', tag: 'ServiceName');
      
      // Use AppConfig for collections
      final doc = await _firestore
          .collection(AppConfig.someCollection)
          .doc(id)
          .get();
      
      LoggerService.success('Operation successful', tag: 'ServiceName');
      return result;
      
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Operation failed',
        tag: 'ServiceName',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error',
        tag: 'ServiceName',
        exception: e,
        stackTrace: stackTrace,
      );
      throw CustomException(
        ErrorMessages.appropriateMessage,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
}
```

### UI Layer Pattern
```dart
class SomeScreen extends StatefulWidget {
  Future<void> _handleAction() async {
    try {
      await _service.doOperation();
      
      if (mounted) {
        ErrorHandlerService.showSuccess(
          context,
          ErrorMessages.successMessage,
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ErrorHandlerService.handleError(
          context,
          e,
          stackTrace: stackTrace,
          tag: 'ScreenName',
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingLarge),
      child: // widgets
    );
  }
}
```

### Stream Pattern (No try-catch in streams)
```dart
Stream<List<Item>> getItemsStream() {
  LoggerService.info('Setting up stream', tag: 'ServiceName');
  
  return _firestore
      .collection(AppConfig.itemsCollection)
      .snapshots()
      .map((snapshot) {
    LoggerService.info(
      'Received ${snapshot.docs.length} items',
      tag: 'ServiceName',
    );
    return snapshot.docs
        .map((doc) => Item.fromJson(doc.data()))
        .toList();
  });
}
```

---

## ✅ CRITICAL RULES - ALWAYS FOLLOW

### 1. Never Use Magic Numbers
```dart
// ❌ DON'T DO THIS
Container(
  padding: EdgeInsets.all(24.0),
  child: SizedBox(height: 56),
)

// ✅ DO THIS
Container(
  padding: EdgeInsets.all(AppDimensions.spacingLarge),
  child: SizedBox(height: AppDimensions.buttonHeight),
)
```

### 2. Always Use ErrorHandlerService
```dart
// ❌ DON'T DO THIS
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Success')),
);

// ✅ DO THIS
ErrorHandlerService.showSuccess(
  context,
  ErrorMessages.successMessage,
);
```

### 3. Always Use LoggerService
```dart
// ❌ DON'T DO THIS
print('User logged in');

// ✅ DO THIS
LoggerService.info('User logged in', tag: 'AuthService');
```

### 4. Always Use Custom Exceptions
```dart
// ❌ DON'T DO THIS
throw Exception('Something went wrong');

// ✅ DO THIS
throw EventException(
  ErrorMessages.eventCreateFailed,
  originalException: e,
  stackTrace: stackTrace,
);
```

### 5. Always Use AppConfig for Collections
```dart
// ❌ DON'T DO THIS
_firestore.collection('events')

// ✅ DO THIS
_firestore.collection(AppConfig.eventsCollection)
```

### 6. Always Add Stack Traces
```dart
// ❌ DON'T DO THIS
} catch (e) {
  LoggerService.error('Error', exception: e);
}

// ✅ DO THIS
} catch (e, stackTrace) {
  LoggerService.error(
    'Error',
    exception: e,
    stackTrace: stackTrace,
  );
}
```

### 7. Always Check mounted
```dart
// ❌ DON'T DO THIS
await someOperation();
Navigator.pop(context);

// ✅ DO THIS
await someOperation();
if (mounted) {
  Navigator.pop(context);
}
```

### 8. Always Tag Logs
```dart
// ❌ DON'T DO THIS
LoggerService.info('Starting operation');

// ✅ DO THIS
LoggerService.info('Starting operation', tag: 'ServiceName');
```

---

## 🎨 UI Constants Reference

### Spacing
- `AppDimensions.spacingXSmall` = 4
- `AppDimensions.spacingSmall` = 8
- `AppDimensions.spacingMedium` = 16
- `AppDimensions.spacingLarge` = 24
- `AppDimensions.spacingXLarge` = 32

### Border Radius
- `AppDimensions.radiusSmall` = 8
- `AppDimensions.radiusMedium` = 12
- `AppDimensions.radiusLarge` = 16
- `AppDimensions.radiusXLarge` = 20

### Icons
- `AppDimensions.iconSmall` = 20
- `AppDimensions.iconMedium` = 24
- `AppDimensions.tabIconSize` = 28

### Avatars
- `AppDimensions.avatarRadiusSmall` = 16
- `AppDimensions.avatarRadiusMedium` = 24
- `AppDimensions.avatarRadiusXLarge` = 60

### Common Sizes
- `AppDimensions.buttonHeight` = 56
- `AppDimensions.progressStroke` = 2
- `AppDimensions.borderWidth` = 1
- `AppDimensions.borderWidthThick` = 2

---

## 📋 Validation Limits Reference

### Text Lengths
- `AppLimits.eventNameMinLength` = 3
- `AppLimits.eventNameMaxLength` = 100
- `AppLimits.bioMaxLength` = 500
- `AppLimits.bioPreviewMaxLines` = 3

### Event Constraints
- `AppLimits.minEventSlots` = 1
- `AppLimits.maxEventSlots` = 100
- `AppLimits.minEventPayment` = 0
- `AppLimits.maxEventPayment` = 100000

### File Limits
- `AppLimits.maxAudioSizeBytes` = 10 * 1024 * 1024 (10MB)
- `AppLimits.profileImageMaxWidth` = 1024
- `AppLimits.profileImageMaxHeight` = 1024
- `AppLimits.imageQuality` = 85

### Durations
- `AppLimits.snackbarSuccessDuration` = 2 seconds
- `AppLimits.snackbarDefaultDuration` = 3 seconds
- `AppLimits.snackbarErrorDuration` = 4 seconds

---

## 🎯 When Adding New Features

### Step 1: Define Constants
```dart
// Add to appropriate constants file
// AppDimensions for UI measurements
// AppLimits for validation rules
// AppConfig for configuration
```

### Step 2: Add Error Messages
```dart
// In error_messages.dart
static const String newFeatureError = 'User-friendly message';
static const String newFeatureSuccess = 'Success message!';
```

### Step 3: Create Service (if needed)
```dart
// Follow service layer pattern
// Use LoggerService with tags
// Throw custom exceptions
// Use AppConfig for collections
```

### Step 4: Create UI
```dart
// Use ErrorHandlerService for feedback
// Use AppDimensions for all measurements
// Check mounted before navigation
// Follow UI layer pattern
```

### Step 5: Test
```dart
// Run flutter analyze
// Test happy path
// Test error scenarios
// Verify console logs
```

---

## 🚨 Common Mistakes to Avoid

### ❌ Don't Do These:
```dart
// Magic numbers
padding: EdgeInsets.all(24.0)

// Hardcoded collections
.collection('events')

// Manual snackbars
ScaffoldMessenger.of(context).showSnackBar(...)

// Generic exceptions
throw Exception('Error')

// No logging
// (just silence)

// No stack traces
} catch (e) { ... }

// Print statements
print('Debug info')

// Forgetting mounted check
Navigator.pop(context)
```

### ✅ Do These Instead:
```dart
// Use constants
padding: EdgeInsets.all(AppDimensions.spacingLarge)

// Use AppConfig
.collection(AppConfig.eventsCollection)

// Use ErrorHandlerService
ErrorHandlerService.showSuccess(context, message)

// Custom exceptions
throw EventException(ErrorMessages.eventCreateFailed, ...)

// Always log
LoggerService.info('Starting...', tag: 'ServiceName')

// Capture stack traces
} catch (e, stackTrace) { ... }

// Use LoggerService
LoggerService.debug('Debug info', tag: 'Component')

// Check mounted
if (mounted) Navigator.pop(context)
```

---

## 📝 Known Issues / TODOs

1. **Linting Cleanup** - 13 warnings/info messages (unused imports, variables, async context)
2. **Password Reset** - Not yet implemented (planned feature)
3. **Settings Screen** - Route defined but screen not implemented
4. **Pagination** - Large lists load everything at once
5. **Image Caching** - Could be optimized for better performance
6. **Tests** - Need unit, widget, and integration tests
7. **Documentation** - Some methods need dartdoc comments
8. **Service Size** - event_service.dart could potentially be split

---

## 🎯 Current Priority: Phase 4

**Focus:** Code quality and linting cleanup

**Current State:**
- Routing system: ✅ Complete
- Authentication & guards: ✅ Complete
- Navigation shell: ✅ Complete
- Error handling: ✅ Complete
- Notification system: ✅ Complete

**Next Steps:**
1. Run `dart fix --apply` to auto-fix issues
2. Manually remove unused imports and variables
3. Fix BuildContext async usage warning
4. Verify with `flutter analyze`
5. Test app to ensure no regressions

---

## 💡 Helpful Tips for Claude Code

### Understanding the Codebase
- All screens are in `lib/presentation/`
- All services are in `lib/data/services/`
- All models are in `lib/data/models/`
- Constants are in `lib/core/constants/` and `lib/core/config/`

### Making Changes
- Always preserve existing patterns
- Follow the architecture established in Phase 1 & 2
- Use constants, logging, error handling as shown
- Test with `flutter analyze` before committing

### Common Commands
```bash
flutter pub get           # Get dependencies
flutter analyze           # Check for issues
flutter run               # Run app
flutter test              # Run tests
dart fix --apply          # Auto-fix issues
```

---

## 🎉 You're Ready!

This file provides all the context needed to work on MUSIKITA. Follow the patterns, avoid the mistakes, and build great features!

**Remember:**
- ✅ Use constants (AppDimensions, AppLimits, AppConfig)
- ✅ Use ErrorHandlerService for feedback
- ✅ Use LoggerService with tags
- ✅ Throw custom exceptions
- ✅ Check mounted before navigation
- ✅ Follow established patterns

**Good luck building MUSIKITA! 🎸🎤**
