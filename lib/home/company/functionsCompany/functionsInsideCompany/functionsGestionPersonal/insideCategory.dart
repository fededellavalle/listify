import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../styles/button.dart';
import 'package:unicons/unicons.dart';
import 'functionsInsideCategory/invitePeopleToCategory.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<dynamic> members = [];
  List<dynamic> invitations = [];

  void loadMembers() async {
    DocumentReference categoryRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('personalCategories')
        .doc(widget.categoryName);

    DocumentSnapshot categorySnapshot = await categoryRef.get();

    if (categorySnapshot.exists) {
      Map<String, dynamic>? categoryData =
          categorySnapshot.data() as Map<String, dynamic>?;

      if (categoryData != null && categoryData.containsKey('members')) {
        var membersData = categoryData['members'];

        if (membersData is List && membersData.isNotEmpty) {
          setState(() {
            members = List.from(membersData);
            print(members);
          });
        } else {
          print('Error: membersData is not a non-empty list');
        }
      } else {
        print('Error: categoryData does not contain key "members"');
      }
    } else {
      print('Error: categorySnapshot does not exist');
    }
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
    loadMembers();
    loadInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              DataColumn(
                  label: Text(
                'Nombre',
                style: GoogleFonts.roboto(color: Colors.white),
              )),
              DataColumn(
                  label: Text(
                'Email',
                style: GoogleFonts.roboto(color: Colors.white),
              )),
              DataColumn(
                  label: Text(
                'Instagram',
                style: GoogleFonts.roboto(color: Colors.white),
              )),
              DataColumn(label: Text('')),
            ],
            rows: [
              ...members.map((member) {
                String memberName = member['completeName'] ?? '';
                String memberEmail = member['email'] ?? '';
                String memberInstagram = member['instagram'] ?? '';

                return DataRow(cells: [
                  DataCell(Text(
                    memberName,
                    style: GoogleFonts.roboto(color: Colors.white),
                  )),
                  DataCell(Text(
                    memberEmail,
                    style: GoogleFonts.roboto(color: Colors.white),
                  )),
                  DataCell(Text(
                    memberInstagram,
                    style: GoogleFonts.roboto(color: Colors.white),
                  )),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.red,
                      onPressed: () {
                        deleteMember(memberName, memberEmail, memberInstagram);
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
              DataColumn(
                  label: Text(
                'Email de persona invitada',
                style: GoogleFonts.roboto(color: Colors.white),
              )),
            ],
            rows: [
              ...invitations.map((memberEmail) {
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Text(
                        memberEmail,
                        style: GoogleFonts.roboto(color: Colors.white),
                      ),
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
                              memberEmail); // Llama al método para eliminar la invitación
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
                  setState(() {
                    invitations.add(email);
                  });
                });

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
                  setState(() {
                    invitations.add(email);
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

  void deleteMember(String name, String email, String instagram) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que quieres eliminar a $name de ${widget.categoryName}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  members.removeWhere((member) => member['email'] == email);
                });

                FirebaseFirestore.instance
                    .collection('companies')
                    .doc(widget.companyData['companyId'])
                    .collection('personalCategories')
                    .doc(widget.categoryName)
                    .update({
                  'members': FieldValue.arrayRemove([
                    {
                      'completeName': name,
                      'email': email,
                      'instagram': instagram,
                    }
                  ]),
                }).then((value) {
                  print('Invitación eliminada de la base de datos');
                }).catchError((error) {
                  print('Error al eliminar la invitación: $error');

                  setState(() {
                    members.add({
                      'completeName': name,
                      'email': email,
                      'instagram': instagram,
                    });
                  });
                });

                User? user = FirebaseAuth.instance.currentUser;

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .update({
                  'companyRelationship': FieldValue.arrayRemove([
                    {
                      'category': widget.categoryName,
                      'companyUsername': widget.companyData['username'],
                    }
                  ]),
                }).then((value) {
                  print('Invitación eliminada de la base de datos');
                }).catchError((error) {
                  print('Error al eliminar la invitación: $error');
                  setState(() {
                    invitations.add(email);
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
