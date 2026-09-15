import '../../../profile/domain/entities/profile.dart';

/// Autres participants d'un chat (hors utilisateur courant).
List<ProfileEntity> findOtherProfiles({
  required Iterable<String> participantIds,
  required String currentUserId,
  required List<ProfileEntity> profiles,
}) {
  final result = <ProfileEntity>[];
  for (final id in participantIds) {
    if (id == currentUserId) continue;
    for (final profile in profiles) {
      if (profile.id == id) {
        result.add(profile);
        break;
      }
    }
  }
  return result;
}

/// Titre affiché pour une conversation (1-1 ou groupe).
String chatDisplayTitle(
  List<ProfileEntity> others, {
  required String emptyFallback,
  required String multiFallback,
}) {
  if (others.isEmpty) return emptyFallback;
  if (others.length == 1) {
    final name = others.first.displayname.trim();
    if (name.isNotEmpty) return name;
    final email = others.first.email.trim();
    return email.isNotEmpty ? email : emptyFallback;
  }
  final names = others
      .map((p) {
        final name = p.displayname.trim();
        return name.isNotEmpty ? name : p.email.split('@').first;
      })
      .where((n) => n.isNotEmpty)
      .take(3)
      .join(', ');
  return names.isEmpty ? multiFallback : names;
}

String nameInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed[0].toUpperCase();
}
