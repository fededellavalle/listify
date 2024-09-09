import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../../home/navigation_page.dart';
import '../endRegisterGoogle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? gAuth = await gUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth?.accessToken,
        idToken: gAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationPage(),
          ),
        );
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.disconnect();

      print('Google sign out successful');
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
