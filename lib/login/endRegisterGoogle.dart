import 'package:app_listas/login/services/firebase_exceptions.dart';
import 'package:app_listas/styles/color.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/navigation_page.dart';

class EndRegisterGoogle extends StatefulWidget {
  final String? uid;
  final String? displayName;
  final String? email;
  final String? imageUrl;

  EndRegisterGoogle({
    super.key,
    required this.uid,
    required this.displayName,
    required this.email,
    required this.imageUrl,
  });

  @override
  State<EndRegisterGoogle> createState() => _EndRegisterGoogleState();
}

class _EndRegisterGoogleState extends State<EndRegisterGoogle> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fechaNacimiento = DateTime.now();
  String _instagramUsername = 'Undefined';
  String? _selectedCountry;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  bool _isLoading = false;

  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Términos y Condiciones',
            style: TextStyle(
              fontFamily: 'SFPro',
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Aquí van los términos y condiciones...',
              style: TextStyle(
                fontFamily: 'SFPro',
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontFamily: 'SFPro',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Política de Privacidad',
            style: TextStyle(
              fontFamily: 'SFPro',
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Aquí va la política de privacidad...',
              style: TextStyle(
                fontFamily: 'SFPro',
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontFamily: 'SFPro',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth =
        375.0; // El ancho base que estás diseñando (ej. iPhone 11)
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    _controller.text = widget.displayName ?? '';
    _controllerEmail.text = widget.email ?? '';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Terminemos de crear tu cuenta',
                        style: TextStyle(
                          fontSize: 22 * scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Completa los siguientes campos con tus datos y ya puedes empezar a utilizar nuestra app',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15 * scaleFactor,
                      color: Colors.grey.shade400,
                      fontFamily: 'SFPro',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      ClipOval(
                        child: Image.network(
                          widget.imageUrl ?? '',
                          width: 70 * scaleFactor,
                          height: 70 * scaleFactor,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(
                        color: white,
                        fontSize: 16 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                      prefixIcon:
                          Icon(CupertinoIcons.person, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBluePrimary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBlueSecondary,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _controllerEmail,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: white,
                        fontSize: 16 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                      prefixIcon: Icon(CupertinoIcons.mail, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBluePrimary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBlueSecondary,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Usuario de Instagram (opcional)',
                      labelStyle: TextStyle(
                        color: skyBluePrimary,
                        fontSize: 16 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                      prefixIcon: Icon(CupertinoIcons.at, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBluePrimary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: skyBlueSecondary,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      _instagramUsername = value ?? 'Undefined';
                    },
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de Nacimiento (Mayor a 14 años)',
                        labelStyle: TextStyle(
                          color: white,
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                        prefixIcon: Icon(CupertinoIcons.calendar_today,
                            color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: skyBluePrimary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: skyBlueSecondary,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${_fechaNacimiento.day}/${_fechaNacimiento.month}/${_fechaNacimiento.year}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountry = country.name;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedCountry != null
                              ? skyBluePrimary
                              : skyBlueSecondary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.flag, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedCountry ?? 'Seleccione la nacionalidad',
                              style: TextStyle(
                                color: _selectedCountry != null
                                    ? Colors.white
                                    : Colors.grey,
                                fontSize: 16 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTermsAndConditions,
                          child: Row(
                            children: [
                              Text(
                                'Acepto los ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Términos y Condiciones',
                                  style: TextStyle(
                                    color: skyBluePrimary,
                                    fontSize: 16 * scaleFactor,
                                    fontFamily: 'SFPro',
                                  ),
                                ),
                              ),
                              Switch(
                                value: _termsAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _termsAccepted = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showPrivacyPolicy,
                          child: Row(
                            children: [
                              Text(
                                'Acepto la ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Política de Privacidad',
                                  style: TextStyle(
                                    color: skyBluePrimary,
                                    fontSize: 16 * scaleFactor,
                                    fontFamily: 'SFPro',
                                  ),
                                ),
                              ),
                              Switch(
                                value: _privacyAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _privacyAccepted = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate() &&
                                _selectedCountry != null &&
                                _termsAccepted &&
                                _privacyAccepted) {
                              _formKey.currentState!.save();
                              setState(() {
                                _isLoading = true;
                              });

                              if (!validateDateOfBirth(_fechaNacimiento)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Debe ser mayor de 14 años.',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                  ),
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                return;
                              }

                              List<dynamic> result = await register(
                                  _fechaNacimiento, _instagramUsername);
                              bool success = result[0];
                              String errorMessage = result[1];
                              setState(() {
                                _isLoading = false;
                              });
                              if (success) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey[800],
                                      title: Text(
                                        'Registro Exitoso',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SFPro',
                                        ),
                                      ),
                                      content: Text(
                                        'Su usuario ${widget.displayName} fue creado exitosamente',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SFPro',
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NavigationPage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                              color: skyBluePrimary,
                                              fontFamily: 'SFPro',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Error',
                                        style: TextStyle(
                                          fontFamily: 'SFPro',
                                        ),
                                      ),
                                      content: Text(errorMessage),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Ok',
                                            style: TextStyle(
                                              fontFamily: 'SFPro',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              if (_selectedCountry == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Por favor, seleccione una nacionalidad.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  )),
                                );
                              }
                              if (!_termsAccepted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Debe aceptar los términos y condiciones.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  )),
                                );
                              }
                              if (!_privacyAccepted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Debe aceptar la política de privacidad.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  )),
                                );
                              }
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
                            ? const Row(
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
                                  const SizedBox(width: 10),
                                  Text(
                                    'Registrando',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Registrarse',
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
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      if (validateDateOfBirth(picked)) {
        setState(() {
          _fechaNacimiento = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Debe ser mayor de 14 años.',
            style: TextStyle(
              fontFamily: 'SFPro',
            ),
          )),
        );
      }
    }
  }

  bool validateDateOfBirth(DateTime fechaNacimiento) {
    DateTime currentDate = DateTime.now();
    DateTime minimumDate =
        currentDate.subtract(Duration(days: 365 * 14)); // 14 años atrás
    return fechaNacimiento.isBefore(minimumDate);
  }

  Future<List<dynamic>> register(
      DateTime fechaNacimiento, String instagram) async {
    try {
      String errorMessage = '';

      Timestamp fechaNacimientoTimestamp = Timestamp.fromDate(fechaNacimiento);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'birthDate': fechaNacimientoTimestamp,
        'instagram': instagram,
        'nationality': _selectedCountry,
        'trial': false,
        'subscription': 'basic',
      });
      return [true, errorMessage];
    } catch (e) {
      String errorMessage = '';
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthExceptions.getErrorMessage(e.code);
        print('Error registering user: $errorMessage');
      } else {
        print('Error registering user: $e');
      }
      return [false, errorMessage];
    }
  }
}
