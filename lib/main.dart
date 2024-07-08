import 'package:app_listas/splashScreen.dart';
import 'package:app_listas/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/login.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:app_listas/home/navigation_page.dart';
import 'package:app_listas/login/services/waiting_for_email_confirmation.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
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
      debugShowCheckedModeBanner: false,
      title: 'Listify',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/waitingForEmailConfirmation': (context) =>
            WaitingForEmailConfirmationPage(),
        '/navigationPage': (context) => NavigationPage(),
        '/welcome': (context) => WelcomePage(),
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