import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id; // User ID of the contact
  final String email;
  final String name; // Display name of the contact

  const ContactEntity({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [id, email, name];
}