import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../../home/navigation_page.dart';
import 'firebase_exceptions.dart';
import '../endRegisterGoogle.dart';

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

      if (userCredential.user != null && userCredential.user!.emailVerified) {
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

      // Verificar si el usuario ya está registrado en la base de datos
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      Map<String, dynamic>? userSnapshotData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (!userSnapshot.exists || userSnapshotData?['birthDate'] == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user?.displayName,
          'email': userCredential.user?.email,
          'imageUrl': userCredential.user?.photoURL,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EndRegisterGoogle(
                uid: userCredential.user?.uid,
                displayName: userCredential.user?.displayName,
                email: userCredential.user?.email,
                imageUrl: userCredential.user?.photoURL),
          ),
        );
      } else {
        // Si el usuario ya está registrado, navegar a la página de navegación
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationPage(),
          ),
        );
      }
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
