import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:a_chat/features/chat/presentation/screen/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageScreen extends StatefulWidget {
  final String conversationId;
  final String otherParticipantId;
  final String otherParticipantName;

  const MessageScreen({
    super.key,
    required this.conversationId,
    required this.otherParticipantId,
    required this.otherParticipantName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Dispatch event to load messages for this conversation
    BlocProvider.of<ChatBloc>(context).add(GetMessagesEvent(widget.conversationId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      BlocProvider.of<ChatBloc>(context).add(
        SendMessageEvent(
          receiverId: widget.otherParticipantId,
          content: _messageController.text.trim(),
        ),
      );
      _messageController.clear();
      // Scroll to bottom after sending message
      _scrollController.animateTo(
        0.0, // Scroll to the top (new messages are at the top due to descending order)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherParticipantName),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is MessageSentSuccess) {
                    // Message sent, now reload messages to show the new one
                    BlocProvider.of<ChatBloc>(context).add(GetMessagesEvent(widget.conversationId));
                  } else if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading && state is! MessagesLoaded) { // Only show loading if not already loaded
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return const Center(child: Text("Say hello!"));
                    }
                    return ListView.builder(
                      reverse: true, // Display latest messages at the bottom
                      controller: _scrollController,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId == currentUserId;
                        return MessageBubble(
                          message: message.content,
                          isMe: isMe,
                          timestamp: message.timestamp,
                        );
                      },
                    );
                  }
                  return const Center(child: Text("Start chatting!"));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Write your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}