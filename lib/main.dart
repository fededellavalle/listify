import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/login.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:app_listas/home/navigation_page.dart';
import 'package:app_listas/login/services/waiting_for_email_confirmation.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance
      // Your personal reCaptcha public key goes here:
      .activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listify',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/waitingForEmailConfirmation': (context) =>
            WaitingForEmailConfirmationPage(),
        '/navigationPage': (context) => NavigationPage(),
      },
    );
  }
}

/* Device Preview
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context), // Add this line
      builder: DevicePreview.appBuilder, // Add this line
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}*/



/* Con esto hago lo de la imagen de carga
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializar Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Listas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Usar SplashScreen como pantalla de carga
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/splash.png'), // Mostrar la imagen de carga
      ),
    );
  }
}*/
