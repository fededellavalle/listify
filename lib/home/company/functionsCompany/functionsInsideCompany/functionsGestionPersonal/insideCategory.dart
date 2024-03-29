import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../styles/button.dart';
import 'package:unicons/unicons.dart';
import 'functionsInsideCategory/invitePeopleToCategory.dart';

class InsideCategory extends StatefulWidget {
  final String categoryName;
  final Map<String, dynamic> companyData;
  final List<String> emails; // Lista de correos electrónicos

  const InsideCategory({
    Key? key,
    required this.categoryName,
    required this.companyData,
    required this.emails,
  }) : super(key: key);

  @override
  State<InsideCategory> createState() => _InsideCategoryState();
}

class _InsideCategoryState extends State<InsideCategory> {
  List<dynamic> persons = [];
  List<dynamic> invitations = [];

  void loadPersons() async {
    DocumentReference categoryRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('personalCategories')
        .doc(widget.categoryName);

    DocumentSnapshot categorySnapshot = await categoryRef.get();

    Map<String, dynamic>? categoryData =
        categorySnapshot.data() as Map<String, dynamic>?;

    setState(() {
      persons = categoryData?['persons'] ?? [];
    });

    print('Persons: $persons');
  }

  void loadInvitations() async {
    DocumentReference categoryRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('personalCategories')
        .doc(widget.categoryName);

    DocumentSnapshot categorySnapshot = await categoryRef.get();

    Map<String, dynamic>? categoryData =
        categorySnapshot.data() as Map<String, dynamic>?;

    setState(() {
      invitations = categoryData?['invitations'] ?? [];
    });

    print('Invitations: $invitations');
  }

  @override
  void initState() {
    super.initState();
    loadPersons();
    loadInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Personas en ${widget.categoryName}',
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            InvitePeopleToCategory(
                                categoryName: widget.categoryName,
                                companyData: widget.companyData,
                                emails: widget.emails),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.linearToEaseOut,
                                reverseCurve: Curves.easeIn,
                              ),
                            ),
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  icon: Icon(
                    UniconsLine.plus_circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          DataTable(
            columnSpacing:
                30, // Ajusta el espacio entre las columnas según sea necesario
            columns: [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Instagram')),
              DataColumn(label: Text('')),
            ],
            rows: [
              ...persons.map((personEmail) {
                String personName =
                    ''; // Aquí deberías tener el nombre de la persona
                String personInstagram =
                    ''; // Aquí deberías tener el Instagram de la persona

                return DataRow(cells: [
                  DataCell(Text(personName)),
                  DataCell(Text(personEmail)),
                  DataCell(Text(personInstagram)),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.red,
                      onPressed: () {
                        deleteInvitation(
                            personEmail); // Llama al método para eliminar la invitación
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ],
          ),
          SizedBox(height: 20), // Agrega un espacio entre las dos DataTables
          DataTable(
            columns: [
              DataColumn(label: Text('Email de persona invitada')),
            ],
            rows: [
              ...invitations.map((personEmail) {
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Text(personEmail),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.red,
                          ),
                        ),
                        onPressed: () {
                          deleteInvitation(
                              personEmail); // Llama al método para eliminar la invitación
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  void deleteInvitation(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content:
              Text('¿Estás seguro de que quieres eliminar esta invitación?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Eliminar la invitación del estado
                setState(() {
                  invitations.remove(email);
                });

                // Eliminar la invitación de la base de datos
                FirebaseFirestore.instance
                    .collection('companies')
                    .doc(widget.companyData['companyId'])
                    .collection('personalCategories')
                    .doc(widget.categoryName)
                    .update({
                  'invitations': FieldValue.arrayRemove([email]),
                }).then((value) {
                  print('Invitación eliminada de la base de datos');
                }).catchError((error) {
                  print('Error al eliminar la invitación: $error');
                  // Aquí puedes manejar cualquier error que ocurra al eliminar la invitación
                  // Por ejemplo, puedes revertir el cambio en el estado si hay un error
                  setState(() {
                    invitations
                        .add(email); // Volver a agregar la invitación al estado
                  });
                });

                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de eliminar
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
