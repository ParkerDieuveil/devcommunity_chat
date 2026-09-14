import 'avatar_update_context.dart';

/// Une étape du pipeline (chaîne de traitement).
abstract interface class AvatarPipelineStep {
  Future<void> apply(AvatarUpdateContext context);
}

/// Exécute les étapes dans l’ordre ; s’arrête à la première erreur.
class AvatarUpdatePipeline {
  final List<AvatarPipelineStep> steps;

  const AvatarUpdatePipeline(this.steps);

  Future<AvatarUpdateContext> run(AvatarUpdateContext context) async {
    for (final step in steps) {
      await step.apply(context);
    }
    return context;
  }
}
