import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when user photo is being uploaded
class AuthPhotoUploading extends AuthState {
  final UserModel user;

  const AuthPhotoUploading(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when Google sign in is pending confirmation
class GoogleSignInPending extends AuthState {
  final UserModel user;

  const GoogleSignInPending(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when an error occurs during authentication
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
