import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.displayname,
    required super.email,
    required super.bio,
    required super.photoUrl,
    super.title,
    super.pushNotificationsEnabled,
    super.createdAt,
    super.lastSeen,
    super.isOnline,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel.fromJson(map);
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      displayname: entity.displayname,
      email: entity.email,
      bio: entity.bio,
      photoUrl: entity.photoUrl,
      title: entity.title,
      pushNotificationsEnabled: entity.pushNotificationsEnabled,
      createdAt: entity.createdAt,
      lastSeen: entity.lastSeen,
      isOnline: entity.isOnline,
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
      title: json['title'] as String? ?? '',
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      createdAt: _readDateTime(json['createdAt']),
      lastSeen: _readDateTime(json['lastSeen']),
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  /// Champs profil éditables / affichés. Merge Firestore : ne pas écraser
  /// les champs présence gérés ailleurs (`isOnline`, `lastSeen`, …).
  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'displayName': displayname,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'title': title,
      'pushNotificationsEnabled': pushNotificationsEnabled,
    };
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
