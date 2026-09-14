import '../entities/profile.dart';
import '../exceptions/profile_exceptions.dart';
import '../pipeline/avatar_update_context.dart';
import '../pipeline/avatar_update_pipeline.dart';
import '../services/avatar_image_source.dart';

/// Orchestration unique : pick → validate → process → upload → Firestore.
class UpdateProfileAvatar {
  final AvatarUpdatePipeline pipeline;

  UpdateProfileAvatar(this.pipeline);

  /// Retourne le profil mis à jour, ou `null` si l’utilisateur annule.
  Future<ProfileEntity?> call({
    required String userId,
    required AvatarPickSource source,
  }) async {
    try {
      final result = await pipeline.run(
        AvatarUpdateContext(userId: userId, pickSource: source),
      );
      return result.updatedProfile;
    } on AvatarSelectionCancelled {
      return null;
    }
  }
}
