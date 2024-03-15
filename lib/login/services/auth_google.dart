import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../../home/navigation_page.dart'; // Importar la página de navegación (NavigationPage)

class AuthService {
  // Método para iniciar sesión con Google
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Imprimir información del usuario
      print(userCredential.user?.displayName);
      print(userCredential.user?.email);
      print(userCredential.user?.photoURL);

      // Navegar a la página de navegación pasando el UID y el nombre de usuario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationPage(uid: userCredential.user?.uid, userName: userCredential.user?.displayName),
        ),
      );
    } catch (e) {
      // Manejar errores si ocurren
      print('Error signing in with Google: $e');
    }
  }
}