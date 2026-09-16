/// Profil côté Firestore, pas le même truc que AppUser (auth).
class UserProfileEntity {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  const UserProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastSeen,
    required this.isOnline,
  });
}
