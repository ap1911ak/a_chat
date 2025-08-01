import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'package:uuid/uuid.dart'; // For generating message IDs
import '../../../../core/error/failures.dart';
// ignore: unused_import
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Directly access for current user ID
  final Uuid uuid = const Uuid();

  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<ConversationsUpdatedEvent>(_onConversationsUpdated);
    on<GetMessagesEvent>(_onGetMessages);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    _conversationsSubscription?.cancel(); // Cancel previous subscription

    final result = await getConversationsUseCase(event.userId);
    result.fold(
      (failure) => emit(ChatError(_mapFailureToMessage(failure))),
      (stream) {
        _conversationsSubscription = stream.listen(
          (conversations) => add(ConversationsUpdatedEvent(conversations)),
          onError: (error) => emit(ChatError(error.toString())),
        );
      },
    );
  }

  void _onConversationsUpdated(
    ConversationsUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(ConversationsLoaded(event.conversations));
  }

  Future<void> _onGetMessages(
    GetMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    _messagesSubscription?.cancel(); // Cancel previous subscription

    final result = await getMessagesUseCase(event.conversationId);
    result.fold(
      (failure) => emit(ChatError(_mapFailureToMessage(failure))),
      (stream) {
        _messagesSubscription = stream.listen(
          (messages) => add(MessagesUpdatedEvent(messages)),
          onError: (error) => emit(ChatError(error.toString())),
        );
      },
    );
  }

  void _onMessagesUpdated(
    MessagesUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(MessagesLoaded(event.messages));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      emit(const ChatError('User not logged in. Cannot send message.'));
      return;
    }

    final message = MessageEntity(
      id: uuid.v4(), // Generate unique ID for message
      senderId: currentUserId,
      receiverId: event.receiverId,
      content: event.content,
      timestamp: DateTime.now(),
    );

    final result = await sendMessageUseCase(message);
    result.fold(
      (failure) => emit(ChatError(_mapFailureToMessage(failure))),
      (_) => emit(MessageSentSuccess()), // Indicate success, then reload messages or update UI
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      // ignore: type_literal_in_constant_pattern
      case ServerFailure:
        return (failure as ServerFailure).message;
      default:
        return 'Unexpected error';
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}