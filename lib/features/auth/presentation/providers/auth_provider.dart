import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/watch_auth_state_use_case.dart';

/// Infra : instance Firebase Auth (datasources uniquement).
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    ref.watch(authRepositoryProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
  );
});

final getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(
    ref.watch(authRepositoryProvider),
  );
});

final watchAuthStateUseCaseProvider =
    Provider<WatchAuthStateUseCase>((ref) {
  return WatchAuthStateUseCase(
    ref.watch(authRepositoryProvider),
  );
});

/// Session live (authStateChanges). Base de [currentUserProvider].
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(watchAuthStateUseCaseProvider).call();
});

/// Utilisateur connecté : seule source de vérité pour le reste de l'app.
/// Dérivé de [authStateProvider], pas une lecture Firebase séparée.
/// Pour login/register/logout (loading/error d'action), voir [authControllerProvider].
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});
