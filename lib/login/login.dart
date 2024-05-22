import 'package:app_listas/login/services/forgotpassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _obscureText = true;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
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
                        height: 128.0,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Bienvenido/a a Listify',
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
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.person,
                                color: Colors.grey), // Color del icono
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Bordes redondeados
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
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(Icons.password,
                                color: Colors.grey), // Color del icono
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Bordes redondeados
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
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
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
                                            title: Text('Error',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            backgroundColor: Colors.grey[800],
                                            content: Text(errorMessage,
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
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
                          style: buttonPrimary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoading
                                  ? Row(
                                      children: [
                                        const SizedBox(
                                          width: 23,
                                          height: 23,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Iniciar Sesión',
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
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
                          style: GoogleFonts.roboto(color: Colors.grey[500]),
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
                      GestureDetector(
                        onTap: () {
                          AuthService().signInWithGoogle(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromARGB(255, 158, 128, 36),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/assets/images/google.png',
                                height: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Continuar con Google',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 253, 205, 62),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
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
                      'No eres parte de Listify?',
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
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12, // Tamaño del texto ajustable
                      ),
                    ),
                    SizedBox(width: 5), // Espacio entre el texto y la imagen
                    GestureDetector(
                      onTap: () {
                        print('Entrando a ig');
                      },
                      child: Image.asset(
                        'lib/assets/images/logo-exodo.png',
                        height: 45,
                        width: 60,
                      ),
                    ),
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

    return userCredential; // Devolver el UserCredential
  } catch (e) {
    print('Error signing in: $e');
    return null; // Error al iniciar sesión, devuelve null
  }
}
