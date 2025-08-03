import 'package:a_chat/core/error/exceptions.dart';
import 'package:a_chat/features/contacts/data/models/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:a_chat/model/profile.dart';

abstract class ContactRemoteDataSource {
  Stream<List<ContactModel>> getContacts(String userId);
  Future<void> addContact(String currentUserId, String contactEmail);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ContactRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth});
  
 @override
  Stream<List<ContactModel>> getContacts(String userId) {
    // ไม่ต้องมี try-catch ที่นี่ เพราะ Stream ของ Firestore จะจัดการ Error ด้วยตัวเอง
    // และส่ง error ออกมาทาง Stream ถ้ามีปัญหา
    return firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .snapshots() // Stream<QuerySnapshot<Map<String, dynamic>>>
        .map((snapshot) {
      // Map QuerySnapshot ไปเป็น List<ContactModel>
      return snapshot.docs.map((doc) => ContactModel.fromFirestore(doc)).toList();
    });
    // ถ้ามี error จาก Firestore เช่น network issue, snapshots() จะส่ง error ออกมาใน Stream
    // และ error นั้นจะถูกจับใน Repository
  }

 @override
Future<void> addContact(String currentUserId, String contactEmail) async {
  try {
    print("Adding contact: $contactEmail for user: $currentUserId");
    
    // 1. ตรวจสอบว่า currentUser มี document ใน users collection หรือไม่
    final currentUserDoc = await firestore.collection('users').doc(currentUserId).get();
    if (!currentUserDoc.exists) {
      throw ServerException(message: 'Current user profile not found. Please re-login.');
    }
    
    // 2. ค้นหาผู้ใช้จากอีเมล
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: contactEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw ServerException(message: 'User with this email does not exist.');
    }

    final contactDoc = userQuery.docs.first;
    final contactId = contactDoc.id;
    final contactData = contactDoc.data();
    final contactName = contactData['username'] ?? contactEmail;

    if (contactId == currentUserId) {
      throw ServerException(message: 'You cannot add yourself as a contact.');
    }

    // 3. เพิ่มผู้ติดต่อ
    final currentUserContactsRef = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts');
    
    final existingContact = await currentUserContactsRef.doc(contactId).get();
    if (existingContact.exists) {
        throw ServerException(message: 'Contact already exists.');
    }

    await currentUserContactsRef.doc(contactId).set({
      'name': contactName,
      'email': contactEmail,
      'addedAt': FieldValue.serverTimestamp(),
    });
    
    print("Contact added successfully");

  } catch (e) {
    print("Error adding contact: $e");
    if (e is ServerException) {
      rethrow;
    }
    throw ServerException(message: 'Failed to add contact: ${e.toString()}');
  }
}
}