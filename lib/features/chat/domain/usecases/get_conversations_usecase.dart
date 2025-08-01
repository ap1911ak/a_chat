import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase implements UseCase<Stream<List<ConversationEntity>>, String> {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<ConversationEntity>>>> call(String userId) async {
    return Right(repository.getConversations(userId).map((either) => either.fold((l) => throw l, (r) => r)));
  }
}