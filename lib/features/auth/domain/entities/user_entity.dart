import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoBase64;
  final DateTime createdAt;
  final bool emailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoBase64,
    required this.createdAt,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoBase64,
    createdAt,
    emailVerified,
  ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }
}
