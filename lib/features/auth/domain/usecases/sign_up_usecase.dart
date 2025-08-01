import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(params.email, params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  const SignUpParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}