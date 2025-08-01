// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:a_chat/core/error/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw AuthException("No user found after sign in.");
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign In Failed');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw AuthException("No user found after sign up.");
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign Up Failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign Out Failed');
    }
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}