import '../../exceptions/profile_exceptions.dart';
import '../../repositories/profile_avatar_storage.dart';
import '../../repositories/profile_repository.dart';
import '../../services/avatar_image_processor.dart';
import '../../services/avatar_image_source.dart';
import '../../services/avatar_validator.dart';
import '../avatar_update_context.dart';
import '../avatar_update_pipeline.dart';

class LoadPreviousPhotoStep implements AvatarPipelineStep {
  final ProfileRepository profiles;

  const LoadPreviousPhotoStep(this.profiles);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final profile = await profiles.getProfile(context.userId);
    context.previousPhotoUrl = profile?.photoUrl;
  }
}

class PickAvatarStep implements AvatarPipelineStep {
  final AvatarImageSource source;

  const PickAvatarStep(this.source);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final picked = await source.pick(context.pickSource);
    if (picked == null) {
      throw const AvatarSelectionCancelled();
    }
    context.rawImage = picked;
  }
}

class ValidateRawAvatarStep implements AvatarPipelineStep {
  final AvatarValidator validator;

  const ValidateRawAvatarStep(this.validator);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final raw = context.rawImage;
    if (raw == null) {
      throw const AvatarValidationException('Aucune image à valider.');
    }
    validator.validateRaw(raw);
  }
}

class ProcessAvatarStep implements AvatarPipelineStep {
  final AvatarImageProcessor processor;
  final AvatarValidator validator;

  const ProcessAvatarStep(this.processor, this.validator);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final raw = context.rawImage;
    if (raw == null) {
      throw const AvatarProcessingException('Aucune image à traiter.');
    }
    final processed = await processor.process(raw);
    validator.validateProcessed(processed);
    context.processedImage = processed;
  }
}

class UploadAvatarStep implements AvatarPipelineStep {
  final ProfileAvatarStorage storage;

  const UploadAvatarStep(this.storage);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final processed = context.processedImage;
    if (processed == null) {
      throw const AvatarUploadException('Aucune image prête à uploader.');
    }
    context.downloadUrl = await storage.uploadAvatar(
      userId: context.userId,
      image: processed,
    );
  }
}

class PersistAvatarUrlStep implements AvatarPipelineStep {
  final ProfileRepository profiles;

  const PersistAvatarUrlStep(this.profiles);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final url = context.downloadUrl;
    if (url == null || url.isEmpty) {
      throw const AvatarUploadException('URL de téléchargement manquante.');
    }
    context.updatedProfile = await profiles.updatePhotoUrl(
      userId: context.userId,
      photoUrl: url,
    );
  }
}

class CleanupPreviousAvatarStep implements AvatarPipelineStep {
  final ProfileAvatarStorage storage;

  const CleanupPreviousAvatarStep(this.storage);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final previous = context.previousPhotoUrl;
    final current = context.downloadUrl;
    if (previous == null || previous.isEmpty || previous == current) {
      return;
    }
    try {
      await storage.deleteOwnedAvatarUrl(previous);
    } catch (_) {
      // best-effort : ne bloque pas le succès de l’upload
    }
  }
}
