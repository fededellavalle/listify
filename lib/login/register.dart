import 'dart:io';
import 'package:app_listas/login/login.dart';
import 'package:app_listas/login/services/firebase_exceptions.dart';
import 'package:app_listas/styles/color.dart';
import 'package:app_listas/styles/inputsDecoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Text(
                  'Ir a Inicio de Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password = '';
  late String _nombre;
  late String _apellido;
  late DateTime _fechaNacimiento = DateTime.now();
  File? _image;
  String _instagramUsername = 'Undefined';
  String? _selectedCountry;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _passwordsMatch = false;
  bool _isLoading = false;

  final _nameValidator = RegExp(r'^[a-zA-Z ]+$');
  final _surnameValidator = RegExp(r'^[a-zA-Z ]+$');
  final _emailValidator = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _passwordValidator =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*]).{8,}$');

  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  String _phoneNumber = '';
  PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'AR');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
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

  void reverseAnimationAndNavigate() {
    _controller.reverse().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

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
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imágen',
          toolbarColor: skyBluePrimary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          cropStyle: CropStyle.circle,
          showCropGrid: false,
        ),
        IOSUiSettings(
          title: 'Recortar imágen',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    return croppedFile;
  }

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
              child: Text('Cerrar'),
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
              child: Text('Cerrar'),
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

    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      'Vamos a crear una cuenta',
                      style: TextStyle(
                        fontSize: 25 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Crea una cuenta con tu email, recuerda que estos datos no van a poder ser modificados una vez ya creada, solamente la foto',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15 * scaleFactor,
                    color: Colors.grey.shade400,
                    fontFamily: 'SFPro',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(height: 5),
                InkWell(
                  onTap: () async {
                    await _getImage();
                  },
                  child: CircleAvatar(
                    radius: 50 * scaleFactor,
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 50 * scaleFactor)
                        : ClipOval(
                            child: Image.file(
                              _image!,
                              width: 100 * scaleFactor,
                              height: 100 * scaleFactor,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Seleccione su foto de perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextFormField(
                          decoration: buildInputDecoration(
                              labelText: 'Nombre',
                              labelFontSize: 16 * scaleFactor,
                              prefixIcon: CupertinoIcons.person_crop_circle,
                              prefixIconSize: 24 * scaleFactor),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
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
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          decoration: buildInputDecoration(
                              labelText: 'Apellido',
                              labelFontSize: 16 * scaleFactor,
                              prefixIcon:
                                  CupertinoIcons.person_crop_circle_fill,
                              prefixIconSize: 24 * scaleFactor),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: buildInputDecoration(
                    labelText: 'Email',
                    labelFontSize: 16 * scaleFactor,
                    prefixIcon: CupertinoIcons.mail,
                    prefixIconSize: 24 * scaleFactor,
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
                const SizedBox(height: 15),
                TextFormField(
                  key: Key('password'),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      color: white,
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock_circle,
                      color: Colors.grey,
                      size: 24 * scaleFactor,
                    ),
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: Icon(
                        _showPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: Colors.grey,
                        size: 24 * scaleFactor,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                  obscureText: !_showPassword,
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
                      return null;
                    } else if (_passwordValidator.hasMatch(value)) {
                      setState(() {
                        _hasUpperCase = value.contains(RegExp(r'[A-Z]'));
                        _hasLowerCase = value.contains(RegExp(r'[a-z]'));
                        _hasNumber = value.contains(RegExp(r'[0-9]'));
                        _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
                        _hasMinLength = value.length >= 8;
                        _password = value;
                      });
                      return null;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                  onChanged: (_) => _validateForm(),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        _buildPasswordStrengthMessage(),
                        style: TextStyle(
                          color:
                              _areRequirementsMet() ? Colors.green : Colors.red,
                          fontSize: 14 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  key: Key('confirmPassword'),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyle(
                      color: white,
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock_circle_fill,
                      color: Colors.grey,
                      size: 24 * scaleFactor,
                    ),
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _showConfirmPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: Colors.grey,
                        size: 24 * scaleFactor,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                  obscureText: !_showConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme su contraseña';
                    } else if (value != _password) {
                      _passwordsMatch = false;
                      return 'Las contraseñas no coinciden';
                    }
                    _passwordsMatch = true;
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
                        fontSize: 14 * scaleFactor,
                      ),
                    ),
                    if (_passwordsMatch) SizedBox(height: 10),
                  ],
                ),
                TextFormField(
                  decoration: buildInputDecoration(
                      labelText: 'Usuario de Instagram (opcional)',
                      labelFontSize: 16 * scaleFactor,
                      prefixIcon: CupertinoIcons.at,
                      prefixIconSize: 24 * scaleFactor),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
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
                    decoration: buildInputDecoration(
                        labelText: 'Fecha de Nacimiento (Mayor a 14 años)',
                        labelFontSize: 16 * scaleFactor,
                        prefixIcon: CupertinoIcons.calendar,
                        prefixIconSize: 24 * scaleFactor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${_fechaNacimiento.day}/${_fechaNacimiento.month}/${_fechaNacimiento.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: skyBluePrimary,
                    ),
                  ),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _phoneNumber = number.phoneNumber!;
                      });
                    },
                    initialValue: _initialPhoneNumber,
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                      setSelectorButtonAsPrefixIcon: true,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: const TextStyle(color: Colors.white),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                    ),
                    inputDecoration: InputDecoration(
                      hintText: 'Número de Teléfono',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.phone,
                        color: Colors.grey,
                        size: 24 * scaleFactor,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: skyBluePrimary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.flag,
                          color: Colors.grey,
                          size: 24 * scaleFactor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedCountry ?? 'Seleccione la nacionalidad',
                            style: TextStyle(
                              color: _selectedCountry != null ? white : grey,
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
                                fontSize: 14 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Términos y Condiciones',
                                style: TextStyle(
                                  color: skyBluePrimary,
                                  fontSize: 14 * scaleFactor,
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
                                fontSize: 14 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Política de Privacidad',
                                style: TextStyle(
                                  color: skyBluePrimary,
                                  fontSize: 14 * scaleFactor,
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
                          print('Phone: $_phoneNumber');
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
                                const SnackBar(
                                    content: Text(
                                  'Debe ser mayor de 14 años.',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                  ),
                                )),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            List<dynamic> result = await register(
                              _email,
                              _password,
                              _nombre,
                              _apellido,
                              _fechaNacimiento,
                              _image,
                              _instagramUsername,
                              _selectedCountry,
                              _phoneNumber, // Añade el número de teléfono aquí
                            );
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
                                      'Su usuario $_nombre($_email) fue creado exitosamente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
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
                            if (_selectedCountry == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Por favor, seleccione una nacionalidad.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!_termsAccepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Debes aceptar los términos y condiciones.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!_privacyAccepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Debes aceptar la política de privacidad.',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                ),
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
                                CupertinoActivityIndicator(
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Registrando',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'SFPro',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'SFPro',
                                color: Colors.black,
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
    DateTime minimumDate = currentDate.subtract(Duration(days: 365 * 14));
    return fechaNacimiento.isBefore(minimumDate);
  }

  Future<List<dynamic>> register(
    String email,
    String password,
    String nombre,
    String apellido,
    DateTime fechaNacimiento,
    File? image,
    String instagramUsername,
    String? nationality,
    String phoneNumber, // Añade el número de teléfono aquí
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      String errorMessage = '';

      if (image != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('users/${userCredential.user!.uid}/profile_image.jpg');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

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
          'instagram': instagramUsername,
          'nationality': nationality,
          'phoneNumber': phoneNumber, // Guarda el número de teléfono aquí
          'trial': false,
          'subscription': 'basic',
        });
      } else {
        String imageUrl =
            "https://firebasestorage.googleapis.com/v0/b/app-listas-eccd1.appspot.com/o/users%2Fprofile-image-standard.png?alt=media&token=f3a904df-f908-4743-8b16-1f3939986569";
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
          'instagram': instagramUsername,
          'nationality': nationality,
          'phoneNumber': phoneNumber, // Guarda el número de teléfono aquí
          'trial': false,
          'subscription': 'basic',
        });
      }

      Navigator.pushReplacementNamed(context, '/waitingForEmailConfirmation');

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
