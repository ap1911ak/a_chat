import 'package:a_chat/core/error/failures.dart';
import 'package:a_chat/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';

class GetContactsUseCase implements UseCase<Stream<List<ContactEntity>>, String> {
  final ContactRepository repository;

  GetContactsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<ContactEntity>>>> call(String userId) async {
    return Right(repository.getContacts(userId).map((either) => either.fold((l) => throw l, (r) => r)));
  }
}