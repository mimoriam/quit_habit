import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quit_habit/services/auth_service.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:quit_habit/services/app_usage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final AppUsageService _appUsageService = AppUsageService();

  @override
  void dispose() {
    _appUsageService.dispose();
    super.dispose();
  }
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
        // Initialize App Usage Tracking
        try {
          // Guard against re-initialization by ensuring any previous session is cleaned up
          if (_appUsageService.isInitialized) {
            await _appUsageService.dispose();
          }
          _appUsageService.init(user.uid);
        } catch (e) {
          debugPrint('Error initializing AppUsageService: $e');
        }
        
        // Check questionnaire status from Firestore
        await _checkQuestionnaireStatus(user);
      } else {
        // Stop App Usage Tracking
        try {
          if (_appUsageService.isInitialized) {
            await _appUsageService.dispose();
          }
        } catch (e) {
          debugPrint('Error disposing AppUsageService: $e');
        }
        _hasCompletedQuestionnaire = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _checkQuestionnaireStatus(User user) async {
    // Always check Firestore for all users
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

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        // Ensure Firestore document exists for Google users
        try {
          final userDoc = await _userService.getUserDocument(user.uid);
          if (userDoc == null) {
            // Document doesn't exist, create it
            await _userService.createUserDocument(user);
          }
        } catch (e) {
          // If Firestore operations fail, log but don't block sign-in
          // Graceful degradation: user can still sign in, document will be created later if needed
          debugPrint('Failed to check/create user document: $e');
        }
        
        // Check questionnaire status
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

  /// Mark questionnaire as completed (saves to Firestore for all users)
  Future<void> markQuestionnaireCompleted() async {
    if (_user == null) return;

    try {
      // Ensure document exists first (for Google users who might not have one yet)
      final userDoc = await _userService.getUserDocument(_user!.uid);
      if (userDoc == null) {
        // Document doesn't exist, create it first
        await _userService.createUserDocument(_user!);
      }
      
      // Mark questionnaire as completed in Firestore
      await _userService.markQuestionnaireCompleted(_user!.uid);
      _hasCompletedQuestionnaire = true;
      notifyListeners();
    } catch (e) {
      // If saving fails, still update local state for better UX
      // User will see completion state even if sync fails temporarily
      _hasCompletedQuestionnaire = true;
      notifyListeners();
      rethrow;
    }
  }

  /// Reset password by sending reset email
  /// Note: Provider checking is no longer possible client-side due to Firebase Auth deprecation
  /// of fetchSignInMethodsForEmail. The email will be sent and Firebase handles validation server-side.
  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Send password reset email
      // Firebase will handle validation server-side and only send email if appropriate
      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_user != null) {
      try {
        await _user!.reload();
        _user = _authService.currentUser;
        if (_user == null) {
          debugPrint('User session invalidated during refresh');
          return;
        }
        await _checkQuestionnaireStatus(_user!);
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing user: $e');
        rethrow;
      }
    }
  }
}

