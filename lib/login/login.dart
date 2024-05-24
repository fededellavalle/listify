import 'package:app_listas/login/services/forgotpassword.dart';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../home/navigation_page.dart';
import 'register.dart';
import 'services/auth_google.dart';
import 'package:flutter/cupertino.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _obscureText = true;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Container(
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/assets/images/listifyIconRecortada.png',
                        height: 128.0 * scaleFactor,
                      ),
                      SizedBox(height: 30.0 * scaleFactor),
                      Text(
                        'Bienvenido/a a Listify',
                        style: TextStyle(
                          fontSize: 25.0 * scaleFactor,
                          color: Colors.white,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 24.0 * scaleFactor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0xFF74BEB8),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 117, 168, 184),
                              ),
                            ),
                            counterText: "",
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0 * scaleFactor,
                            fontFamily: 'SFPro',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                          maxLength: 50,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                            prefixIcon: Icon(
                              Icons.password,
                              color: Colors.grey,
                              size: 24.0 * scaleFactor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0xFF74BEB8),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 117, 168, 184),
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 24.0 * scaleFactor,
                              ),
                            ),
                            counterText: "",
                          ),
                          obscureText: _obscureText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0 * scaleFactor,
                            fontFamily: 'SFPro',
                          ),
                          maxLength: 40,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        SizedBox(height: 10.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ForgotPasswordPage();
                                },
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Olvidaste tu Contraseña?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.0 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        CupertinoButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();

                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    List<dynamic> result = await AuthService()
                                        .signIn(context, _email, _password);
                                    UserCredential? userCredential = result[0];
                                    String errorMessage = result[1];

                                    if (userCredential != null) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NavigationPage(),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Error',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0 * scaleFactor,
                                              ),
                                            ),
                                            backgroundColor: Colors.grey[800],
                                            content: Text(
                                              errorMessage,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0 * scaleFactor,
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'OK',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        14.0 * scaleFactor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          color: skyBluePrimary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoading
                                  ? CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'O puedes',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.0 * scaleFactor,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                // Wait for signInWithGoogle to complete
                                await AuthService().signInWithGoogle(context);

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoading
                                ? const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  )
                                : Row(
                                    children: [
                                      Image.asset(
                                        'lib/assets/images/google.png',
                                        height: 16 * scaleFactor,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Continuar con Google',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16 * scaleFactor,
                                          fontFamily: 'SFPro',
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No eres parte de Listify?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    RegisterPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(-1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Registrate aquí',
                        style: TextStyle(
                          color: Color(0xFF74BEB8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () async {
                        print('Entro al ig');
                        /*
                        const url = 'https://www.instagram.com/exodo_club_/';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $url';
                        }*/
                      },
                      child: Image.asset(
                        'lib/assets/images/logo-exodo.png',
                        height: 45 * scaleFactor,
                        width: 70 * scaleFactor,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<UserCredential?> signIn(
    BuildContext context, String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential;
  } catch (e) {
    print('Error signing in: $e');
    return null;
  }
}
