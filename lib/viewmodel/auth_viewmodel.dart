import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investy/datamodel/user_model.dart';
import 'package:investy/repository/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  StreamSubscription<User?>? _authStateSubscription;
  bool _disposed = false;

  User? get currentUser => _userRepository.currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    // Listen to auth state changes
    _authStateSubscription = _userRepository.authStateChanges.listen((User? user) {
      if (!_disposed) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _userRepository.registerUser(
        username: username,
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _userRepository.loginUser(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _userRepository.logoutUser();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _userRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    try {
      return await _userRepository.getUser(currentUser!.uid);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

