import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({required super.uid, required super.email});

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }
}