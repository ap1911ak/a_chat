import 'package:a_chat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:a_chat/features/auth/presentation/screen/home.dart';
import 'package:a_chat/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:a_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:a_chat/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:a_chat/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:a_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:a_chat/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_chat/injection_container.dart' as di;

void setupDependencies() {
  // Data Sources
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    firebaseAuth: FirebaseAuth.instance,
  );

  // Repositories
  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
  );

  // Use Cases
  final getConversationsUseCase = GetConversationsUseCase(chatRepository);
  final getMessagesUseCase = GetMessagesUseCase(chatRepository);
  final sendMessageUseCase = SendMessageUseCase(chatRepository);

  // ตรวจสอบว่า ChatBloc ได้รับ dependencies ถูกต้อง
  final chatBloc = ChatBloc(
    getConversationsUseCase: getConversationsUseCase,
    getMessagesUseCase: getMessagesUseCase,
    sendMessageUseCase: sendMessageUseCase,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider( // New: ChatBloc
          create: (_) => di.sl<ChatBloc>(),
        ),
        BlocProvider( // New: ContactsBloc
          create: (_) => di.sl<ContactsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.green, // Changed primary color to green
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(), // Home page will handle initial authentication flow
      ),
    );
  }
}