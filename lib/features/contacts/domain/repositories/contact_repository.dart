import 'package:a_chat/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/contact.dart';

abstract class ContactRepository {
  Stream<Either<Failure, List<ContactEntity>>> getContacts(String userId);
  Future<Either<Failure, void>> addContact(String currentUserId, String contactEmail);
}