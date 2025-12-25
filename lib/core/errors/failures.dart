import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(super.message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure(super.message);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure(super.message);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure(super.message);
}

class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure(super.message);
}

class UserDisabledFailure extends Failure {
  const UserDisabledFailure(super.message);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure(super.message);
}

class OperationNotAllowedFailure extends Failure {
  const OperationNotAllowedFailure(super.message);
}

// Validation failures for Community feature
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
