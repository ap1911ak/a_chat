import 'package:a_chat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:a_chat/features/auth/presentation/screen/home.dart';
import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:a_chat/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_chat/injection_container.dart' as di;


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