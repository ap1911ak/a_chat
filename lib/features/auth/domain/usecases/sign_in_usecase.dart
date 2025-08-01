import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signIn(params.email, params.password);
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}