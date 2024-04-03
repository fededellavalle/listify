import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                          width: 120, // Ancho de la imagen
                          height: 120, // Alto de la imagen
                          fit: BoxFit
                              .cover, // Ajuste de la imagen para cubrir todo el espacio disponible
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la empresa',
                labelStyle: GoogleFonts.roboto(color: Colors.white),
                prefixIcon:
                    Icon(Icons.person, color: Colors.grey), // Color del icono
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
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
                      color:
                          Color.fromARGB(255, 158, 128, 36)), // Borde regular
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'Username de la empresa',
                labelStyle: GoogleFonts.roboto(color: Colors.white),
                prefixIcon: Icon(Icons.alternate_email,
                    color: Colors.grey), // Icono de arroba al frente
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
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
                      color:
                          Color.fromARGB(255, 158, 128, 36)), // Borde regular
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Acción al presionar el botón de agregar
                String companyName = nameController.text.trim();
                String companyUser = userController.text.trim();
                String ownerUid = widget.uid ?? '';

                if (companyName.isNotEmpty &&
                    companyUser.isNotEmpty &&
                    ownerUid.isNotEmpty) {
                  try {
                    // Verificar si el username ya existe en Firestore
                    QuerySnapshot<Map<String, dynamic>> usernameCheck =
                        await FirebaseFirestore.instance
                            .collection('companies')
                            .where('username', isEqualTo: companyUser)
                            .get();

                    if (usernameCheck.docs.isEmpty) {
                      // El username es único, proceder con el registro de la empresa
                      String imageUrl = '';

                      if (_image != null) {
                        // Subir la imagen a Firebase Storage
                        Reference ref = FirebaseStorage.instance.ref().child(
                            'company_images/$companyUser/company_image.jpg');
                        UploadTask uploadTask = ref.putFile(_image!);
                        TaskSnapshot taskSnapshot =
                            await uploadTask.whenComplete(() => null);
                        imageUrl = await taskSnapshot.ref.getDownloadURL();
                      } else {
                        imageUrl =
                            'https://firebasestorage.googleapis.com/v0/b/app-listas-eccd1.appspot.com/o/users%2Fcompany-image-standard.png?alt=media&token=215f501d-c691-4804-93d3-97187cf5e677';
                      }

                      // Guardar la información de la empresa en Firestore junto con la URL de la imagen
                      await FirebaseFirestore.instance
                          .collection('companies')
                          .doc(
                              companyUser) // Utilizar el username como ID del documento
                          .set({
                        'name': companyName,
                        'username': companyUser,
                        'ownerUid': ownerUid,
                        'imageUrl': imageUrl,
                      });

                      Navigator.pop(
                          context); // Cerrar el diálogo después de agregar la empresa
                    } else {
                      // Mostrar mensaje de error si el username ya está en uso
                      print('El username ya está en uso');
                    }
                  } catch (e) {
                    print('Error adding company: $e');
                    // Manejar el error si ocurriera al agregar la empresa
                  }
                } else {
                  // Mostrar un mensaje al usuario si algún valor está vacío
                  print('Todos los campos son obligatorios');
                }
              },
              style: buttonPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Agregar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
