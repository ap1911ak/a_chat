import 'package:a_chat/core/error/failures.dart';
import 'package:a_chat/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/contact_repository.dart';
import 'package:equatable/equatable.dart';

class AddContactUseCase implements UseCase<void, AddContactParams> {
  final ContactRepository repository;

  AddContactUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddContactParams params) async {
    // ignore: avoid_print
    print("${params.currentUserId}, ${params.contactEmail}");
    return await repository.addContact(params.currentUserId, params.contactEmail);
  }
}

class AddContactParams extends Equatable {
  final String currentUserId;
  final String contactEmail;

  const AddContactParams({required this.currentUserId, required this.contactEmail});

  @override
  List<Object> get props => [currentUserId, contactEmail];
}