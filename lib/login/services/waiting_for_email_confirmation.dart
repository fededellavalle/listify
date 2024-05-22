import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../styles/button.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          children: [
            Text(
              'Verificación de Email',
              style: TextStyle(color: Colors.white),
            ),
            // Título
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: _isChecking
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                    size: 200,
                    color: Colors.white,
                  ),
                  Text(
                    'Se ha enviado un email de verificación a ${user!.email}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendVerificationEmail,
                      child: Text('Reenviar Email de Verificación'),
                      style: buttonPrimary,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkEmailVerified,
                      child: Text('Verificar Estado de Email'),
                      style: buttonPrimary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
