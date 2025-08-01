part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object> get props => [];
}

class GetContactsEvent extends ContactsEvent {
  final String userId;
  const GetContactsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class ContactsUpdatedEvent extends ContactsEvent {
  final List<ContactEntity> contacts;
  const ContactsUpdatedEvent(this.contacts);

  @override
  List<Object> get props => [contacts];
}

class AddContactEvent extends ContactsEvent {
  final String contactEmail;
  const AddContactEvent(this.contactEmail);

  @override
  List<Object> get props => [contactEmail];
}