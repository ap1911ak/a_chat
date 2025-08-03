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
    try {
      // ignore: avoid_print
      print("UseCase: Getting conversations for user: $userId"); // เพิ่ม debug log
      
      final stream = repository.getConversations(userId).asyncMap((either) async {
        return either.fold(
          (failure) {
            // ignore: avoid_print
            print("UseCase Error: ${failure.toString()}"); // เพิ่ม debug log
            throw failure;
          },
          (conversations) {
            // ignore: avoid_print
            print("UseCase Success: ${conversations.length} conversations found"); // เพิ่ม debug log
            return conversations;
          },
        );
      });
      
      return Right(stream);
    } catch (e) {
      // ignore: avoid_print
      print("UseCase Catch Error: $e"); // เพิ่ม debug log
      return Left(ServerFailure(e.toString()));
    }
  }
}