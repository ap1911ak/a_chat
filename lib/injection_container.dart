import 'package:a_chat/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:a_chat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:a_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:a_chat/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:a_chat/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:a_chat/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:a_chat/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';



import 'package:a_chat/core/usecase/usecase.dart'; 
import 'package:a_chat/core/error/failures.dart'; 

// Features - Chat
import 'package:a_chat/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:a_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:a_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:a_chat/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:a_chat/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:a_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';

// Features - Contacts
import 'package:a_chat/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:a_chat/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:a_chat/features/contacts/domain/repositories/contact_repository.dart';
import 'package:a_chat/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:a_chat/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:a_chat/features/contacts/presentation/bloc/contacts_bloc.dart';


final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );


  // Features - Chat
sl.registerFactory(() => ChatBloc(
        getConversationsUseCase: sl(),
        getMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()));

  // Features - Contacts
  sl.registerLazySingleton(() => GetContactsUseCase(sl()));
  sl.registerLazySingleton(() => AddContactUseCase(sl()));
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ContactRemoteDataSource>(
    () => ContactRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
  
  // Bloc
  sl.registerFactory(() => ContactsBloc(
    getContactsUseCase: sl(),
    addContactUseCase: sl(),
  ));


   // External (จำเป็นสำหรับ Firebase และอื่นๆ)
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => const Uuid()); // ถ้า ChatRemoteDataSource ใช้ UUID     

}
