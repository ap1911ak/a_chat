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
    try {
      // ignore: avoid_print
      print("UseCase: Getting messages for conversation: $conversationId"); // เพิ่ม debug log
      
      final stream = repository.getMessages(conversationId).asyncMap((either) async {
        return either.fold(
          (failure) {
            // ignore: avoid_print
            print("UseCase Error (Messages): ${failure.toString()}"); // เพิ่ม debug log
            throw failure;
          },
          (messages) {
            // ignore: avoid_print
            print("UseCase Success (Messages): ${messages.length} messages found"); // เพิ่ม debug log
            return messages;
          },
        );
      });
      
      return Right(stream);
    } catch (e) {
      // ignore: avoid_print
      print("UseCase Catch Error (Messages): $e"); // เพิ่ม debug log
      return Left(ServerFailure(e.toString()));
    }
  }
}