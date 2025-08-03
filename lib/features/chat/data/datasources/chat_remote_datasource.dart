import 'package:a_chat/core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
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
      // ignore: avoid_print
      print("DataSource: Getting conversations for user: $userId"); // เพิ่ม debug log
      
      return firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        // ignore: avoid_print
        print("DataSource: Firestore snapshot received with ${snapshot.docs.length} documents"); // เพิ่ม debug log
        
        final conversations = snapshot.docs
            .map((doc) {
              try {
                // ignore: avoid_print
                print("DataSource: Processing document: ${doc.id}"); // เพิ่ม debug log
                // ignore: avoid_print
                print("DataSource: Document data: ${doc.data()}"); // เพิ่ม debug log
                return ConversationModel.fromFirestore(doc, userId);
              } catch (e) {
                // ignore: avoid_print
                print("DataSource: Error processing document ${doc.id}: $e"); // เพิ่ม debug log
                rethrow;
              }
            })
            .toList();
            
        // ignore: avoid_print
        print("DataSource: Successfully processed ${conversations.length} conversations"); // เพิ่ม debug log
        return conversations;
      });
    } catch (e) {
      // ignore: avoid_print
      print("DataSource: Error in getConversations: $e"); // เพิ่ม debug log
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String conversationID) {
    try {
      final String currentUserId = firebaseAuth.currentUser!.uid;
      // ignore: avoid_print
      print("DataSource: Getting messages for conversation: $conversationID"); // เพิ่ม debug log
      
      return firestore
          .collection('conversations')
          .doc(conversationID)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        // ignore: avoid_print
        print("DataSource: Messages snapshot received with ${snapshot.docs.length} documents"); // เพิ่ม debug log
        
        return snapshot.docs.map((doc) {
          try {
            return MessageModel.fromFirestore(doc, currentUserId);
          } catch (e) {
            // ignore: avoid_print
            print("DataSource: Error processing message ${doc.id}: $e"); // เพิ่ม debug log
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print("DataSource: Error in getMessages: $e"); // เพิ่ม debug log
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) {
        throw ServerException(message: 'User not logged in.');
      }

      // ignore: avoid_print
      print("DataSource: Sending message from $currentUserId to ${message.receiverId}"); // เพิ่ม debug log

      // Determine conversation ID based on participants
      final participants = [message.senderId, message.receiverId]..sort();
      final conversationId = participants.join('_');
      // ignore: avoid_print
      print("DataSource: Conversation ID: $conversationId"); // เพิ่ม debug log

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
              message.senderId: {'name': firebaseAuth.currentUser?.email ?? 'Unknown'},
              message.receiverId: {'name': 'Other User Name'}, // You'll need to fetch this from contacts
            },
          },
          SetOptions(merge: true),
        );
      });
      
      // ignore: avoid_print
      print("DataSource: Message sent successfully"); // เพิ่ม debug log
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print("DataSource: FirebaseException: ${e.message}"); // เพิ่ม debug log
      throw ServerException(message: '${e.message} Failed to send message.');
    } catch (e) {
      // ignore: avoid_print
      print("DataSource: General Exception: $e"); // เพิ่ม debug log
      throw ServerException(message: e.toString());
    }
  }
}