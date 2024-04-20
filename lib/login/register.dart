import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'services/firebase_exceptions.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Registrarse',
          style: TextStyle(
              color: Color.fromARGB(
                  255, 242, 187, 29)), // Color deseado para el texto del AppBar
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_downward, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
  late String _password = '';
  late String _nombre;
  late String _apellido;
  late DateTime _fechaNacimiento = DateTime.now();
  File? _image;
  String _instagramUsername = 'Undefined';

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _passwordsMatch = false;
  bool _isLoading = false;

  final _nameValidator = RegExp(r'^[a-zA-Z ]+$');
  final _surnameValidator = RegExp(r'^[a-zA-Z ]+$');
  final _emailValidator = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _passwordValidator =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*]).{8,}$');
  final _usernameValidator = RegExp(r'^[a-zA-Z0-9_.-]+$');

  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  String _buildPasswordStrengthMessage() {
    List<String> requirements = [];
    if (!_hasUpperCase) requirements.add('Mayúscula');
    if (!_hasLowerCase) requirements.add('Minúscula');
    if (!_hasNumber) requirements.add('Número');
    if (!_hasSpecialChar) requirements.add('Carácter especial');
    if (!_hasMinLength) requirements.add('Al menos 8 caracteres');

    String message = 'La contraseña debe contener:';
    if (requirements.isEmpty) {
      return 'Todos los requisitos están cumplidos';
    } else {
      print(requirements);
      return message +
          '\n- ' +
          requirements.join('\n- ') +
          '\n(Faltan estos requisitos por cumplir)';
    }
  }

  bool _areRequirementsMet() {
    return _hasUpperCase &&
        _hasLowerCase &&
        _hasNumber &&
        _hasSpecialChar &&
        _hasMinLength;
  }

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
      aspectRatio:
          CropAspectRatio(ratioX: 1, ratioY: 1), // Ratio 1:1 para un círculo
      compressQuality: 100,
      maxWidth: 512,
      maxHeight: 512,
      cropStyle: CropStyle.circle, // Estilo de recorte circular
    );
    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Seleccione su foto de perfil(opcional)',
                  style: TextStyle(
                    color: Colors.white,
                  ), // Color del texto
                  textAlign:
                      TextAlign.center, // Centra el texto horizontalmente
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su Nombre';
                  } else if (!_nameValidator.hasMatch(value)) {
                    return 'Ingrese solo letras y espacios';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Apellido',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su Apellido';
                  } else if (!_surnameValidator.hasMatch(value)) {
                    return 'Ingrese solo letras y espacios';
                  }
                  return null;
                },
                onSaved: (value) {
                  _apellido = value!;
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su email';
                  } else if (!_emailValidator.hasMatch(value)) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: Key('password'),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey, // Color del icono del ojo
                    ),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText:
                    !_showPassword, // Mostrar u ocultar la contraseña según el estado de _showPassword
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  } else if (!_passwordValidator.hasMatch(value)) {
                    setState(() {
                      _hasUpperCase = value.contains(RegExp(r'[A-Z]'));
                      _hasLowerCase = value.contains(RegExp(r'[a-z]'));
                      _hasNumber = value.contains(RegExp(r'[0-9]'));
                      _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
                      _hasMinLength = value.length >= 8;
                    });
                    return null; // No return an error message here
                  } else if (_passwordValidator.hasMatch(value)) {
                    setState(() {
                      _hasUpperCase = value.contains(RegExp(r'[A-Z]'));
                      _hasLowerCase = value.contains(RegExp(r'[a-z]'));
                      _hasNumber = value.contains(RegExp(r'[0-9]'));
                      _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
                      _hasMinLength = value.length >= 8;
                      _password = value;
                    });
                    return null; // No return an error message here
                  }
                },
                onSaved: (value) {
                  _password = value!;
                },
                onChanged: (_) => _validateForm(),
              ),

              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      _buildPasswordStrengthMessage(),
                      style: TextStyle(
                        color:
                            _areRequirementsMet() ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                key: Key('confirmPassword'),
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey, // Color del icono del ojo
                    ),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme su contraseña';
                  } else if (value != _password) {
                    _passwordsMatch = false;
                    return 'Las contraseñas no coinciden';
                  }
                  _passwordsMatch =
                      true; // Actualizamos la variable cuando las contraseñas coinciden
                  return null;
                },
                onChanged: (_) => _validateForm(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_passwordsMatch) SizedBox(height: 10),
                  Text(
                    _passwordsMatch ? 'Las contraseñas coinciden' : '',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  if (_passwordsMatch) SizedBox(height: 10),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Usuario de Instagram (opcional)',
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
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _instagramUsername = value ?? 'Undefined';
                },
                onChanged: (_) => _validateForm(),
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
                onPressed: _isLoading // Verifica si isLoading es true
                    ? null // Si es true, deshabilita el botón
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            _isLoading = true; // Activar el estado de carga
                          });
                          List<dynamic> result = await register(
                              _email,
                              _password,
                              _nombre,
                              _apellido,
                              _fechaNacimiento,
                              _image,
                              _instagramUsername);
                          Navigator.pop(context);
                          bool success = result[0];
                          String errorMessage = result[1];
                          setState(() {
                            _isLoading = false; // Desactivar el estado de carga
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
                                    'Su usuario $_nombre($_email) fue creado exitosamente',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
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
                                  strokeWidth: 2, // Grosor del círculo de carga
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
      String email,
      String password,
      String nombre,
      String apellido,
      DateTime fechaNacimiento,
      File? image,
      String instagram) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String errorMessage = '';

      if (image != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('users/${userCredential.user!.uid}/profile_image.jpg');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Guardar información adicional en Firestore
        Timestamp fechaNacimientoTimestamp =
            Timestamp.fromDate(fechaNacimiento);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nombre,
          'lastname': apellido,
          'email': email,
          'birthDate': fechaNacimientoTimestamp,
          'imageUrl': imageUrl,
          'instagram': instagram,
        });
      } else {
        String imageUrl =
            "https://firebasestorage.googleapis.com/v0/b/app-listas-eccd1.appspot.com/o/users%2Fprofile-image-standard.png?alt=media&token=f3a904df-f908-4743-8b16-1f3939986569";
        // No se proporcionó una imagen, guardar la información sin la URL de la imagen
        Timestamp fechaNacimientoTimestamp =
            Timestamp.fromDate(fechaNacimiento);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nombre,
          'lastname': apellido,
          'birthDate': fechaNacimientoTimestamp,
          'email': email,
          'imageUrl': imageUrl,
          'instagram': instagram,
        });
      }

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
