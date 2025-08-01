import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ConversationEntity>>> getConversations(String userID)  {
    
    return remoteDataSource.getConversations(userID)
      .map<Either<Failure, List<ConversationEntity>>>((models) {
      try {
        return  Right(models.map((model) => model as ConversationEntity).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }).handleError((error) {
      if (error is ServerException) {
        return Left(ServerFailure(error.message));
      }
      return Left(ServerFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String conversationId) {
    return remoteDataSource.getMessages(conversationId).map<Either<Failure, List<MessageEntity>>>((models) {
      try {
        return Right(models.map((model) => model as MessageEntity).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }).handleError((error) {
      if (error is ServerException) {
        return Left(ServerFailure(error.message));
      }
      return Left(ServerFailure(error.toString()));
    });
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}