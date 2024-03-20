import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles/button.dart';
import '../styles/color.dart';

class CompanyPage extends StatelessWidget {
  final String? uid;

  CompanyPage({this.uid});

  Future<List<Map<String, dynamic>>> _fetchCompanyData(String? uid) async {
    if (uid != null) {
      try {
        QuerySnapshot companySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

        List<Map<String, dynamic>> companies = [];

        companySnapshot.docs.forEach((doc) {
          companies.add(doc.data() as Map<String, dynamic>);
        });

        return companies;
      } catch (e) {
        print('Error fetching company data: $e');
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchCompanyData(uid),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else {
          List<Map<String, dynamic>> companies = snapshot.data ?? [];

          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      'Todavía no tienes empresa. ¿Quieres crear una ya?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showAddCompanyDialog(context);
                    },
                    child: Text(
                      'Agregar una empresa',
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      'O puedes recibir invitacions para unirte a una empresa',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: buttonPrimary,
                    onPressed: () {
                      _showAddCompanyDialog(context);
                    },
                    label: Text(
                      'Invitaciones',
                      style: GoogleFonts.openSans(
                        color: white,
                      ),
                    ),
                    icon: const Icon(Icons.send),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón (si es necesario)
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          companyData['name'],
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tipo: ${companyData['type']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showAddCompanyDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 242, 187, 29),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Agregar una empresa',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
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
                String ownerUid = uid ?? '';

                if (companyName.isNotEmpty &&
                    companyType.isNotEmpty &&
                    ownerUid.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('companies')
                        .add({
                      'name': companyName,
                      'type': companyType,
                      'ownerUid': ownerUid,
                    });

                    Navigator.pop(
                        context); // Cerrar el diálogo después de agregar la empresa
                  } catch (e) {
                    print('Error adding company: $e');
                    // Manejar el error si ocurriera al agregar la empresa
                    // Aquí podrías mostrar un mensaje de error al usuario si lo deseas
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
