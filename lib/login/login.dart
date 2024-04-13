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
  //bool _keepSignedIn = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black.withOpacity(0.9),
      backgroundColor: Colors.black,
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
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 242, 187, 29)),
                          prefixIcon: Icon(Icons.person,
                              color: Colors.grey), // Color del icono
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 242, 187,
                                    29)), // Borde resaltado al enfocar
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 158, 128, 36)), // Borde regular
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
                          prefixIcon: Icon(Icons.password,
                              color: Colors.grey), // Color del icono
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 242, 187,
                                    29)), // Borde resaltado al enfocar
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 158, 128, 36)), // Borde regular
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
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Colors.grey[800], // Fondo gris oscuro
                                  title: Text(
                                    'Iniciando sesión',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          'Por favor, espera un momento...',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 20),
                                        Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                3, // Ajusta el grosor del círculo
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color.fromARGB(255, 242, 187,
                                                  29), // Color del círculo
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            List<dynamic> result = await AuthService()
                                .signIn(context, _email, _password);
                            UserCredential? userCredential = result[0];
                            String errorMessage = result[1];
                            Navigator.pop(
                                context); // Cerrar el diálogo de "Iniciando sesión"
                            if (userCredential != null) {
                              String uid = userCredential.user!.uid;
                              DocumentSnapshot userData =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .get();
                              String _userName = userData['name'];
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
                                    title: Text(
                                      'Error',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        Colors.grey[800], // Fondo gris oscuro
                                    content: Text(
                                      errorMessage,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(color: Colors.white),
                                        ),
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
                          'Iniciar Sesión',
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
                    style: GoogleFonts.roboto(color: Colors.grey),
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
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = Offset(0.0,
                                1.0); // Define el punto de inicio de la animación (abajo)
                            var end = Offset
                                .zero; // Define el punto final de la animación (arriba)
                            var curve = Curves.ease; // Curva de animación
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
                      style: GoogleFonts.roboto(
                        color: Color.fromARGB(255, 242, 187, 29),
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
