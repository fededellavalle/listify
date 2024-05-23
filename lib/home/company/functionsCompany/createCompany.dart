import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:country_picker/country_picker.dart';
import '../../../styles/button.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Agregar una nueva empresa',
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : ClipOval(
                          child: Image.file(
                            _image!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                style: GoogleFonts.roboto(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre de la empresa',
                  labelStyle: GoogleFonts.roboto(color: Colors.white),
                  prefixIcon: Icon(Icons.business, color: Colors.grey),
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
                  counterText: "",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                ],
                validator: _validateName,
                maxLength: 25,
              ),
              SizedBox(height: 20),
              TextFormField(
                style: GoogleFonts.roboto(color: Colors.white),
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Username de la empresa',
                  labelStyle: GoogleFonts.roboto(color: Colors.white),
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
                  counterText: "",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z0-9._-]+$')),
                ],
                validator: _validateUsername,
                maxLength: 15,
              ),
              SizedBox(height: 20),
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
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          _selectedCountry != null ? Colors.white : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedCountry ?? 'Seleccione la nacionalidad',
                          style: GoogleFonts.roboto(
                            color: _selectedCountry != null
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                                print('El username ya está en uso');
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              print('Error adding company: $e');
                            }
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                            print('Todos los campos son obligatorios');
                          }
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                style: buttonPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoading
                        ? SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            'Agregar',
                            style: GoogleFonts.roboto(
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
}
