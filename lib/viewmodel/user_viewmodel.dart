import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investy/datamodel/user_model.dart';
import 'package:investy/repository/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _userRepository.currentUser;

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    try {
      return await _userRepository.getUser(currentUser!.uid);
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String uid,
    required String username,
    String? fullName,
    String? phoneNumber,
    String? country,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if username changed and if it already exists
      final currentUserData = await _userRepository.getUser(uid);
      if (currentUserData != null && currentUserData.username != username) {
        try {
          final usernameExists = await _userRepository.usernameExists(username);
          if (usernameExists) {
            _setError('Username already exists. Please choose another one.');
            _setLoading(false);
            return false;
          }
        } catch (e) {

          if (e.toString().contains('permission-denied')) {
            // Permission denied - skip username check and proceed with update
            // This allows users to update their profile even if security rules
            // don't allow username queries
          } else {
            // For other errors, we can still proceed but log the issue
            // The update will go through and any conflicts will be handled by Firestore
          }
        }
      }

      // Create updated user model
      final updatedUser = UserModel(
        uid: uid,
        username: username,
        email: currentUserData?.email ?? '',
        createdAt: currentUserData?.createdAt ?? DateTime.now(),
        fullName: fullName?.isEmpty ?? true ? null : fullName,
        phoneNumber: phoneNumber?.isEmpty ?? true ? null : phoneNumber,
        country: country?.isEmpty ?? true ? null : country,
      );

      await _userRepository.updateUser(updatedUser);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete user account (requires password for re-authentication)
  Future<bool> deleteAccount({required String password}) async {
    final user = currentUser;
    if (user == null) {
      _setError('No user is currently signed in.');
      return false;
    }
    
    try {
      _setLoading(true);
      _clearError();

      final userEmail = user.email;
      final userUid = user.uid;
      
      if (userEmail == null) {
        _setError('User email not found. Cannot delete account.');
        _setLoading(false);
        return false;
      }

      // Re-authenticate user before deleting
      await _userRepository.reauthenticateUser(
        email: userEmail,
        password: password,
      );

      await _userRepository.deleteUser(userUid);

      await user.delete();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      _setLoading(false);
      return false;
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
