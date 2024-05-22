import 'package:app_listas/login/services/firebase_exceptions.dart';
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

  bool _isLoading = false;

  // Define un controlador
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.displayName ?? '';
    _controllerEmail.text = widget.email ?? '';
    return Scaffold(
      backgroundColor: Colors.black,
      // Añadido Scaffold aquí
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Esto quita la flecha de volver
        title: Text(
          'Completar Registro',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        widget.imageUrl ?? '',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 242, 187, 29),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 242, 187, 29),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 158, 128, 36),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controllerEmail,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 242, 187, 29),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 242, 187, 29),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 158, 128, 36),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usuario de Instagram (opcional)',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 242, 187, 29),
                    ),
                    prefixIcon: Icon(Icons.alternate_email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 242, 187, 29),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 158, 128, 36),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
                      prefixIcon: Icon(Icons.calendar_today,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${_fechaNacimiento.day}/${_fechaNacimiento.month}/${_fechaNacimiento.year}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Si es true, deshabilita el botón
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              _isLoading = true; // Activar el estado de carga
                            });
                            List<dynamic> result = await register(
                                _fechaNacimiento, _instagramUsername);
                            Navigator.pop(context);
                            bool success = result[0];
                            String errorMessage = result[1];
                            setState(() {
                              _isLoading =
                                  false; // Desactivar el estado de carga
                            });
                            if (success) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[800],
                                    title: Text(
                                      'Registro Exitoso',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Su usuario ${widget.displayName} fue creado exitosamente',
                                      style: TextStyle(color: Colors.white),
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
                                              color: Color.fromARGB(
                                                  255, 242, 187, 29)),
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
                                    title: Text('Error'),
                                    content: Text(errorMessage),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Ok'),
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
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(20),
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 242, 187, 29),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
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
                                    strokeWidth:
                                        2, // Grosor del círculo de carga
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        10), // Espacio entre el círculo y el texto
                                Text(
                                  'Registrando',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Registrarse',
                              style: TextStyle(
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
      ),
    );
  }

  // Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento)
      setState(() {
        _fechaNacimiento = picked;
      });
  }

  // Función para validar la fecha de nacimiento
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

      // Guardar información adicional en Firestore
      Timestamp fechaNacimientoTimestamp = Timestamp.fromDate(fechaNacimiento);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'birthDate': fechaNacimientoTimestamp,
        'instagram': instagram,
      });
      return [true, errorMessage]; // Registro exitoso
    } catch (e) {
      String errorMessage = '';
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthExceptions.getErrorMessage(e.code);
        print('Error registering user: $errorMessage');
      } else {
        print('Error registering user: $e');
      }
      return [false, errorMessage]; // Error al registrar usuario
    }
  }
}
