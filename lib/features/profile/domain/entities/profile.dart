class ProfileEntity {
  final String id;
  final String displayname;
  final String email;
  final String bio;
  final String photoUrl;

  /// Titre / rôle affiché sous le @username (ex. "Mobile Engineer").
  final String title;

  /// Préférence notifications push (persistée Firestore).
  final bool pushNotificationsEnabled;

  final DateTime? createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  /// Au-delà de ce délai sans heartbeat, on n'affiche plus « en ligne ».
  static const presenceTtl = Duration(minutes: 2);

  const ProfileEntity({
    required this.id,
    required this.displayname,
    required this.email,
    required this.bio,
    required this.photoUrl,
    this.title = '',
    this.pushNotificationsEnabled = true,
    this.createdAt,
    this.lastSeen,
    this.isOnline = false,
  });

  /// Présence affichable : flag Firestore + `lastSeen` récent (anti-faux positifs).
  bool get isEffectivelyOnline {
    if (!isOnline) return false;
    final seen = lastSeen;
    if (seen == null) return false;
    final age = DateTime.now().difference(seen);
    if (age.isNegative) return true;
    return age <= presenceTtl;
  }

  ProfileEntity copyWith({
    String? id,
    String? displayname,
    String? email,
    String? bio,
    String? photoUrl,
    String? title,
    bool? pushNotificationsEnabled,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      displayname: displayname ?? this.displayname,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      title: title ?? this.title,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
