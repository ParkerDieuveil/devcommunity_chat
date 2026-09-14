import '../repositories/profile_repository.dart';

class UpdatePushNotifications {
  final ProfileRepository repository;

  UpdatePushNotifications(this.repository);

  Future<void> call({
    required String userId,
    required bool enabled,
  }) {
    return repository.updatePushNotifications(
      userId: userId,
      enabled: enabled,
    );
  }
}
