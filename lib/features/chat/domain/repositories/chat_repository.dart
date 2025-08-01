import 'package:a_chat/core/error/failures.dart';
import 'package:a_chat/features/chat/domain/entities/conversation.dart';
import 'package:a_chat/features/chat/domain/entities/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ConversationEntity>>> getConversations(String userId);
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String conversationId);
  Future<Either<Failure, void>> sendMessage(MessageEntity message);
}