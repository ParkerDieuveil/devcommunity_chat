import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class WatchProfile {
  final ProfileRepository repository;

  WatchProfile(this.repository);

  Stream<ProfileEntity?> call(String userId) {
    return repository.watchProfile(userId);
  }
}
