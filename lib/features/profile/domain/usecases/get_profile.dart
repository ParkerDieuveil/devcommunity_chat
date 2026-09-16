import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<ProfileEntity?> call(String userId) async {
    return await repository.getProfile(userId);
  }
}
