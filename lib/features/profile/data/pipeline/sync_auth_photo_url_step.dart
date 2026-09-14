import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/pipeline/avatar_update_context.dart';
import '../../domain/pipeline/avatar_update_pipeline.dart';

/// Aligne `FirebaseAuth.photoURL` (best-effort). L’UI profil lit Firestore.
class SyncAuthPhotoUrlStep implements AvatarPipelineStep {
  final FirebaseAuth auth;

  const SyncAuthPhotoUrlStep(this.auth);

  @override
  Future<void> apply(AvatarUpdateContext context) async {
    final url = context.downloadUrl;
    final user = auth.currentUser;
    if (url == null || user == null || user.uid != context.userId) return;
    try {
      await user.updatePhotoURL(url);
    } catch (_) {}
  }
}
