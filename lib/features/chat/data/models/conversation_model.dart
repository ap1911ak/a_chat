import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/conversation.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.lastMessage,
    required super.timestamp,
    required super.otherParticipantName,
    required super.otherParticipantId,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> participants = data['participants'];
    final Map<String, dynamic> participantDetails = data['participantDetails'];

    String otherParticipantId = '';
    String otherParticipantName = 'Unknown';

    for (var participantId in participants) {
      if (participantId != currentUserId) {
        otherParticipantId = participantId;
        otherParticipantName = participantDetails[participantId]?['name'] ?? 'Unknown';
        break;
      }
    }

    return ConversationModel(
      id: doc.id,
      lastMessage: data['lastMessage'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      otherParticipantName: otherParticipantName,
      otherParticipantId: otherParticipantId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'timestamp': Timestamp.fromDate(timestamp),
      // participantDetails and participants will be handled in data source
    };
  }
  static ConversationModel fromSnapshot(DocumentSnapshot doc) {
    return ConversationModel.fromFirestore(doc, '');
  }
}