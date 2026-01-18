import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  AuthState _authState = AuthState.initial;
  UserProfile? _userProfile;
  String? _errorMessage;

  // Getters
  AuthState get authState => _authState;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _authState == AuthState.loading;

  // Initialize auth state
  Future<void> initialize() async {
    _setAuthState(AuthState.loading);

    try {
      if (_supabaseService.isAuthenticated) {
        await _loadUserProfile();
        _setAuthState(AuthState.authenticated);
      } else {
        _setAuthState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
      _setAuthState(AuthState.unauthenticated);
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setAuthState(AuthState.loading);
    _clearError();

    try {
      await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      await _loadUserProfile();
      _setAuthState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      _setAuthState(AuthState.unauthenticated);
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setAuthState(AuthState.loading);
    _clearError();

    try {
      await _supabaseService.signIn(
        email: email,
        password: password,
      );

      await _loadUserProfile();
      _setAuthState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      _setAuthState(AuthState.unauthenticated);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setAuthState(AuthState.loading);

    try {
      await _supabaseService.signOut();
      _userProfile = null;
      _setAuthState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    _clearError();

    try {
      await _supabaseService.resetPassword(email: email);
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currency,
    String? currencySymbol,
  }) async {
    _clearError();

    try {
      await _supabaseService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        currency: currency,
        currencySymbol: currencySymbol,
      );

      await _loadUserProfile();
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    final profileData = await _supabaseService.getProfile();
    if (profileData != null) {
      _userProfile = UserProfile.fromJson(profileData);
      notifyListeners();
    }
  }

  // Helper methods
  void _setAuthState(AuthState state) {
    _authState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}