import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoBase64,
    required super.createdAt,
    super.emailVerified = false,
  });

  // Create UserModel from Firebase User
  // Note: photoBase64 will be set later by the data source layer
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoBase64: null, // Will be converted to base64 in data source layer
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      emailVerified: firebaseUser.emailVerified,
    );
  }

  // Convert UserModel to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoBase64': photoBase64,
      'createdAt': createdAt.toIso8601String(),
      'emailVerified': emailVerified,
    };
  }

  // Create UserModel from JSON (Hive cache)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoBase64: json['photoBase64'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoBase64,
    bool updatePhoto = false, // Flag to allow updating photo to null
    DateTime? createdAt,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoBase64: updatePhoto
          ? photoBase64
          : (photoBase64 ?? this.photoBase64),
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }
}
