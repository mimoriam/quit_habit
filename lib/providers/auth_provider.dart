import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quit_habit/services/auth_service.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = true;
  bool _hasCompletedQuestionnaire = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get hasCompletedQuestionnaire => _hasCompletedQuestionnaire;
  AuthService get authService => _authService;
  UserService get userService => _userService;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        // Check questionnaire status (Firestore for email/password, SharedPreferences for Google)
        await _checkQuestionnaireStatus(user);
      } else {
        _hasCompletedQuestionnaire = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Check if user signed in with Google
  bool _isGoogleSignInUser(User user) {
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  Future<void> _checkQuestionnaireStatus(User user) async {
    // Google sign-in users don't have Firestore documents
    if (_isGoogleSignInUser(user)) {
      // Check SharedPreferences for Google users
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = _getQuestionnaireKey(user.uid);
        _hasCompletedQuestionnaire = prefs.getBool(key) ?? false;
      } catch (e) {
        // If check fails, assume not completed
        _hasCompletedQuestionnaire = false;
      }
      notifyListeners();
      return;
    }

    // Only check Firestore for email/password users
    try {
      _hasCompletedQuestionnaire =
          await _userService.hasCompletedQuestionnaire(user.uid);
      notifyListeners();
    } catch (e) {
      // If check fails, assume not completed
      _hasCompletedQuestionnaire = false;
      notifyListeners();
    }
  }

  /// Get SharedPreferences key for questionnaire status
  String _getQuestionnaireKey(String uid) {
    return 'questionnaire_completed_$uid';
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        // Check questionnaire status (will load from SharedPreferences for Google users)
        await _checkQuestionnaireStatus(user);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      final user = _authService.currentUser;

      if (user != null) {
        await _checkQuestionnaireStatus(user);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential =
          await _authService.signUpWithEmailAndPassword(email, password, fullName);
      final user = userCredential.user;

      if (user != null) {
        // Create user document
        await _userService.createUserDocument(user, fullName: fullName);
        // New users haven't completed questionnaire
        _hasCompletedQuestionnaire = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _hasCompletedQuestionnaire = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh questionnaire status
  Future<void> refreshQuestionnaireStatus() async {
    if (_user != null) {
      await _checkQuestionnaireStatus(_user!);
    }
  }

  /// Mark questionnaire as completed (for Google users, persists to SharedPreferences)
  Future<void> markQuestionnaireCompleted() async {
    if (_user == null) return;

    final isGoogleUser = _isGoogleSignInUser(_user!);
    
    if (isGoogleUser) {
      // For Google users, save to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = _getQuestionnaireKey(_user!.uid);
        await prefs.setBool(key, true);
        _hasCompletedQuestionnaire = true;
        notifyListeners();
      } catch (e) {
        // If saving fails, still update local state
        _hasCompletedQuestionnaire = true;
        notifyListeners();
      }
    } else {
      // For email/password users, save to Firestore
      await _userService.markQuestionnaireCompleted(_user!.uid);
      _hasCompletedQuestionnaire = true;
      notifyListeners();
    }
  }
}

