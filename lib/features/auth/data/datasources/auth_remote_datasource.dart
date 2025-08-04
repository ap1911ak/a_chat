// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:a_chat/core/error/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});
  

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
      // ตรวจสอบว่ามี user document หรือไม่ ถ้าไม่มีให้สร้าง
      final user = userCredential.user!;
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        await firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': email.split('@')[0],
          'createdAt': FieldValue.serverTimestamp(),
        });
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
    
    final user = userCredential.user!;
    final username = email.split('@')[0];
    
    // สร้าง private user document
    await firestore.collection('users').doc(user.uid).set({
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // สร้าง public user document สำหรับค้นหา
    await firestore.collection('public_users').doc(user.uid).set({
      'email': email,
      'username': username,
      'uid': user.uid,
    });
    
    return UserModel.fromFirebaseUser(user);
  } on FirebaseAuthException catch (e) {
    throw AuthException(e.message ?? 'Sign Up Failed');
  } catch (e) {
    throw AuthException('Failed to create user profile: $e');
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