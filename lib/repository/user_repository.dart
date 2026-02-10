import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investy/services/auth_service.dart';
import 'package:investy/datamodel/user_model.dart';

class UserRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final String _collection = 'users';

  // Auth state
  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    User? createdUser;
    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account. Please try again.');
      }

      createdUser = userCredential.user;

      try {
        final usernameExists = await this.usernameExists(username);
        if (usernameExists) {
          await createdUser!.delete();
          throw Exception('Username already exists. Please choose another one.');
        }
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
        } else {
          if (createdUser != null) {
            await createdUser.delete();
          }
          throw Exception('Failed to verify username: ${e.message ?? "Please check Firestore security rules."}');
        }
      } catch (e) {
        throw Exception('Failed to verify username: ${e.toString()}');
      }

      final userModel = UserModel(
        uid: createdUser!.uid,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );

      await createUser(userModel);
      return userModel;
    } on Exception {
      rethrow;
    } catch (e) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
        }
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(user.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to save user data: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<bool> usernameExists(String username) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check username: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logoutUser() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> reauthenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.reauthenticateWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

