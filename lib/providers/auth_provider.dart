import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    print('AuthProvider: Initializing authentication...');
    
    // Listen to auth state changes first
    _authService.authStateChanges.listen((User? user) {
      print('AuthProvider: Auth state changed - User: ${user?.uid ?? "null"}, isAnonymous: ${user?.isAnonymous ?? "unknown"}');
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
    
    // Check if already signed in
    _user = _authService.currentUser;
    print('AuthProvider: Current user: ${_user?.uid ?? "null"}, isAnonymous: ${_user?.isAnonymous ?? "unknown"}');
    
    // If not signed in, sign in anonymously
    if (_user == null) {
      print('AuthProvider: No current user, signing in anonymously...');
      await signIn();
    } else {
      print('AuthProvider: User already signed in');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    print('AuthProvider: Starting sign in process...');
    _isLoading = true;
    notifyListeners();
    
    _user = await _authService.signInAnonymously();
    print('AuthProvider: Sign in completed - User: ${_user?.uid ?? "null"}');
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserAvatar() async {
    if (_user != null) {
      return await _authService.getUserAvatar(_user!.uid);
    }
    return null;
  }

  Future<void> createUserDocumentIfNeeded() async {
    if (_user != null) {
      await _authService.createUserDocument(_user!.uid);
    }
  }
}