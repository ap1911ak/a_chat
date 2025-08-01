import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase implements UseCase<Stream<List<MessageEntity>>, String> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<MessageEntity>>>> call(String conversationId) async {
    return Right(repository.getMessages(conversationId).map((either) => either.fold((l) => throw l, (r) => r)));
  }
}