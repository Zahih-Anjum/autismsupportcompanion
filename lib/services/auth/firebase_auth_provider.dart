import 'package:autismcompanionsupport/firebase_options.dart';
import 'package:autismcompanionsupport/services/auth/auth_exceptions.dart';
import 'package:autismcompanionsupport/services/auth/auth_provider.dart';
import 'package:autismcompanionsupport/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthProvider implements AuthProvider {

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser?> createUser({
    required String email, 
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      final user = currentUser;
      if(user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
        if(e.code == 'email-already-in-use') {
          throw EmailAlreadyInUseAuthException();
        } else if(e.code == 'invalid-email') {
          throw InvalidEmailAuthException();
        } else if(e.code == 'weak-password') {
          throw WeakPasswordAuthException();
        } else {
          throw GenericAuthException();
        }
    } catch (_) {
      throw GenericAuthException();
    }
  }
 
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser?> login({
    required String email, 
    required String password,
    }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      final user = currentUser;
      if(user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e) {
        if (e.code == 'user-not-found') {
          throw UserNotFoundAuthException();
        } else if (e.code == 'wrong-password') {
          throw WrongPasswordAuthException();
        } else {
          throw GenericAuthException();
        }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

}