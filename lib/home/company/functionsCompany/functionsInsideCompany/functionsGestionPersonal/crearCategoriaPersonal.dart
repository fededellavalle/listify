import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../styles/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:unicons/unicons.dart';

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
  List<String> selectedPermises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Crear Categoria de Personal",
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nombre de la categoría',
                  hintStyle: TextStyle(
                      color: Colors
                          .grey), // Color del hint text (texto de sugerencia)
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Color del borde cuando está habilitado
                    borderRadius:
                        BorderRadius.circular(10.0), // Radio del borde
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Color del borde cuando está enfocado
                    borderRadius:
                        BorderRadius.circular(10.0), // Radio del borde
                  ),
                ),
                style: TextStyle(
                    color: Colors
                        .white), // Color del texto ingresado por el usuario
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona los permisos que la categoría va a obtener con las listas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign:
                        TextAlign.center, // Centra el texto horizontalmente
                  ),
                  SizedBox(height: 10),
                  CheckboxListTile(
                    title: Text(
                      'Leer Listas',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: isChecked,
                    onChanged: (bool? value) {
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
                  CheckboxListTile(
                    title: Text('Escribir o Hacer Listas',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    value: isChecked2,
                    onChanged: (bool? value) {
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
                  // Agrega más CheckboxListTile para otros permisos si es necesario
                ],
              ),
              SizedBox(
                  height:
                      20), // Espacio entre los CheckboxListTiles y los botones
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Obtener el nombre de la categoría y los tipos seleccionados
                      String categoryName = nameController.text;
                      List<String> selectedTypes = this.selectedPermises;

                      // Verificar que se haya ingresado un nombre de categoría válido
                      if (categoryName.isNotEmpty && selectedTypes.isNotEmpty) {
                        // Obtener la referencia a la colección de categorías personales dentro de la empresa
                        CollectionReference categoryCollection = FirebaseFirestore
                            .instance
                            .collection(
                                'companies') // Cambia 'empresas' por el nombre de tu colección de empresas
                            .doc(widget.companyData[
                                'companyId']) // 'id' es el campo que contiene el ID de la empresa
                            .collection('personalCategories');

                        // Crear un documento nuevo con el nombre de la categoría como ID
                        await categoryCollection.doc(categoryName).set({
                          'nombre': categoryName,
                          'tipos': selectedTypes,
                          'persons': [],
                          'invitations': [],
                        });

                        nameController.clear();
                        setState(() {
                          this.selectedPermises.clear();
                        });

                        // Cerrar el diálogo actual
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Categoria Creada'),
                              content:
                                  Text('Su categoria fue creada exitosamente'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Cerrar el AlertDialog
                                    Navigator.of(context)
                                        .pop(); // Volver a la pantalla anterior (login)
                                  },
                                  child: Text('OK'),
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
                              content: Text(
                                  'Error al crear la categoria, debes ponerle nombre o tienes que seleccionar alguna opcion'),
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
                    },
                    style: buttonPrimary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Agregar'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      nameController.clear();
                      setState(() {
                        this.selectedPermises.clear();
                      });
                      Navigator.pop(context);
                    },
                    style: buttonSecondary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cancelar',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
