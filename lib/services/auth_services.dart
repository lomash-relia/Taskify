import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import '../helper/helper_function.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//login
  Future logInWithUsernameAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

//register
  Future registerUserWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update the user data.
        await DatabaseService(uid: user.uid).saveUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

//sign-out
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserNameSF('');
      await HelperFunctions.saveUserEmailSF('');
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
