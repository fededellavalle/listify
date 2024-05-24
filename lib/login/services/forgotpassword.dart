import 'package:app_listas/styles/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    String email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
    });
    if (email.isNotEmpty) {
      try {
        // Intentar enviar el correo de restablecimiento de contraseña
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Recuperar Contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  )),
              backgroundColor: Colors.grey[800],
              content: Text(
                'Se le ha enviado un email para recuperar su contraseña a $email',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      )),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  )),
              backgroundColor: Colors.grey[800],
              content: Text(e.message.toString(),
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      )),
                ),
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Debes ingresar un email.',
          style: TextStyle(
            fontFamily: 'SFPro',
          ),
        )),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Ingresa tu email y te enviaremos un link para que puedas cambiar tu contraseña',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade400,
                    fontFamily: 'SFPro',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                      size: 24.0 * scaleFactor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: grey),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z0-9@._-]+$'),
                    ),
                  ],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            passwordReset();
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
                                'Resetear Contraseña',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                      ],
                    ),
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
