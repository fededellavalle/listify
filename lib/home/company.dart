import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

          return ListView(
            padding: EdgeInsets.all(20), // Añadir espacio alrededor de la lista
            children: [
              // Mostrar cada empresa en la lista
              for (var companyData in companies) ...[
                SizedBox(height: 20),
                // Botón rectangular con el nombre de la empresa y el tipo
                SizedBox(
                  width: double.infinity, // Ocupar todo el ancho disponible
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón (si es necesario)
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Sin radio de borde
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
              // Botón para agregar una nueva empresa
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Ocupar todo el ancho disponible
                child: ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón para agregar una empresa
                    _showAddCompanyDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Sin radio de borde
                    ),
                  ),
                  child: Text('Agregar una empresa'),
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

                if (companyName.isNotEmpty && companyType.isNotEmpty && ownerUid.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('companies').add({
                      'name': companyName,
                      'type': companyType,
                      'ownerUid': ownerUid,
                    });

                    Navigator.pop(context); // Cerrar el diálogo después de agregar la empresa
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
