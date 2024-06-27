import 'package:app_listas/styles/loading.dart';
import 'package:app_listas/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/login.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_listas/home/navigation_page.dart';
import 'package:app_listas/login/services/waiting_for_email_confirmation.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startLoading();
  }

  Future<void> startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      prefs.setBool('isFirstRun', false);
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/navigationPage');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingScreen(),
      ),
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