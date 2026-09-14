import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/profile/domain/entities/avatar_image.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:devcommunitychat/features/profile/domain/pipeline/avatar_update_pipeline.dart';
import 'package:devcommunitychat/features/profile/domain/pipeline/steps/avatar_pipeline_steps.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_avatar_storage.dart';
import 'package:devcommunitychat/features/profile/domain/services/avatar_image_processor.dart';
import 'package:devcommunitychat/features/profile/domain/services/avatar_image_source.dart';
import 'package:devcommunitychat/features/profile/domain/services/avatar_validator.dart';
import 'package:devcommunitychat/features/profile/domain/usecases/update_profile_avatar.dart';

import '../fakes/fake_profile_repository.dart';

class _FakeSource implements AvatarImageSource {
  RawAvatarImage? image;

  _FakeSource(this.image);

  @override
  Future<RawAvatarImage?> pick(AvatarPickSource source) async => image;
}

class _FakeProcessor implements AvatarImageProcessor {
  @override
  Future<ProcessedAvatarImage> process(RawAvatarImage raw) async {
    return ProcessedAvatarImage(bytes: raw.bytes);
  }
}

class _FakeStorage implements ProfileAvatarStorage {
  String? lastUserId;
  ProcessedAvatarImage? lastImage;
  final deletedUrls = <String>[];

  @override
  Future<String> uploadAvatar({
    required String userId,
    required ProcessedAvatarImage image,
  }) async {
    lastUserId = userId;
    lastImage = image;
    return 'https://cdn.example/users/$userId/avatar/profile.jpg';
  }

  @override
  Future<void> deleteOwnedAvatarUrl(String? photoUrl) async {
    if (photoUrl != null) deletedUrls.add(photoUrl);
  }
}

void main() {
  group('AvatarValidator', () {
    const validator = AvatarValidator();

    test('rejette un fichier vide', () {
      expect(
        () => validator.validateRaw(const RawAvatarImage(bytes: [])),
        throwsA(isA<AvatarValidationException>()),
      );
    });

    test('rejette un mime non supporté', () {
      expect(
        () => validator.validateRaw(
          RawAvatarImage(bytes: List.filled(10, 1), mimeType: 'application/pdf'),
        ),
        throwsA(isA<AvatarValidationException>()),
      );
    });
  });

  group('UpdateProfileAvatar pipeline', () {
    test('annulation → null sans toucher Storage', () async {
      final profiles = FakeProfileRepository(
        profile: const ProfileEntity(
          id: 'u1',
          displayname: 'Alex',
          email: 'a@b.c',
          bio: '',
          photoUrl: 'https://old',
        ),
      );
      final storage = _FakeStorage();
      final useCase = UpdateProfileAvatar(
        AvatarUpdatePipeline([
          LoadPreviousPhotoStep(profiles),
          PickAvatarStep(_FakeSource(null)),
          ValidateRawAvatarStep(const AvatarValidator()),
          ProcessAvatarStep(_FakeProcessor(), const AvatarValidator()),
          UploadAvatarStep(storage),
          PersistAvatarUrlStep(profiles),
          CleanupPreviousAvatarStep(storage),
        ]),
      );

      final result = await useCase.call(
        userId: 'u1',
        source: AvatarPickSource.gallery,
      );

      expect(result, isNull);
      expect(storage.lastImage, isNull);
      expect(profiles.profile?.photoUrl, 'https://old');
    });

    test('galerie → upload + persist photoUrl + cleanup', () async {
      final profiles = FakeProfileRepository(
        profile: const ProfileEntity(
          id: 'u1',
          displayname: 'Alex',
          email: 'a@b.c',
          bio: '',
          photoUrl: 'https://cdn.example/users/u1/avatar/old.jpg',
        ),
      );
      final storage = _FakeStorage();
      final raw = RawAvatarImage(
        bytes: List.filled(64, 7),
        mimeType: 'image/jpeg',
      );

      final useCase = UpdateProfileAvatar(
        AvatarUpdatePipeline([
          LoadPreviousPhotoStep(profiles),
          PickAvatarStep(_FakeSource(raw)),
          ValidateRawAvatarStep(const AvatarValidator()),
          ProcessAvatarStep(_FakeProcessor(), const AvatarValidator()),
          UploadAvatarStep(storage),
          PersistAvatarUrlStep(profiles),
          CleanupPreviousAvatarStep(storage),
        ]),
      );

      final result = await useCase.call(
        userId: 'u1',
        source: AvatarPickSource.gallery,
      );

      expect(result?.photoUrl, contains('profile.jpg'));
      expect(storage.lastUserId, 'u1');
      expect(profiles.profile?.photoUrl, result?.photoUrl);
      expect(storage.deletedUrls, ['https://cdn.example/users/u1/avatar/old.jpg']);
    });
  });
}
