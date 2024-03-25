import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'functionsCompany/insideCompany.dart';

class CompanyPage extends StatefulWidget {
  final String? uid;

  CompanyPage({this.uid});

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  File? _image;

  @override
  void initState() {
    super.initState();
  }

  void _openCompanyDetails(Map<String, dynamic> companyData) {
    print('Company Data: $companyData');
    print("entre al boton");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyWidget(companyData: companyData),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCompanyData(String? uid) async {
    if (uid != null) {
      try {
        QuerySnapshot companySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

        List<Map<String, dynamic>> companies = [];

        await Future.forEach(companySnapshot.docs, (doc) async {
          String companyId = doc.id;
          String companyName = (doc.data() as Map<String, dynamic>)['name'];
          String companyType = (doc.data() as Map<String, dynamic>)['type'];
          String? imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];

          Map<String, dynamic> companyData = {
            'companyId': companyId,
            'name': companyName,
            'type': companyType,
            'imageUrl': imageUrl,
          };

          companies.add(companyData);
        });

        print(companies);
        return companies;
      } catch (e) {
        print('Error fetching company data: $e');
        return [];
      }
    } else {
      return [];
    }
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
      backgroundColor:
          Colors.black.withOpacity(0.0), // Color de fondo del Scaffold
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else {
            List<Map<String, dynamic>> companies = [];

            snapshot.data?.docs.forEach((doc) {
              String companyId = doc.id;
              String companyName = doc['name'];
              String companyType = doc['type'];
              String? imageUrl = doc['imageUrl'];

              Map<String, dynamic> companyData = {
                'companyId': companyId,
                'name': companyName,
                'type': companyType,
                'imageUrl': imageUrl,
              };

              companies.add(companyData);
            });

            if (companies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Todavía no tienes empresa. ¿Quieres crear una ya?',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showAddCompanyDialog(context);
                      },
                      child: Text('Agregar una empresa'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                for (var companyData in companies) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Company Details button pressed');
                      _openCompanyDetails(companyData);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.red,
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(20),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (companyData['imageUrl'] != null)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(companyData['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.question_mark),
                            onPressed: () {},
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                companyData['name'] ?? '',
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Tipo: ${companyData['type'] ?? ''}',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 20),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddCompanyDialog(context);
        },
        backgroundColor: Color.fromARGB(255, 242, 187, 29),
        icon: Icon(Icons.add),
        label: Text('Agregar empresa'),
      ),
    );
  }

  // Función para mostrar un diálogo para agregar una nueva empresa
  void _showAddCompanyDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar una nueva empresa'),
          content: Column(
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
                            width: 100, // Ancho de la imagen
                            height: 100, // Alto de la imagen
                            fit: BoxFit
                                .cover, // Ajuste de la imagen para cubrir todo el espacio disponible
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre de la empresa'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Tipo de empresa'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Acción al presionar el botón de cancelar
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Acción al presionar el botón de agregar
                String companyName = nameController.text.trim();
                String companyType = typeController.text.trim();
                String ownerUid = widget.uid ?? '';
                String companyId =
                    Uuid().v4(); // Generar un ID único para la compañía

                if (companyName.isNotEmpty &&
                    companyType.isNotEmpty &&
                    ownerUid.isNotEmpty) {
                  try {
                    String imageUrl = '';

                    if (_image != null) {
                      // Subir la imagen a Firebase Storage
                      Reference ref = FirebaseStorage.instance
                          .ref()
                          .child('company_images/$companyId/company_image.jpg');
                      UploadTask uploadTask = ref.putFile(_image!);
                      TaskSnapshot taskSnapshot =
                          await uploadTask.whenComplete(() => null);
                      imageUrl = await taskSnapshot.ref.getDownloadURL();
                    }

                    // Guardar la información de la empresa en Firestore junto con la URL de la imagen
                    await FirebaseFirestore.instance
                        .collection('companies')
                        .doc(companyId)
                        .set({
                      'name': companyName,
                      'type': companyType,
                      'ownerUid': ownerUid,
                      'imageUrl': imageUrl,
                    });

                    Navigator.pop(
                        context); // Cerrar el diálogo después de agregar la empresa
                  } catch (e) {
                    print('Error adding company: $e');
                    // Manejar el error si ocurriera al agregar la empresa
                  }
                } else {
                  // Mostrar un mensaje al usuario si algún valor está vacío
                  print('Todos los campos son obligatorios');
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
