import 'package:app_listas/login/services/firebase_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn {
  Future<List<dynamic>> signIn(
      BuildContext context, String email, String password) async {
    String errorMessage = '';
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && userCredential.user!.emailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        return [
          userCredential,
          errorMessage
        ]; // Devolver el UserCredential si la autenticación es exitosa
      } else if (userCredential.user != null) {
        errorMessage =
            FirebaseAuthExceptions.getErrorMessage('email-not-verified');
        ;
        return [null, errorMessage];
      } else {
        errorMessage = FirebaseAuthExceptions.getErrorMessage(
            FirebaseAuthExceptions
                .userNotFound); // Mensaje de usuario no encontrado
        print(errorMessage);
        return [null, errorMessage];
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      errorMessage = FirebaseAuthExceptions.getErrorMessage(
          e.code); // Obtener mensaje de error
      print('Error signing in: $errorMessage');
      return [null, errorMessage]; // Devolver null en caso de error
    } catch (e) {
      print('Error signing in: $e');
      return [null, errorMessage]; // Devolver null en caso de error
    }
  }
}
