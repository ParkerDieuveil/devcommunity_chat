import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<AppUser?> call() {
    return repository.watchAuthState();
  }
}