import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
// ignore: unused_import
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ConversationEntity>>> getConversations(String userID) {
    try {
      return remoteDataSource.getConversations(userID)
          .map<Either<Failure, List<ConversationEntity>>>((models) {
        return Right(models.map((model) => model as ConversationEntity).toList());
      }).handleError((error) {
        // ignore: avoid_print
        print("Repository Error: $error"); // เพิ่ม debug log
        if (error is ServerException) {
          return Left(ServerFailure(error.message));
        }
        return Left(ServerFailure(error.toString()));
      });
    } catch (e) {
      // ignore: avoid_print
      print("Repository Catch Error: $e"); // เพิ่ม debug log
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String conversationId) {
    try {
      return remoteDataSource.getMessages(conversationId)
          .map<Either<Failure, List<MessageEntity>>>((models) {
        return Right(models.map((model) => model as MessageEntity).toList());
      }).handleError((error) {
        // ignore: avoid_print
        print("Repository Error (Messages): $error"); // เพิ่ม debug log
        if (error is ServerException) {
          return Left(ServerFailure(error.message));
        }
        return Left(ServerFailure(error.toString()));
      });
    } catch (e) {
      // ignore: avoid_print
      print("Repository Catch Error (Messages): $e"); // เพิ่ม debug log
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageEntity message) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        timestamp: message.timestamp,
      );
      await remoteDataSource.sendMessage(messageModel);
      return Right(null);
    } on ServerException catch (e) {
      // ignore: avoid_print
      print("Send Message Error: ${e.message}"); // เพิ่ม debug log
      return Left(ServerFailure(e.message));
    } catch (e) {
      // ignore: avoid_print
      print("Send Message Catch Error: $e"); // เพิ่ม debug log
      return Left(ServerFailure(e.toString()));
    }
  }
}