import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsGestionPersonal/functionsInsideCategory/invitePeopleToCategory.dart';
import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsGestionPersonal/functionsInsideCategory/member_info_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Map<String, dynamic>> memberUIDs = [];
  List<String> invitations = [];
  List<Map<String, dynamic>> membersInfo = [];
  List<Map<String, dynamic>> filteredMembers = [];
  String searchQuery = '';

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
            memberUIDs = List<Map<String, dynamic>>.from(membersData);
          });
          await loadMembersInfo();
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

  Future<void> loadMembersInfo() async {
    List<Map<String, dynamic>> loadedMembersInfo = [];

    for (Map<String, dynamic> uidMap in memberUIDs) {
      String userUid = uidMap['userUid'];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          userData['uid'] = userUid;
          loadedMembersInfo.add(userData);
        }
      }
    }

    setState(() {
      membersInfo = loadedMembersInfo;
      filteredMembers = membersInfo;
    });
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
      if (categoryData != null && categoryData.containsKey('invitations')) {
        invitations = List<String>.from(categoryData['invitations']);
      } else {
        invitations = [];
      }
    });

    print('Invitations: $invitations');
  }

  void filterMembers(String query) {
    setState(() {
      searchQuery = query;
      filteredMembers = membersInfo.where((member) {
        final name = member['name']?.toLowerCase() ?? '';
        final email = member['email']?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadMembers();
    loadInvitations();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Personas en ${widget.categoryName}',
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
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
                CupertinoIcons.add_circled_solid,
                size: 20 * scaleFactor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0 * scaleFactor),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar miembros...',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
              onChanged: filterMembers,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: 20 * scaleFactor, vertical: 10 * scaleFactor),
              children: [
                Center(
                  child: Text(
                    'Miembros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * scaleFactor,
                      fontFamily: 'SFPro',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (filteredMembers.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20 * scaleFactor),
                      child: Text(
                        'No hay miembros en la categoría',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ),
                  ),
                ...filteredMembers.map((member) {
                  String memberName = member['name'] ?? '';
                  String memberApellido = member['lastname'] ?? '';
                  String memberEmail = member['email'] ?? '';
                  String memberInstagram = member['instagram'] ?? '';
                  String memberUid = member['uid'] ?? '';

                  print(member);

                  return GestureDetector(
                    onTap: () {
                      if (memberUid.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MemberInfoModal(
                              userUid: memberUid,
                              scaleFactor: scaleFactor,
                            );
                          },
                        );
                      } else {
                        print('Error: UID del miembro está vacío.');
                      }
                    },
                    child: Card(
                      color: Colors.grey.shade900,
                      margin: EdgeInsets.symmetric(vertical: 5 * scaleFactor),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * scaleFactor),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10 * scaleFactor,
                          horizontal: 15 * scaleFactor,
                        ),
                        title: Text(
                          '$memberName $memberApellido',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * scaleFactor,
                            fontFamily: 'SFPro',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: $memberEmail',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            Text(
                              'Instagram: $memberInstagram',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          color: Colors.red,
                          onPressed: () {
                            deleteMember(memberUid, scaleFactor);
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20 * scaleFactor),
                Center(
                  child: Text(
                    'Invitaciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * scaleFactor,
                      fontFamily: 'SFPro',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (invitations.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20 * scaleFactor),
                      child: Text(
                        'No hay invitaciones hechas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ),
                  ),
                ...invitations.map((memberEmail) {
                  return Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(vertical: 5 * scaleFactor),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * scaleFactor),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10 * scaleFactor,
                        horizontal: 15 * scaleFactor,
                      ),
                      title: Text(
                        memberEmail,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.red,
                        onPressed: () {
                          deleteInvitation(memberEmail, scaleFactor);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void deleteInvitation(String email, double scaleFactor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 18 * scaleFactor,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar esta invitación?',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
              ),
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

                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de eliminar
              },
              child: Text(
                'Aceptar',
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

  void deleteMember(String uid, double scaleFactor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 18 * scaleFactor,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar a este miembro de ${widget.categoryName}?',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Remove member from the membersInfo list
                  setState(() {
                    membersInfo.removeWhere((member) => member['uid'] == uid);
                  });

                  // Remove member from the personalCategories collection
                  await FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyData['companyId'])
                      .collection('personalCategories')
                      .doc(widget.categoryName)
                      .update({
                    'members': FieldValue.arrayRemove([
                      {'userUid': uid}
                    ]),
                  });
                  print('Miembro eliminado de la categoría');

                  // Remove company relationship from the user's document
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'companyRelationship': FieldValue.arrayRemove([
                      {
                        'category': widget.categoryName,
                        'companyUsername': widget.companyData['username'],
                      }
                    ]),
                  });
                  print(
                      'Relación de miembro eliminada de la base de datos del usuario');

                  // Remove member from the company's main collection
                  await FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyData['companyId'])
                      .collection('personalCategories')
                      .doc(widget.categoryName)
                      .update({
                    'members': FieldValue.arrayRemove([uid]),
                  });
                  print('Miembro eliminado de la compañía');

                  // Cerrar el diálogo después de eliminar
                  Navigator.of(context).pop();
                } catch (error) {
                  print('Error al eliminar el miembro: $error');
                  setState(() {
                    loadMembersInfo();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Aceptar',
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
}
