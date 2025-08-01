import 'package:a_chat/core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // For generating message IDs
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ConversationModel>> getConversations(String userId);
  Stream<List<MessageModel>> getMessages(String conversationId);
  Future<void> sendMessage(MessageModel message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final Uuid uuid;

  ChatRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth}) : uuid = const Uuid();

  @override
  Stream<List<ConversationModel>> getConversations(String userId) {
    try {
      // ignore: unused_local_variable
      final String currentUserId = firebaseAuth.currentUser!.uid; 
      
      return firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc, userId))
            .toList();
      });
    } catch (e) {
      throw ServerException(message:e.toString());
    }
  }

 @override
  Stream<List<MessageModel>> getMessages(String conversationID) {
  try {
      final String currentUserId = firebaseAuth.currentUser!.uid;
      return firestore
        .collection('conversations')
        .doc(conversationID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc, currentUserId)).toList();
        });
  } catch (e) {
    throw ServerException(message:e.toString());
  }
}

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) {
        throw ServerException(message: 'User not logged in.');
      }

      // Determine conversation ID based on participants
      // For simplicity, assume conversation ID is a combination of sorted user IDs
      final participants = [message.senderId, message.receiverId]..sort();
      final conversationId = participants.join('_');

      final conversationRef = firestore.collection('conversations').doc(conversationId);
      final messageId = uuid.v4();

      await firestore.runTransaction((transaction) async {
        // Add message to messages subcollection
        transaction.set(
          conversationRef.collection('messages').doc(messageId),
          message.toMap(),
        );

        // Update conversation last message and timestamp
        transaction.set(
          conversationRef,
          {
            'lastMessage': message.content,
            'timestamp': message.timestamp,
            'participants': participants,
            'participantDetails': {
              message.senderId: {'name': firebaseAuth.currentUser?.email ?? 'Unknown'}, // Assuming email as name
              message.receiverId: {'name': 'Other User Name'}, // You'll need to fetch this from contacts
            },
          },
          SetOptions(merge: true), // Merge to update existing fields
        );
      });
    } on FirebaseException catch (e) {
      // ignore: prefer_interpolation_to_compose_strings
      throw ServerException(message: e.toString()+'Failed to send message.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}