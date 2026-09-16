import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({
    required String email,
    required String password,
  });

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  AppUser? get currentUser;

  Stream<AppUser?> watchAuthState();
}