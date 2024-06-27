import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEditCompany/inviteCoOwner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String ownerName = '';
  String coOwnerName = 'Invitar Co-Owner';

  @override
  void initState() {
    super.initState();
    print(widget.companyData);
    _fetchUserNames(
        widget.companyData['ownerUid'], widget.companyData['co-ownerUid']);
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    setState(() {
      _companyImageUrl = widget.companyData['imageUrl'];
      _nameController.text = widget.companyData['name'] ?? '';
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserNames(String ownerUid, String? coOwnerUid) async {
    try {
      // Fetch owner name
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerUid)
          .get();

      setState(() {
        if (ownerSnapshot.exists && ownerSnapshot.data() != null) {
          var ownerData = ownerSnapshot.data() as Map<String, dynamic>;
          ownerName =
              ownerData.containsKey('lastName') && ownerData['lastName'] != null
                  ? '${ownerData['name']} ${ownerData['lastName']}'
                  : '${ownerData['name']}';
        }
      });

      if (coOwnerUid != null && coOwnerUid.isNotEmpty) {
        // Fetch co-owner name if co-owner UID is not null or empty
        DocumentSnapshot coOwnerSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(coOwnerUid)
            .get();

        setState(() {
          if (coOwnerSnapshot.exists && coOwnerSnapshot.data() != null) {
            var coOwnerData = coOwnerSnapshot.data() as Map<String, dynamic>;
            coOwnerName = coOwnerData.containsKey('lastName') &&
                    coOwnerData['lastName'] != null
                ? '${coOwnerData['name']} ${coOwnerData['lastName']}'
                : '${coOwnerData['name']}';
          }
        });
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }
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
          .doc(widget.companyData['companyUsername'])
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

  void _showDeleteConfirmationDialog(String coOwnerUid) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Eliminar Co-Owner"),
          content: Text("¿Está seguro de que desea eliminar el Co-Owner?"),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text("Eliminar"),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyData['companyUsername'])
                      .update({'co-ownerUid': null});
                  setState(() {
                    coOwnerName = 'Invitar Co-Owner';
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting co-owner: $e');
                }
              },
            ),
          ],
        );
      },
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

  Widget _buildCoOwnerField(String value, double scaleFactor) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return GestureDetector(
      onTap: () {
        if (widget.companyData['co-ownerUid'] != null) {
          if (currentUserUid == widget.companyData['ownerUid']) {
            _showDeleteConfirmationDialog(widget.companyData['co-ownerUid']);
          }
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => InviteCoOwner(
                companyData: widget.companyData,
              ),
            ),
          );
        }
      },
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
                Spacer(),
                if (widget.companyData['co-ownerUid'] != null &&
                    currentUserUid == widget.companyData['ownerUid'])
                  Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 24 * scaleFactor,
                  )
                else if (widget.companyData['co-ownerUid'] == null &&
                    currentUserUid == widget.companyData['ownerUid'])
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24 * scaleFactor,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
                        widget.companyData['companyUsername'], scaleFactor),
                    _buildCompanyInfo('Instagram',
                        widget.companyData['instagram'], scaleFactor),
                    _buildCompanyInfo('Nationality',
                        widget.companyData['nationality'], scaleFactor),
                    _buildCompanyInfo('Subscription',
                        widget.companyData['subscription'], scaleFactor),
                    _buildCompanyInfo('Owner', ownerName, scaleFactor),
                    _buildCoOwnerField(coOwnerName, scaleFactor),
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
}
