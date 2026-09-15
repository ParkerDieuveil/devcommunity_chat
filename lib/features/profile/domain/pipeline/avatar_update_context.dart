import '../entities/avatar_image.dart';
import '../entities/profile.dart';
import '../services/avatar_image_source.dart';

/// Contexte muté au fil du pipeline d’update avatar.
class AvatarUpdateContext {
  AvatarUpdateContext({
    required this.userId,
    required this.pickSource,
  });

  final String userId;
  final AvatarPickSource pickSource;

  String? previousPhotoUrl;
  RawAvatarImage? rawImage;
  ProcessedAvatarImage? processedImage;
  String? downloadUrl;
  ProfileEntity? updatedProfile;
}
