import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

//auth  state to retain last sign in
class AuthProvider extends ChangeNotifier{
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null && _appUser != null;

  // Convenience getters for routing
  String? get userRole => _appUser?.role.name;
  String? get userId => _appUser?.uid;

  AuthProvider(){
    _initAuthListener();
  }

  //initialize auth state listener
  void _initAuthListener(){
    _authService.authStateChanges.listen((User? user) async{
      _firebaseUser = user;

      if(user!= null){
        await _loadUserData(user.uid); //user is signed in, fetch app user data
      }
      else{
        _appUser = null;
        _isLoading = false;
      }
      notifyListeners();
    });
  }

  //load user data from firestore
  Future<void> _loadUserData(String uid) async{
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userData = await _authService.getUserData(uid);
      _appUser = userData;
      _isLoading = false;
      notifyListeners();
    }
    catch (e){
      _error = 'Failed to load user data: ${e.toString()}';
      _isLoading =false;
      notifyListeners();
    }
  }

  //sign out
  Future<void> signOut() async{
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _authService.signOut();

      _firebaseUser = null;
      _appUser = null;
      _isLoading = false;
      notifyListeners();
    }
    catch(e){
      _error = 'Failed to sign out: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  //refresh
  Future<void> refreshUserData() async{
  if(_firebaseUser != null){
      await _loadUserData(_firebaseUser!.uid);
    }
  }

  void updateAppUser(AppUser updatedUser){
    _appUser = updatedUser;
    notifyListeners();
  }

  void clearError(){
    _error = null;
    notifyListeners();
  }
}