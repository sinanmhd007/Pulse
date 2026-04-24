import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'sign_in.dart';

class SignUp implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signUpWithEmailPassword(params.email, params.password);
  }
}
