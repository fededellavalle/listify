import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : AssetImage('assets/apple.png')
                                    as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tap to change profile image',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    _buildUserInfo('Name', _name),
                    _buildUserInfo('Last Name', _lastname),
                    _buildUserInfo('Email', _email),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
