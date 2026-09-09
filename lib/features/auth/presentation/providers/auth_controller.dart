import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import 'auth_provider.dart';

final authControllerProvider =
NotifierProvider<AuthController, AsyncValue<AppUser?>>(
  AuthController.new,
);

class AuthController extends Notifier<AsyncValue<AppUser?>> {
  @override
  AsyncValue<AppUser?> build() {
    return const AsyncData(null);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(registerUseCaseProvider).call(
        email: email,
        password: password,
      );

      state = AsyncData(user);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(
        _mapFirebaseAuthError(error),
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        'Une erreur inattendue est survenue.',
        stackTrace,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(loginUseCaseProvider).call(
        email: email,
        password: password,
      );

      state = AsyncData(user);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(
        _mapFirebaseAuthError(error),
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        'Une erreur inattendue est survenue.',
        stackTrace,
      );
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      await ref.read(logoutUseCaseProvider).call();

      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(
        _mapFirebaseAuthError(error),
        stackTrace,
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        'Une erreur inattendue est survenue.',
        stackTrace,
      );
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'L’adresse email est invalide.';

      case 'user-not-found':
        return 'Aucun compte ne correspond à cette adresse email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';

      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';

      case 'weak-password':
        return 'Le mot de passe est trop faible.';

      case 'network-request-failed':
        return 'Problème de connexion Internet.';

      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';

      case 'user-disabled':
        return 'Ce compte a été désactivé.';

      default:
        return error.message ??
            'Une erreur d’authentification est survenue.';
    }
  }
}