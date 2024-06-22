import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEditCompany/inviteCoOwner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditCompanyPage extends StatefulWidget {
  final Map<String, dynamic> companyData;

  EditCompanyPage({required this.companyData});

  @override
  _EditCompanyPageState createState() => _EditCompanyPageState();
}

class _EditCompanyPageState extends State<EditCompanyPage> {
  String? _companyImageUrl;
  TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    print(widget.companyData);
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    setState(() {
      _companyImageUrl = widget.companyData['imageUrl'];
      _nameController.text = widget.companyData['name'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
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
          toolbarTitle: 'Recortar imagen',
          toolbarColor: Colors.blue,
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
          title: 'Recortar imagen',
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

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('company_images')
          .child(widget.companyData['companyId'] + '.jpg');

      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['companyId'])
          .update({'imageUrl': downloadUrl});

      setState(() {
        _companyImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['username'])
          .update({
        'name': _nameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company details updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update company details: $e')),
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
          'Editar Empresa',
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
                            : _companyImageUrl != null
                                ? NetworkImage(_companyImageUrl!)
                                : AssetImage('assets/apple.png')
                                    as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    Text(
                      'Toca para cambiar la imagen de la empresa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    _buildEditableField('Nombre', _nameController, scaleFactor),
                    _buildCompanyInfo('Username',
                        widget.companyData['username'], scaleFactor),
                    _buildCompanyInfo('Instagram',
                        widget.companyData['instagram'], scaleFactor),
                    _buildCompanyInfo('Nationality',
                        widget.companyData['nationality'], scaleFactor),
                    _buildCompanyInfo('Subscription',
                        widget.companyData['subscription'], scaleFactor),
                    _buildCompanyInfo('Owner UID',
                        widget.companyData['ownerUid'], scaleFactor),
                    _buildCoOwnerField(
                        widget.companyData['co-ownerUid'], scaleFactor),
                    SizedBox(height: 16 * scaleFactor),
                    CupertinoButton(
                      onPressed: () {
                        _uploadImage();
                        _saveChanges();
                      },
                      color: Colors.blue,
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

  Widget _buildEditableField(
      String label, TextEditingController controller, double scaleFactor) {
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
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16 * scaleFactor,
                  fontFamily: 'SFPro',
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(String label, String value, double scaleFactor) {
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

  Widget _buildCoOwnerField(String? coOwner, double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Co-Owner:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
            ),
          ),
          Expanded(
            child: coOwner != null && coOwner.isNotEmpty
                ? Text(
                    coOwner,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                  )
                : CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteCoOwner(
                                  companyData: widget.companyData,
                                )),
                      );
                    },
                    color: Colors.blue,
                    child: Text(
                      'Invitar Co-Owner',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        color: Colors.black,
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
