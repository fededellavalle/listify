import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../../home/navigation_page.dart';

class AuthService {
  // Método para iniciar sesión con email y contraseña
  Future<List<dynamic>> signIn(
      BuildContext context, String email, String password) async {
    String errorMessage = '';
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return [
        userCredential,
        errorMessage
      ]; // Devolver el UserCredential si la autenticación es exitosa
    } on FirebaseAuthException catch (e) {
      errorMessage = getFirebaseAuthErrorMessage(e); // Obtener mensaje de error
      print('Error signing in: $errorMessage');
      return [null, errorMessage]; // Devolver null en caso de error
    } catch (e) {
      print('Error signing in: $e');
      return [null, errorMessage]; // Devolver null en caso de error
    }
  }

  // Método para obtener el mensaje de error de FirebaseAuthException
  String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado. Por favor, regístrate primero.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Por favor, inténtalo de nuevo.';
      case 'invalid-email':
        return 'Email inválido. Por favor, verifica tu email.';
      case 'user-disabled':
        return 'Usuario deshabilitado. Por favor, contacta al soporte.';
      default:
        return 'Error al iniciar sesión. Por favor, intenta de nuevo más tarde.';
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Iniciar sesión con Google
      GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? gAuth = await gUser?.authentication;

      // Obtener credencial de autenticación de Google
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth?.accessToken,
        idToken: gAuth?.idToken,
      );

      // Iniciar sesión con la credencial en FirebaseAuth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Imprimir información del usuario
      print(userCredential.user?.displayName);
      print(userCredential.user?.email);
      print(userCredential.user?.photoURL);
      print(userCredential.user?.phoneNumber);

      // Navegar a la página de navegación pasando el UID y el nombre de usuario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationPage(
              uid: userCredential.user?.uid,
              userName: userCredential.user?.displayName),
        ),
      );
    } catch (e) {
      // Manejar errores si ocurren
      print('Error signing in with Google: $e');
    }
  }

  // Método para cerrar sesión en Google
  Future<void> signOutGoogle() async {
    try {
      // Obtener instancia de GoogleSignIn
      GoogleSignIn googleSignIn = GoogleSignIn();

      // Desconectar la sesión de Google
      await googleSignIn.disconnect();

      // Imprimir mensaje o realizar otras acciones después de cerrar sesión
      print('Google sign out successful');
    } catch (e) {
      // Manejar errores si ocurren
      print('Error signing out from Google: $e');
    }
  }
}
