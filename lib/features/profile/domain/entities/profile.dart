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
