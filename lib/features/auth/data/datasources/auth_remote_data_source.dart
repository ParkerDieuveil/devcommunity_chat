import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource({
    required this.firebaseAuth,
  });

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() {
    return firebaseAuth.signOut();
  }

  User? get currentUser {
    return firebaseAuth.currentUser;
  }

  Stream<User?> watchAuthState() {
    return firebaseAuth.authStateChanges();
  }
}