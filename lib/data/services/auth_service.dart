import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

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
      await _firestore.collection('users').doc(user.uid).set(appUser.toJson());

      // Create role-specific document with all required fields
      final now = DateTime.now();

      if (role == UserRole.musician) {
        await _firestore.collection('musicians').doc(user.uid).set({
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
        await _firestore.collection('organizers').doc(user.uid).set({
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
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on FirebaseException catch (e) {
      throw Exception('Database error: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('User profile not found. Please contact support.');
      }

      final data = doc.data();
      if (data == null) {
        throw Exception('User data is empty. Please contact support.');
      }

      return AppUser.fromJson(data);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on FirebaseException catch (e) {
      throw Exception('Database error: ${e.message ?? e.toString()}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}