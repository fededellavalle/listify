import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../styles/loading.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  late User? currentUser; // Usuario actual
  bool _isLoadingAccept = false;
  bool _isLoadingReject = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> acceptInvitation(String companyUser, String category) async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoadingAccept = true;
    });

    try {
      // Agregar la relación de compañía al usuario actual
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid) // UID del usuario
          .update({
        'companyRelationship': FieldValue.arrayUnion([
          {'companyUsername': companyUser, 'category': category}
        ])
      });

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyUser)
          .collection('personalCategories')
          .doc(category)
          .update({
        'invitations': FieldValue.arrayRemove([currentUser!.email]),
        'members': FieldValue.arrayUnion([
          {
            'userUid': currentUser!.uid,
          }
        ])
      });

      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(currentUser!.email)
          .collection('receivedInvitations')
          .where('company', isEqualTo: companyUser)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Notificar al usuario que la invitación ha sido aceptada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitación aceptada'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error al aceptar la invitación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aceptar la invitación'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingAccept = false;
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> cancelInvitation(String companyId, String category) async {
    setState(() {
      _isLoadingReject = true;
    });
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(currentUser!.email)
          .collection('receivedInvitations')
          .where('company', isEqualTo: companyId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('personalCategories')
          .doc(category)
          .update({
        'invitations': FieldValue.arrayRemove([
          currentUser!.email
        ]), // Remove directly the email without wrapping it in an array
      });

      // Notify the user that the invitation has been canceled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitación rechazada'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error al rechazar la invitación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al rechazar la invitación'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingReject = false;
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Mis Invitaciones",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 20 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: StreamBuilder(
                stream: currentUser != null
                    ? FirebaseFirestore.instance
                        .collection('invitations')
                        .doc(currentUser!.email)
                        .collection('receivedInvitations')
                        .snapshots()
                    : null,
                builder: (context, AsyncSnapshot<QuerySnapshot>? snapshot) {
                  if (snapshot == null) {
                    return Text(
                      'Usuario no autenticado',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar las invitaciones',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No tienes invitaciones',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    );
                  }

                  // Si hay invitaciones, construye la lista de invitaciones
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      // Obtener los datos de la invitación como un Map<String, dynamic>
                      var invitation = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      String sender = invitation['sender'] ??
                          'Sin remitente'; // Email del remitente de la invitación
                      String category = invitation['category'] ??
                          'Sin mensaje'; // Categoría de la invitación
                      String companyId =
                          invitation['company']; // UID de la compañía

                      // Obtener el nombre del remitente a partir del email
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: sender)
                            .get(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> userSnapshot) {
                          if (userSnapshot.hasError) {
                            return Text(
                              'Error al obtener el nombre del remitente',
                              style: TextStyle(
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            );
                          }

                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingScreen();
                          }

                          if (userSnapshot.data!.docs.isEmpty) {
                            return Text(
                              'Remitente no encontrado',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            );
                          }

                          var userData = userSnapshot.data!.docs.first.data()
                              as Map<String, dynamic>;
                          String senderName = userData['name'] ??
                              'Nombre no encontrado'; // Nombre del remitente
                          String senderImage = userData['imageUrl'] ??
                              'Imagen no encontrada'; // Imagen del remitente

                          // Construir el widget de la invitación con el nombre del remitente
                          return FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('companies')
                                .doc(companyId)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot>
                                    companySnapshot) {
                              if (companySnapshot.hasError) {
                                return Text(
                                  'Error al obtener el nombre de la compañía',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 16 * scaleFactor,
                                  ),
                                );
                              }

                              if (companySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return LoadingScreen();
                              }

                              var companyData = companySnapshot.data!.data()
                                  as Map<String, dynamic>;
                              String companyName = companyData['name'] ??
                                  'Nombre de compañía no encontrado';
                              String companyImageUrl =
                                  companyData['imageUrl'] ??
                                      ''; // URL de la imagen de la empresa

                              // Construir el ListTile para mostrar la invitación
                              return ListTile(
                                leading: Stack(
                                  children: [
                                    ClipOval(
                                      child: companyImageUrl.isNotEmpty
                                          ? Image.network(
                                              companyImageUrl,
                                              width: 52 * scaleFactor,
                                              height: 52 * scaleFactor,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.business,
                                              size: 26 * scaleFactor,
                                            ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: ClipOval(
                                        child: senderImage.isNotEmpty
                                            ? Image.network(
                                                senderImage,
                                                width: 26 * scaleFactor,
                                                height: 26 * scaleFactor,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 52 * scaleFactor,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  '$senderName te invita a unirte a $companyName como $category',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SFPro',
                                    fontSize: 16 * scaleFactor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 8, 16, 8),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 4 * scaleFactor),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () async {
                                                  await acceptInvitation(
                                                      companyId, category);
                                                },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(10 * scaleFactor),
                                            ),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.black),
                                            backgroundColor: MaterialStateProperty
                                                .all<Color>(Color.fromARGB(
                                                    255,
                                                    242,
                                                    187,
                                                    29)), // Cambia el color de fondo del botón
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0 * scaleFactor),
                                              ),
                                            ),
                                          ),
                                          child: _isLoadingAccept
                                              ? CupertinoActivityIndicator(
                                                  color: Colors.black,
                                                )
                                              : Text(
                                                  'Aceptar',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'SFPro',
                                                    fontSize: 14 * scaleFactor,
                                                  ),
                                                ),
                                        ),
                                        SizedBox(
                                          width: 13 * scaleFactor,
                                        ),
                                        ElevatedButton(
                                          onPressed: _isLoadingReject
                                              ? null
                                              : () async {
                                                  await cancelInvitation(
                                                      companyId, category);
                                                },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(10 *
                                                  scaleFactor), // Ajusta el padding del botón según sea necesario
                                            ),
                                            overlayColor: MaterialStateProperty
                                                .all<Color>(Colors.red
                                                    .shade300), // Color del overlay (sombra) al presionar el botón
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Colors.black.withOpacity(
                                                        0.0)), // Color de fondo del botón con opacidad
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0 * scaleFactor),
                                                side: BorderSide(
                                                    color: Colors
                                                        .red), // Borde blanco
                                              ),
                                            ),
                                          ),
                                          child: _isLoadingReject
                                              ? CupertinoActivityIndicator(
                                                  color: Colors.red,
                                                )
                                              : Text(
                                                  'Rechazar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily: 'SFPro',
                                                    fontSize: 14 * scaleFactor,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
