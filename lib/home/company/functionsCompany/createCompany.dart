import 'dart:io';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:country_picker/country_picker.dart';

class CreateCompany extends StatefulWidget {
  final String? uid;

  const CreateCompany({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _CreateCompanyState createState() => _CreateCompanyState();
}

class _CreateCompanyState extends State<CreateCompany> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCountry;
  File? _image;
  bool _isLoading = false;

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
    final imageCropper = ImageCropper();
    CroppedFile? croppedFile = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 512,
      maxHeight: 512,
      cropStyle: CropStyle.circle,
    );
    return croppedFile;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese el nombre de la empresa';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese el username de la empresa';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Agregar una nueva empresa',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                            width: 120 * scaleFactor,
                            height: 120 * scaleFactor,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20 * scaleFactor),
              TextFormField(
                controller: nameController,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                decoration: InputDecoration(
                  labelText: 'Nombre de la empresa',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 14 * scaleFactor,
                  ),
                  prefixIcon: Icon(
                    Icons.business,
                    color: Colors.grey,
                    size: 20 * scaleFactor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBluePrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBlueSecondary,
                    ),
                  ),
                  counterText: "",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                ],
                validator: _validateName,
                maxLength: 25,
              ),
              SizedBox(height: 20 * scaleFactor),
              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Username de la empresa',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 14 * scaleFactor,
                  ),
                  prefixIcon: Icon(
                    Icons.alternate_email,
                    color: Colors.grey,
                    size: 20 * scaleFactor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBluePrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBlueSecondary,
                    ),
                  ),
                  counterText: "",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z0-9._-]+$')),
                ],
                validator: _validateUsername,
                maxLength: 15,
              ),
              SizedBox(height: 20 * scaleFactor),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 20 * scaleFactor,
                    horizontal: 20 * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    border: Border.all(
                      color:
                          _selectedCountry != null ? Colors.white : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: Colors.grey,
                        size: 20 * scaleFactor,
                      ),
                      SizedBox(width: 10 * scaleFactor),
                      Expanded(
                        child: Text(
                          _selectedCountry ?? 'Seleccione la nacionalidad',
                          style: TextStyle(
                            color: _selectedCountry != null
                                ? Colors.white
                                : Colors.grey,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20 * scaleFactor),
              CupertinoButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          String companyName = nameController.text.trim();
                          String companyUser = userController.text.trim();
                          String ownerUid = widget.uid ?? '';
                          String? country = _selectedCountry;

                          if (companyName.isNotEmpty &&
                              companyUser.isNotEmpty &&
                              ownerUid.isNotEmpty &&
                              country != null) {
                            try {
                              QuerySnapshot<Map<String, dynamic>>
                                  usernameCheck = await FirebaseFirestore
                                      .instance
                                      .collection('companies')
                                      .where('username', isEqualTo: companyUser)
                                      .get();

                              if (usernameCheck.docs.isEmpty) {
                                String imageUrl = '';

                                if (_image != null) {
                                  Reference ref = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'company_images/$companyUser/company_image.jpg');
                                  UploadTask uploadTask = ref.putFile(_image!);
                                  TaskSnapshot taskSnapshot =
                                      await uploadTask.whenComplete(() => null);
                                  imageUrl =
                                      await taskSnapshot.ref.getDownloadURL();
                                } else {
                                  imageUrl =
                                      'https://firebasestorage.googleapis.com/v0/b/app-listas-eccd1.appspot.com/o/users%2Fcompany-image-standard.png?alt=media&token=215f501d-c691-4804-93d3-97187cf5e677';
                                }

                                await FirebaseFirestore.instance
                                    .collection('companies')
                                    .doc(companyUser)
                                    .set({
                                  'name': companyName,
                                  'username': companyUser,
                                  'ownerUid': ownerUid,
                                  'imageUrl': imageUrl,
                                  'nationality': country,
                                });

                                setState(() {
                                  _isLoading = false;
                                });

                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                                SnackBar(
                                    content: Text(
                                  'El username ya está en uso',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                  ),
                                ));
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              SnackBar(
                                  content: Text(
                                'Error agregando la empresa: $e',
                                style: TextStyle(
                                  fontFamily: 'SFPro',
                                ),
                              ));
                            }
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                'Debes completar todos los datos.',
                                style: TextStyle(
                                  fontFamily: 'SFPro',
                                ),
                              )),
                            );
                          }
                        } else {
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
                        ? CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
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
    );
  }
}
