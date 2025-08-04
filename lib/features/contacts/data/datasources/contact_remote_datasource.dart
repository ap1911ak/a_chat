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
    // ค้นหาใน public_users collection
    final userQuery = await firestore
        .collection('public_users')  // เปลี่ยนเป็น public_users
        .where('email', isEqualTo: contactEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw ServerException(message: 'User with email "$contactEmail" does not exist.');
    }

    final contactDoc = userQuery.docs.first;
    final contactData = contactDoc.data();
    final contactId = contactData['uid']; // ใช้ uid จาก public_users
    final contactName = contactData['username'] ?? contactEmail;

    // เหลือโค้ดเหมือนเดิม...
  } catch (e) {
    // error handling...
  }
}
}