import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../styles/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class crearCategoriaPersonal extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const crearCategoriaPersonal({
    super.key,
    required this.companyData,
  });

  @override
  State<crearCategoriaPersonal> createState() => _crearCategoriaPersonalState();
}

class _crearCategoriaPersonalState extends State<crearCategoriaPersonal> {
  TextEditingController nameController = TextEditingController();
  bool? isChecked = false;
  bool? isChecked2 = false;
  bool? isChecked3 = false;
  bool? isChecked4 = false;
  List<String> selectedPermises = [];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Crear Categoria de Personal",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nombre de la categoría',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
            SizedBox(height: 20 * scaleFactor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona los permisos que la categoría va a obtener en la empresa',
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10 * scaleFactor),
                SwitchListTile(
                  title: Text(
                    'Leer Listas',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  activeColor: Colors.green,
                  value: isChecked!,
                  onChanged: (bool value) {
                    setState(() {
                      isChecked = value;
                      if (isChecked! && !selectedPermises.contains('Leer')) {
                        selectedPermises.add('Leer');
                      } else {
                        selectedPermises.remove('Leer');
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    'Escribir o Hacer Listas',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  activeColor: Colors.green,
                  value: isChecked2!,
                  onChanged: (bool value) {
                    setState(() {
                      isChecked2 = value;
                      if (isChecked2! &&
                          !selectedPermises.contains('Escribir')) {
                        selectedPermises.add('Escribir');
                      } else {
                        selectedPermises.remove('Escribir');
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(
                    'Poder gestionar el personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  activeColor: Colors.green,
                  value: isChecked3!,
                  onChanged: (bool value) {
                    setState(() {
                      isChecked3 = value;
                      if (isChecked3! &&
                          !selectedPermises.contains('Gestionar')) {
                        selectedPermises.add('Gestionar');
                      } else {
                        selectedPermises.remove('Gestionar');
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8 * scaleFactor),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20 * scaleFactor,
                ),
                SizedBox(width: 5 * scaleFactor),
                Expanded(
                  child: Text(
                    'Una vez creada la categoria, no se puede cambiarle el nombre',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14 * scaleFactor,
                      fontFamily: 'SFPro',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * scaleFactor),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            String categoryName = nameController.text;
                            List<String> selectedPermissions =
                                this.selectedPermises;

                            if (categoryName.isNotEmpty &&
                                selectedPermissions.isNotEmpty) {
                              CollectionReference categoryCollection =
                                  FirebaseFirestore.instance
                                      .collection('companies')
                                      .doc(widget.companyData['companyId'])
                                      .collection('personalCategories');

                              await categoryCollection.doc(categoryName).set({
                                'nombre': categoryName,
                                'permissions': selectedPermissions,
                                'members': [],
                                'invitations': [],
                              });

                              nameController.clear();
                              setState(() {
                                this.selectedPermises.clear();
                              });

                              setState(() {
                                isLoading = true;
                              });

                              Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Categoria Creada',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: 18 * scaleFactor,
                                      ),
                                    ),
                                    content: Text(
                                      'Su categoria fue creada exitosamente',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: 16 * scaleFactor,
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
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Error',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: 18 * scaleFactor,
                                      ),
                                    ),
                                    content: Text(
                                      'Error al crear la categoria, debes ponerle nombre o tienes que seleccionar alguna opcion',
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: 16 * scaleFactor,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Ok',
                                          style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                    color: skyBluePrimary,
                    child: isLoading
                        ? CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Crear categoria',
                            style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 16 * scaleFactor,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20 * scaleFactor),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () {
                      nameController.clear();
                      setState(() {
                        this.selectedPermises.clear();
                      });
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    child: isLoading
                        ? CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Cancelar',
                            style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 16 * scaleFactor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
