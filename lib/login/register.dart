import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrarse',
          style: TextStyle(
              color: Color.fromARGB(
                  255, 242, 187, 29)), // Color deseado para el texto del AppBar
        ),
        backgroundColor: Colors.black
            .withOpacity(0.9), // Color deseado para el fondo del AppBar
        iconTheme: const IconThemeData(
            color: Colors
                .white), // Color deseado para el icono de la flecha de retorno
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  late String _nombre;
  late String _apellido;
  late DateTime _fechaNacimiento = DateTime.now();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  Future<CroppedFile?> _cropImage(File imageFile) async {
    final imageCropper = ImageCropper(); // Crear una instancia de ImageCropper
    CroppedFile? croppedFile = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressQuality: 100,
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  await _getImage();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[
                      300], // Color de fondo del avatar si la imagen no está presente
                  foregroundColor: Colors.black, // Color del borde del avatar
                  child: _image == null
                      ? Icon(Icons.camera_alt,
                          size:
                              50) // Icono de la cámara si no se selecciona ninguna imagen
                      : ClipOval(
                          child: Image.file(
                            _image!,
                            width: 100, // Ancho de la imagen
                            height: 100, // Alto de la imagen
                            fit: BoxFit
                                .cover, // Ajuste de la imagen para cubrir todo el espacio disponible
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8), // Espacio entre el círculo y el texto
              const Center(
                child: Text(
                  'Seleccione su foto de perfil',
                  style: TextStyle(
                    color: Colors.white,
                  ), // Color del texto
                  textAlign:
                      TextAlign.center, // Centra el texto horizontalmente
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
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
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
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
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
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
                    return 'Por favor, ingrese su Nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
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
                    return 'Por favor, ingrese su Apellido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _apellido = value!;
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    //fillColor: Colors.white,
                    //filled: true,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${_fechaNacimiento.day}/${_fechaNacimiento.month}/${_fechaNacimiento.year}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Verificar si la edad es mayor a 14 años
                    if (!validateDateOfBirth(_fechaNacimiento)) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text(
                                'Debe ser mayor de 14 años para registrarse'),
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
                      return;
                    }

                    bool registered = await register(_email, _password, _nombre,
                        _apellido, _fechaNacimiento, _image);
                    if (registered) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Registro Exitoso'),
                            content: Text('Su usuario fue creado exitosamente'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cerrar el AlertDialog
                                  Navigator.of(context)
                                      .pop(); // Volver a la pantalla anterior (login)
                                },
                                child: Text('OK'),
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
                            content: Text(
                                'Error al crear el Usuario, intentelo nuevamente'),
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
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(20),
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 242, 187, 29)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Text('Registrarse'),
              ),
            ],
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
}

Future<bool> register(String email, String password, String nombre,
    String apellido, DateTime fechaNacimiento, File? image) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Subir la imagen a Firebase Storage
    if (image != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('users/${userCredential.user!.uid}/profile_image.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Guardar información adicional en Firestore
      Timestamp fechaNacimientoTimestamp = Timestamp.fromDate(fechaNacimiento);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'email:': email,
        'fechaNacimiento': fechaNacimientoTimestamp,
        'imageUrl': imageUrl, // URL de descarga de la imagen
      });
    } else {
      // No se proporcionó una imagen, guardar la información sin la URL de la imagen
      Timestamp fechaNacimientoTimestamp = Timestamp.fromDate(fechaNacimiento);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'fechaNacimiento': fechaNacimientoTimestamp,
      });
    }

    return true; // Registro exitoso
  } catch (e) {
    print('Error registering user: $e');
    return false; // Error al registrar usuario
  }
}
