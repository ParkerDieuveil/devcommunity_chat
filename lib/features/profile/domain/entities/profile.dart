class ProfileEntity {
  final String id;
  final String displayname;
  final String email;
  final String bio;
  final String avatarUrl;

  ProfileEntity({
    required this.id,
    required this.displayname,
    required this.email,
    required this.bio,
    required this.avatarUrl,
  });

  // factory ProfileEntity.fromJson(Map<String, dynamic> json) {
  //   return ProfileEntity(
  //     id: json['id'] as String,
  //     displayname: json['displayname'] as String,
  //     email: json['email'] as String,
  //     bio: json['bio'] as String,
  //     avatarUrl: json['avatarUrl'] as String,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'displayname': displayname,
  //     'email': email,
  //     'bio': bio,
  //     'avatarUrl': avatarUrl,
  //   };
  // }
}
