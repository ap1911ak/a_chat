import 'package:a_chat/features/chat/presentation/screen/message.dart';
import 'package:a_chat/features/contacts/presentation/screen/new_contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_chat/features/contacts/domain/entities/contact.dart';
import 'package:a_chat/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:a_chat/features/contacts/presentation/widgets/contact_list_item.dart';
import 'package:a_chat/injection_container.dart' as sl;

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Dispatch event to load conversations when the page initializes
      BlocProvider.of<ContactsBloc>(context).add(GetContactsEvent(currentUser.uid));
    }
  // ignore: avoid_print
  print("UID : ${GetContactsEvent(currentUser!.uid)}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              BlocProvider<ContactsBloc>(
                                                create: (_) => sl.sl<ContactsBloc>(),
                                                child: NewContactScreen(),
                                              )));
              
            },
          ),
        ],
      ),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          if (state is ContactsLoaded) {
            if (state.contacts.isEmpty) {
              return const Center(child: Text("No contacts yet. Add a new contact."));
            }
            // Group contacts by first letter (for UI like the image)
            final Map<String, List<ContactEntity>> groupedContacts = {};
            for (var contact in state.contacts) {
              final firstLetter = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#';
              if (!groupedContacts.containsKey(firstLetter)) {
                groupedContacts[firstLetter] = [];
              }
              groupedContacts[firstLetter]!.add(contact);
            }

            final sortedKeys = groupedContacts.keys.toList()..sort();
            
            return ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final contactsInGroup = groupedContacts[key]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...contactsInGroup.map((contact) => ContactListItem(
                      contact: contact,
                      onTap: () {
                        // When a contact is tapped, navigate to the MessagePage
                        // You'll need to create a conversation ID or find an existing one
                        // For simplicity, let's create a dummy conversation ID for now
                        // In a real app, you'd check if a conversation exists or create one.
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                        if (currentUserId != null) {
                          final participants = [currentUserId, contact.id]..sort();
                          final conversationId = participants.join('_');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageScreen(
                                conversationId: conversationId,
                                otherParticipantId: contact.id,
                                otherParticipantName: contact.name,
                              ),
                            ),
                          );
                        }
                      },
                    )),
                  ],
                );
              },
            );
          } else if (state is ContactsError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Load contacts..."));
        },
      ),
    );
  }
}
