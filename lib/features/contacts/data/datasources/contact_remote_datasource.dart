import 'package:a_chat/core/error/exceptions.dart';
import 'package:a_chat/features/contacts/data/models/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // 1. ค้นหาผู้ใช้จากอีเมลใน Collection 'users'
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: contactEmail)
        .limit(1)
        .get();

    // 2. ตรวจสอบว่าพบผู้ใช้หรือไม่
    if (userQuery.docs.isEmpty) {
      throw ServerException(message: 'User with this email does not exist.');
    }

    final contactDoc = userQuery.docs.first;
    final contactId = contactDoc.id;
    final contactData = contactDoc.data();
    final contactName = contactData['username'] ?? contactEmail; // ใช้ username หรือ email เป็นชื่อ

    // 3. ป้องกันการเพิ่มตัวเองเป็นผู้ติดต่อ
    if (contactId == currentUserId) {
      throw ServerException(message: 'You cannot add yourself as a contact.');
    }

    // 4. เพิ่มผู้ติดต่อเข้าไปใน Collection ย่อย 'contacts' ของผู้ใช้ปัจจุบัน
    final currentUserContactsRef = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts');
    
    // ตรวจสอบว่าผู้ติดต่อถูกเพิ่มไปแล้วหรือยัง
    final existingContact = await currentUserContactsRef
        .doc(contactId)
        .get();

    if (existingContact.exists) {
        throw ServerException(message: 'Contact already exists.');
    }

    // เพิ่มผู้ติดต่อใหม่
    await currentUserContactsRef.doc(contactId).set({
      'name': contactName,
      'email': contactEmail,
      'addedAt': FieldValue.serverTimestamp(),
    });

  } on FirebaseException catch (e) {
    // จัดการข้อผิดพลาดที่มาจาก Firebase
    throw ServerException(message: e.message ?? 'An unknown Firebase error occurred.');
  } on ServerException {
    // ส่งต่อ ServerException ที่สร้างขึ้นเอง
    rethrow;
  } catch (e) {
    // จัดการข้อผิดพลาดอื่นๆ ที่ไม่คาดคิด
    throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
  }
}
}