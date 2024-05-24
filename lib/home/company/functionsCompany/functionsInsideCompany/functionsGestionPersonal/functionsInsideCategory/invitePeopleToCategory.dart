import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitePeopleToCategory extends StatefulWidget {
  final String categoryName;
  final Map<String, dynamic> companyData;
  final List<String> emails; // Lista de correos electrónicos

  const InvitePeopleToCategory({
    Key? key,
    required this.categoryName,
    required this.companyData,
    required this.emails,
  }) : super(key: key);

  @override
  State<InvitePeopleToCategory> createState() => _InvitePeopleToCategoryState();
}

class _InvitePeopleToCategoryState extends State<InvitePeopleToCategory> {
  TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    bool isLoading = false;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.black,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0 * scaleFactor),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Text(
                  'Invitemos a gente',
                  style: TextStyle(
                    fontSize: 25 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ingresa un email de alguna persona que quieras que se una a tu empresa.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15 * scaleFactor,
                color: Colors.grey.shade400,
                fontFamily: 'SFPro',
              ),
            ),
            SizedBox(
              height: 10 * scaleFactor,
            ),
            TextFormField(
              controller: userController,
              decoration: InputDecoration(
                hintText: 'Email del usuario al cual quieres invitar',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: skyBluePrimary),
                  borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: skyBlueSecondary),
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
                            await handleInvitation(scaleFactor);
                            setState(() {
                              isLoading = false;
                            });
                          },
                    color: skyBluePrimary,
                    child: isLoading
                        ? CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Invitar a unirse',
                            style: TextStyle(
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                                color: Colors.black),
                          ),
                  ),
                ),
                SizedBox(
                  height: 20 * scaleFactor,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () {
                      userController.clear();
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> sendInvitation(String inviteEmail, User? user) async {
    // Obtener una referencia a la colección de invitaciones para el destinatario
    CollectionReference invitationsCollection =
        FirebaseFirestore.instance.collection('invitations');

    // Guardar la invitación en la subcolección "ReceivedInvitations" dentro del documento del destinatario
    DocumentReference recipientDocRef = invitationsCollection.doc(inviteEmail);
    CollectionReference receivedInvitationsCollection =
        recipientDocRef.collection('receivedInvitations');

    await receivedInvitationsCollection.add({
      'sender': user?.email,
      'recipient': inviteEmail,
      'company': widget.companyData['companyId'],
      'category': widget.categoryName,
    });

    print('Invitacion enviada a $inviteEmail');
  }

  Future<void> handleInvitation(double scaleFactor) async {
    // Obtener el nombre de la categoría y el email del usuario a invitar
    String categoryName = widget.categoryName;
    String inviteEmail = userController.text;

    DocumentReference ownerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.companyData['ownerUid']);
    DocumentSnapshot ownerSnapshot = await ownerRef.get();
    Map<String, dynamic>? ownerData =
        ownerSnapshot.data() as Map<String, dynamic>?;

    String ownerEmail = ownerData?['email'] ?? 'No se encontro email';

    // Verificar que se haya ingresado un nombre de categoría válido y un email de invitación
    if (categoryName.isNotEmpty && inviteEmail.isNotEmpty) {
      // Obtener la referencia a la categoría personal dentro de la empresa
      DocumentReference categoryRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['companyId'])
          .collection('personalCategories')
          .doc(categoryName);

      User? user = FirebaseAuth.instance.currentUser;
      if (user?.email != inviteEmail) {
        // Obtener el documento de la categoría personal
        DocumentSnapshot categorySnapshot = await categoryRef.get();
        Map<String, dynamic>? categoryData =
            categorySnapshot.data() as Map<String, dynamic>?;

        List<dynamic> members = categoryData?['members'] ?? [];
        if (ownerEmail != inviteEmail) {
          //Verifico que sea diferente del owner
          if (!members.contains(inviteEmail)) {
            // Verificar si la categoría existe
            if (categorySnapshot.exists) {
              // Verificar que los datos no sean nulos y obtener la lista de invitaciones
              List<dynamic> invitations = categoryData?['invitations'] ?? [];

              // Verificar si el email de invitación ya está en la lista
              if (invitations.contains(inviteEmail)) {
                // Mostrar mensaje de error si el email ya fue invitado anteriormente
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
                        'El email ya fue invitado anteriormente.',
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
              } else {
                await sendInvitation(inviteEmail, user);

                invitations.add(inviteEmail);

                // Actualizar el documento de la categoría con la nueva lista de invitaciones
                await categoryRef.update({'invitations': invitations});

                userController.clear();

                // Mostrar mensaje de éxito al enviar la invitación
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        'Invitación Enviada',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 18 * scaleFactor,
                        ),
                      ),
                      content: Text(
                        'La invitación fue enviada exitosamente.',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 16 * scaleFactor,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
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
              }
            } else {
              // Mostrar mensaje de error si la categoría no existe
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
                      'La categoría no existe.',
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
          } else {
            // Mostrar mensaje de error si el usuario ya pertenece a la categoría
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
                    'El usuario al que está invitando ya pertenece a la categoría',
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
        } else {
          // Mostrar mensaje de error si el usuario intenta invitarse a sí mismo
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
                  'No puedes invitarte a ti mismo',
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
      } else {
        // Mostrar mensaje de error si el usuario intenta invitar al propietario de la empresa
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
                'No puedes invitar al owner de la compania',
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
    } else {
      // Mostrar mensaje de error si no se ingresó el nombre de la categoría o el email de invitación
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
              'Por favor, ingrese el nombre de la categoría y el email del usuario a invitar.',
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
  }
}
