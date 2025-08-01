part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class GetConversationsEvent extends ChatEvent {
  final String userId;
  const GetConversationsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class ConversationsUpdatedEvent extends ChatEvent {
  final List<ConversationEntity> conversations;
  const ConversationsUpdatedEvent(this.conversations);

  @override
  List<Object> get props => [conversations];
}

class GetMessagesEvent extends ChatEvent {
  final String conversationId;
  const GetMessagesEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class MessagesUpdatedEvent extends ChatEvent {
  final List<MessageEntity> messages;
  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}

class SendMessageEvent extends ChatEvent {
  final String receiverId;
  final String content;
  const SendMessageEvent({required this.receiverId, required this.content});

  @override
  List<Object> get props => [receiverId, content];
}