import 'dart:async';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/domain/repositories/auth_repository.dart';

/// Fake en mémoire de [AuthRepository], utilisé pour tester la logique
/// de login/register/logout sans dépendre de Firebase.
class FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;
  Exception? logoutError;
  AppUser? _currentUser;
  final _controller = StreamController<AppUser?>.broadcast();

  void dispose() => _controller.close();

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutError != null) {
      throw logoutError!;
    }
    _currentUser = null;
    _controller.add(null);
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> watchAuthState() => _controller.stream;
}
