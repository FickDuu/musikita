import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../../core/config/app_config.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/services/logger_service.dart';

// Authentication service for Firebase Auth operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register new user with email and password
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    try {
      LoggerService.info(
        'Starting registration for: $email, role: ${role.name}',
        tag: 'AuthService',
      );
      // Create Firebase Auth user
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed - no user returned');
      }

      // Create app user object
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        username: username,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save to Firestore - users collection
      await _firestore.collection(AppConfig.usersCollection).doc(user.uid).set(appUser.toJson());

      // Create role-specific document with all required fields
      final now = DateTime.now();

      if (role == UserRole.musician) {
        await _firestore.collection(AppConfig.musiciansCollection).doc(user.uid).set({
          'id': user.uid,
          'userId': user.uid,
          'artistName': username,  // Use registration username as initial artist name
          'bio': 'Welcome to my profile! Edit this to tell people about yourself.',
          'profileImageUrl': null,
          'genres': [],  // Empty initially, user can add later
          'experience': null,
          'location': null,
          'contactNumber': null,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        // Create organizer document
        await _firestore.collection(AppConfig.organizersCollection).doc(user.uid).set({
          'id': user.uid,
          'userId': user.uid,
          'organizerName': username,
          'bio': 'Welcome! We organize evets. Contact us to book',
          'companyName': null,
          'businessType': null,
          'location': null,
          'contactNumber': null,
          'profileImageUrl': null,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      return appUser;
    } on FirebaseAuthException catch (e, stackTrace) {
      LoggerService.error(
        'Registration failed - Auth error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleAuthException(e);

    } on FirebaseException catch(e, stackTrace){
      LoggerService.error(
        'Registration failed - Firestore error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);

    } catch(e, stackTrace){
      LoggerService.error(
        'Registration failed - Unexpected error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw AuthException(
        'Registration failed. Please try again',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Sign in with email and password
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('Attempting sign in for: $email', tag: 'AuthService');
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      // Get user data from Firestore
      final doc = await _firestore.collection(AppConfig.usersCollection).doc(user.uid).get();

      if (!doc.exists) {
        throw ProfileException('User profile not found. Please contact support.');
      }

      final data = doc.data();
      if (data == null) {
        throw ProfileException('User data is empty. Please contact support.');
      }

      LoggerService.success('Sign in successful for: $email', tag: 'AuthService');
      return AppUser.fromJson(data);
    } on FirebaseAuthException catch (e, stackTrace) {
      LoggerService.error(
        'Sign in failed - Auth error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleAuthException(e);
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Sign in failed - Firestore error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } on ProfileException {
      // Re-throw ProfileException as-is
      rethrow;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Sign in failed - Unexpected error for: $email',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw AuthException(
        'Sign in failed. Please try again.',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      LoggerService.info('User signing out', tag: 'AuthService');
      await _auth.signOut();
      LoggerService.success('Sign out successful', tag: 'AuthService');
      } catch (e, stackTrace) {
      LoggerService.error(
        'Sign out failed',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw AuthException(
        'Failed to sign out. Please try again.',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      LoggerService.info('Fetching user data for: $uid', tag: 'AuthService');
      final doc = await _firestore.collection(AppConfig.usersCollection).doc(uid).get();

      if (!doc.exists) {
        LoggerService.warning('User data not found for: $uid', tag: 'AuthService');
        return null;
      }

      return AppUser.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to get user data for: $uid',
        tag: 'AuthService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}