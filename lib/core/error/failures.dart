import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error. Please try again later.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local data.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network and try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
