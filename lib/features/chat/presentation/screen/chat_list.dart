import 'package:a_chat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:a_chat/features/chat/domain/entities/conversation.dart';
import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:a_chat/features/chat/presentation/screen/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:a_chat/features/contacts/presentation/screen/contacts.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Dispatch event to load conversations when the page initializes
      BlocProvider.of<ChatBloc>(context).add(GetConversationsEvent(currentUser.uid));
    }
  // ignore: avoid_print
  print("UID : ${GetConversationsEvent(currentUser!.uid)}");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate based on selected index
    if (index == 0) {
      // Stay on Chat List Page
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsScreen()));
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings page not implemented yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(AuthSignOutRequested());
              // Navigate back to HomePage (login/register) after logout
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatListScreen())); // Or HomePage
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          // ignore: avoid_print
          print("ChatLoading $ChatLoading");

          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text("No conversations yet. Start a new chat from Contacts."));
            }
            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return ConversationListItem(
                  conversation: conversation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageScreen(
                          conversationId: conversation.id,
                          otherParticipantId: conversation.otherParticipantId,
                          otherParticipantName: conversation.otherParticipantName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Welcome to Chat App!"));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class ConversationListItem extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            conversation.otherParticipantName.isNotEmpty
                ? conversation.otherParticipantName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.green),
          ),
        ),
        title: Text(
          conversation.otherParticipantName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${conversation.timestamp.hour}:${conversation.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}