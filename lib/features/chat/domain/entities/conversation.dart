import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String lastMessage;
  final DateTime timestamp;
  final String otherParticipantName; // Name of the other person in chat
  final String otherParticipantId; // ID of the other person in chat

  const ConversationEntity({
    required this.id,
    required this.lastMessage,
    required this.timestamp,
    required this.otherParticipantName,
    required this.otherParticipantId,
  });

  @override
  List<Object> get props => [id, lastMessage, timestamp, otherParticipantName, otherParticipantId];
}