import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart'; // Para el DateFormat

class EditProfilePage extends StatefulWidget {
  final String? uid;

  EditProfilePage({this.uid});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _profileImageUrl;
  String _name = '';
  String _lastname = '';
  String _email = '';
  String _instagram = '';
  DateTime? _birthDate;
  String _nacionality = '';
  String _subscription = '';
  bool _isLoading = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _profileImageUrl = userData['imageUrl'];
        _name = userData['name'] ?? '';
        _lastname = userData['lastname'] ?? '';
        _email = FirebaseAuth.instance.currentUser?.email ?? '';
        _instagram = userData['instagram'] ?? '';
        _birthDate = (userData['birthDate'] as Timestamp?)?.toDate();
        _nacionality = userData['nationality'] ?? '';
        _subscription = userData['subscription'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 512,
      maxHeight: 512,
      cropStyle: CropStyle.circle,
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(widget.uid! + '.jpg');

      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'imageUrl': downloadUrl});

      Navigator.pop(context, downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 20 * scaleFactor,
            fontFamily: 'SFPro',
            color: Colors.white,
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
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50 * scaleFactor,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : AssetImage('assets/apple.png')
                                    as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    Text(
                      'Toca para cambiar la imagen de perfil',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    _buildUserInfo('Nombre', _name, scaleFactor),
                    _buildUserInfo('Apellido', _lastname, scaleFactor),
                    _buildUserInfo('Email', _email, scaleFactor),
                    _buildUserInfo('Instagram', _instagram, scaleFactor),
                    _buildUserInfo(
                        'Fecha de Nacimiento',
                        _birthDate != null
                            ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                            : '',
                        scaleFactor),
                    _buildUserInfo('Nacionalidad', _nacionality, scaleFactor),
                    _buildUserInfo('Suscripción', _subscription, scaleFactor),
                    SizedBox(height: 16 * scaleFactor),
                    CupertinoButton(
                      onPressed: _uploadImage,
                      color: skyBluePrimary,
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.black,
                          fontSize: 16 * scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfo(String label, String value, double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
