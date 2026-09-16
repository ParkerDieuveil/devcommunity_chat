import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  AppUser _mapFirebaseUser(User user) {
    return UserModel.fromFirebaseUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final credential = await remoteDataSource.register(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Impossible de récupérer l’utilisateur créé.',
      );
    }

    return _mapFirebaseUser(user);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await remoteDataSource.login(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Impossible de récupérer l’utilisateur connecté.',
      );
    }

    return _mapFirebaseUser(user);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  AppUser? get currentUser {
    final user = remoteDataSource.currentUser;

    if (user == null) {
      return null;
    }

    return _mapFirebaseUser(user);
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return remoteDataSource.watchAuthState().map(
          (user) {
        if (user == null) {
          return null;
        }

        return _mapFirebaseUser(user);
      },
    );
  }
}