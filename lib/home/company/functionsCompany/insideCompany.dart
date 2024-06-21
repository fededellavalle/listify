import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/editCompany.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import '../../../styles/button.dart';
import 'functionsInsideCompany/gestionPersonal.dart';
import 'functionsInsideCompany/eventsCompany.dart';

class CompanyWidget extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final bool isOwner;
  final String? companyCategory;

  const CompanyWidget({
    Key? key,
    required this.companyData,
    required this.isOwner,
    this.companyCategory,
  }) : super(key: key);

  @override
  State<CompanyWidget> createState() => _CompanyWidgetState();
}

class _CompanyWidgetState extends State<CompanyWidget> {
  late String uid;

  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
    }
  }

  void leaveCompany(BuildContext context, String companyId) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Confirmar salida',
            style: TextStyle(color: Colors.black),
          ),
          message: Text(
            '¿Estás seguro de que quieres salir de la empresa?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'companyRelationship': FieldValue.arrayRemove([
                      {
                        'category': widget.companyCategory,
                        'companyUsername': companyId,
                      }
                    ]),
                  });

                  await FirebaseFirestore.instance
                      .collection('companies')
                      .doc(companyId)
                      .collection('personalCategories')
                      .doc(widget.companyCategory)
                      .update({
                    'members': FieldValue.arrayRemove([
                      {'userUid': uid}
                    ]),
                  });

                  Navigator.of(context).pop(); // Cerrar el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Has salido de la empresa.'),
                    ),
                  );
                } catch (error) {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al salir de la empresa.'),
                    ),
                  );
                }
              },
              child: Text('Aceptar'),
              isDestructiveAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text('Cancelar'),
            isDefaultAction: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    String companyName = widget.companyData['name'] ?? '';
    String companyImageUrl = widget.companyData['imageUrl'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          companyName,
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
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20 * scaleFactor),
              if (companyImageUrl.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(companyImageUrl),
                  radius: 80 * scaleFactor,
                ),
              SizedBox(height: 20 * scaleFactor),
              Text(
                '$companyName',
                style: TextStyle(
                  fontSize: 25 * scaleFactor,
                  color: Colors.white,
                  fontFamily: 'SFPro',
                ),
              ),
              SizedBox(height: 10 * scaleFactor),
              Text(
                '@${widget.companyData['username'] ?? ''}',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  color: Colors.white,
                  fontFamily: 'SFPro',
                ),
              ),
              SizedBox(height: 20 * scaleFactor),

              // Botones de acciones dentro de la empresa
              if (widget.isOwner)
                Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        child: Column(
                          children: [
                            //Eventos Boton
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EventosPage(
                                      companyData: widget.companyData,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        UniconsSolid.calender,
                                        size: 20 * scaleFactor,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15 * scaleFactor,
                                  ),
                                  Text(
                                    'Gestionar Eventos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    UniconsLine.angle_right_b,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),

                            // Gestionar Personal
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        GestionPersonal(
                                      companyData: widget.companyData,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        UniconsSolid.user_arrows,
                                        size: 20 * scaleFactor,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15 * scaleFactor,
                                  ),
                                  Text(
                                    'Gestionar Personal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    UniconsLine.angle_right_b,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),

                            // Editar Personal
                            ElevatedButton(
                              onPressed: () {},
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        UniconsSolid.user_arrows,
                                        size: 20 * scaleFactor,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15 * scaleFactor,
                                  ),
                                  Text(
                                    'Editar Personal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    UniconsLine.angle_right_b,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EditCompanyPage(
                                      companyData: widget.companyData,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        CupertinoIcons.pen,
                                        size: 20 * scaleFactor,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15 * scaleFactor,
                                  ),
                                  Text(
                                    'Editar Empresa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    UniconsLine.angle_right_b,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                            //Eliminar compania
                            ElevatedButton(
                              onPressed: () {},
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        UniconsLine.trash,
                                        size: 20 * scaleFactor,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15 * scaleFactor,
                                  ),
                                  Text(
                                    'Eliminar Empresa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    UniconsLine.angle_right_b,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                  ],
                ),

              if (!widget.isOwner)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            leaveCompany(
                                context, widget.companyData['username']);
                          },
                          style: buttonCompany,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(8 * scaleFactor),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0 * scaleFactor),
                                  child: Icon(
                                    CupertinoIcons.square_arrow_right_fill,
                                    size: 20 * scaleFactor,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15 * scaleFactor,
                              ),
                              Text(
                                'Salir de la Empresa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                              Spacer(),
                              Icon(
                                UniconsLine.angle_right_b,
                                size: 20 * scaleFactor,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20 * scaleFactor),
            ],
          ),
        ),
      ),
    );
  }
}
