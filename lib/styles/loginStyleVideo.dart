import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    late String _email;
    late String _password;
    bool _obscureText = true;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xffB81736),
              Color(0xff281537),
            ])),
            child: const Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Hola\nInicia Sesion',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Olvidaste tu contrasenha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xff281537),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  Container(
                    height: 55,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(colors: [
                          Color(0xffB81736),
                          Color(0xff281537),
                        ])),
                    child: const Center(
                      child: Text(
                        'Iniciar Sesion',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'No estas registrado?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Registrate ahora',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
