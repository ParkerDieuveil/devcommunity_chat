import '../entities/avatar_image.dart';

enum AvatarPickSource { gallery, camera }

abstract interface class AvatarImageSource {
  Future<RawAvatarImage?> pick(AvatarPickSource source);
}
