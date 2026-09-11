import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.displayname,
    required super.email,
    required super.bio,
    required super.avatarUrl,
  });

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      displayname: entity.displayname,
      email: entity.email,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      displayname: json['displayname'],
      email: json['email'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayname': displayname,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }
}
