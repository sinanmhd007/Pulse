import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw AuthException('User not found.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw AuthException('Failed to create account.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Google sign in aborted.');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw AuthException('Google sign in failed.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  AuthException _handleFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found for that email.');
      case 'wrong-password':
        return AuthException('Wrong password provided.');
      case 'email-already-in-use':
        return AuthException('The account already exists for that email.');
      case 'weak-password':
        return AuthException('The password provided is too weak.');
      default:
        return AuthException(e.message ?? 'An unknown error occurred.');
    }
  }
}
