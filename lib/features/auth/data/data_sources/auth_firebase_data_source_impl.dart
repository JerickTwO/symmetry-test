import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'auth_firebase_data_source.dart';

/// Implementación concreta del [AuthFirebaseDataSource].
/// Interactúa directamente con Firebase Auth y Cloud Firestore.
class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthFirebaseDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      return await _buildUserModel(user, email);
    } on FirebaseAuthException catch (e) {
      throw _mapSignInException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return await _buildUserModel(user, user.email ?? 'unknown@email.com');
  }

  // ──────────────────── Private Helpers ────────────────────

  Future<UserModel> _buildUserModel(User user, String fallbackEmail) async {
    if (kIsWeb) {
      return UserModel(
        uid: user.uid,
        email: user.email ?? fallbackEmail,
        fullName: user.displayName ?? 'Usuario',
        createdAt: DateTime.now(),
      );
    }

    final userDoc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('Datos de usuario no encontrados en Firestore');
    }

    final userData = userDoc.data()!;
    userData['uid'] = user.uid;

    return UserModel.fromRawData(userData);
  }

  Future<void> _saveUserToFirestore(UserModel userModel) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userModel.uid)
          .set(userModel.toJson())
          .timeout(Duration(seconds: 10));
    } catch (_) {
      // Si falla Firestore, aún retornamos el usuario ya que se creó en Auth
    }
  }

  Exception _mapSignInException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No existe una cuenta con este correo electrónico');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('El correo electrónico no es válido');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada');
      case 'invalid-credential':
        return Exception(
            'Credenciales incorrectas. Verifica tu correo y contraseña');
      default:
        return Exception('Error al iniciar sesión: ${e.message}');
    }
  }

}
