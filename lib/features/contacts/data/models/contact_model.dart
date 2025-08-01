import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory ContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? data['email'] ?? '', // Use email as fallback for name
    );
  }

  ContactEntity toEntity() {
        return ContactEntity(
          id: id,
          email: email,
          name: name,
        );
  }
} 