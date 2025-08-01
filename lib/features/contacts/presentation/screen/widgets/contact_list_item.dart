import 'package:a_chat/features/contacts/domain/entities/contact.dart';
import 'package:flutter/material.dart';

class ContactListItem extends StatelessWidget {
  final ContactEntity contact;
  final VoidCallback onTap;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.email),
        onTap: onTap,
      ),
    );
  }
}