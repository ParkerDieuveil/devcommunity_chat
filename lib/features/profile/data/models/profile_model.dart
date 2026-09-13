import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.displayname,
    required super.email,
    required super.bio,
    required super.photoUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['uid'] as String? ?? map['id'] as String? ?? '',
      displayname:
          map['displayName'] as String? ?? map['displayname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      displayname: entity.displayname,
      email: entity.email,
      bio: entity.bio,
      photoUrl: entity.photoUrl,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['uid'] as String? ?? json['id'] as String? ?? '',
      displayname:
          json['displayName'] as String? ??
          json['displayname'] as String? ??
          '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'displayName': displayname,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }
}
