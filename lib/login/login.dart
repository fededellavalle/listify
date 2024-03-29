import 'package:app_listas/login/services/forgotpassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/navigation_page.dart'; // Importa HomePage desde la carpeta home
import 'register.dart';
import 'services/auth_google.dart';
import '../styles/button.dart';

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

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _keepSignedIn = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black.withOpacity(0.9),
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/images/applistas-icono.png',
                      height: 128.0,
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      'Bienvenido/a a App Listas',
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
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
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 242, 187, 29)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          //fillColor: Colors.white,
                          //filled: true,
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 242, 187, 29),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText =
                                    !_obscureText; // Cambia el estado de la visibilidad de la contraseña
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey, // Color del icono
                            ),
                          ),
                        ),
                        obscureText:
                            _obscureText, // Estado de visibilidad de la contraseña
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _keepSignedIn,
                            onChanged: (value) {
                              setState(() {
                                _keepSignedIn = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Mantener sesión iniciada',
                            style: TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),*/
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
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          )),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            UserCredential? userCredential = await AuthService()
                                .signIn(context, _email, _password);
                            if (userCredential != null) {
                              String uid = userCredential.user!.uid;
                              DocumentSnapshot userData =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .get();

                              String _userName = userData['nombre'];

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigationPage(
                                      uid: uid, userName: _userName),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error'),
                                    content:
                                        Text('Email o Contraseña invalido'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        style: buttonPrimary,
                        child: Text(
                          'Iniciar Sesion',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Texto o iniciar sesion con
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
                        style: GoogleFonts.roboto(color: Colors.grey[500]),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ))
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        AuthService().signInWithGoogle(context);
                      },
                      style: buttonSecondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/google.png',
                            height: 20,
                          ),
                          SizedBox(
                              width: 8), // Espacio entre la imagen y el texto
                          Text(
                            'Continuar con Google',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*
                                      Parte de poder iniciar sesion con Apple
                    SizedBox(height: 15),
                
                    ElevatedButton(
                      onPressed: () {
                        // Acción al presionar el botón
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(Colors.grey),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.1)), // Color de fondo del botón con opacidad
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.white), // Borde blanco
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(20), // Ajusta el padding del botón según sea necesario
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/apple.png',
                            height: 20,
                          ),
                          SizedBox(width: 8), // Espacio entre la imagen y el texto
                          Text(
                            'Continuar con Apple',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),*/
                  ],
                ),
              ),

              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No eres parte de app listas?',
                    style: GoogleFonts.roboto(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                      print('Registrate ahora presionado');
                    },
                    child: Text(
                      'Registrate ahora',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
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

    return userCredential; // Devolver el UserCredential
  } catch (e) {
    print('Error signing in: $e');
    return null; // Error al iniciar sesión, devuelve null
  }
}
