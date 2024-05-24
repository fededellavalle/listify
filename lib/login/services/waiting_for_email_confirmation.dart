import 'package:app_listas/styles/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitingForEmailConfirmationPage extends StatefulWidget {
  const WaitingForEmailConfirmationPage({Key? key});

  @override
  State<WaitingForEmailConfirmationPage> createState() =>
      _WaitingForEmailConfirmationPageState();
}

class _WaitingForEmailConfirmationPageState
    extends State<WaitingForEmailConfirmationPage> {
  bool _isEmailVerified = false;
  bool _isChecking = true;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkEmailVerified();
  }

  Future<void> _checkEmailVerified() async {
    user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    setState(() {
      _isEmailVerified = user!.emailVerified;
      _isChecking = false;
    });

    if (_isEmailVerified) {
      Navigator.pushReplacementNamed(context, '/navigationPage');
    }
  }

  Future<void> _sendVerificationEmail() async {
    await user!.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email de verificación enviado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Verificación de Email',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
          ),
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
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isChecking
          ? Center(
              child: CupertinoActivityIndicator(
                color: white,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.0 * scaleFactor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/Verify_Email_Address.png', // Cambia esta ruta a la imagen deseada
                    width: 300 * scaleFactor,
                    height: 200 * scaleFactor,
                  ),
                  SizedBox(height: 20 * scaleFactor),
                  Text(
                    'Se ha enviado un email de verificación a ${user!.email}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0 * scaleFactor,
                      color: Colors.white,
                      fontFamily: 'SFPro',
                    ),
                  ),
                  SizedBox(height: 20 * scaleFactor),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _sendVerificationEmail,
                      child: Text(
                        'Reenviar Email de Verificación',
                        style: TextStyle(
                          fontSize: 16.0 * scaleFactor,
                          color: Colors.black,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      color: skyBluePrimary,
                    ),
                  ),
                  SizedBox(height: 20 * scaleFactor),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _checkEmailVerified,
                      child: Text(
                        'Verificar Estado de Email',
                        style: TextStyle(
                          fontSize: 16.0 * scaleFactor,
                          color: Colors.black,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      color: skyBluePrimary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
