import 'package:app_listas/styles/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose del controlador cuando el widget se elimine del árbol de widgets
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    String email = _emailController.text;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey[800],
            content: Text(
                'Se le ha enviado un email para recuperar su contraseña a $email',
                style: TextStyle(color: Colors.white)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Recuperar tu contraseña',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Ingresa tu email y te enviaremos un link para que puedas cambiar tu contraseña',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.email,
                        color: Colors.grey), // Color del icono
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 242, 187, 29)), // Borde resaltado al enfocar
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 158, 128, 36)), // Borde regular
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isLoading = true;
                            });
                            passwordReset();
                          },
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Resetear Contraseña',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                      ],
                    ),
                    style: buttonPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
