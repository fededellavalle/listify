import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
//import '../../styles/button.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  late User? currentUser; // Usuario actual

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> acceptInvitation(String companyUser, String category) async {
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

      // Obtener información adicional del usuario
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        String userName = userData['name'] ?? 'Nombre no encontrado';
        String lastName = userData['lastname'] ?? '';
        String completeName =
            lastName.isNotEmpty ? '$userName $lastName' : userName;
        String userInstagram = userData['instagram'] ?? '-';

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyUser)
            .collection('personalCategories')
            .doc(category)
            .update({
          'invitations': FieldValue.arrayRemove([currentUser!.email]),
          'members': FieldValue.arrayUnion([
            {
              'completeName': completeName,
              'email': currentUser!.email,
              'instagram': userInstagram
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
      } else {
        throw Exception('Error al obtener los datos del usuario');
      }
    } catch (e) {
      print('Error al aceptar la invitación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aceptar la invitación'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> cancelInvitation(String companyId, String category) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Mis Invitaciones",
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
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
                        .doc(currentUser!
                            .email) // Uso del email del usuario actual
                        .collection(
                            'receivedInvitations') // Subcolección de invitaciones recibidas
                        .snapshots()
                    : null, // No se muestra nada si el usuario no está autenticado
                builder: (context, AsyncSnapshot<QuerySnapshot>? snapshot) {
                  if (snapshot == null) {
                    return Text('Usuario no autenticado');
                  }

                  if (snapshot.hasError) {
                    return Text('Error al cargar las invitaciones');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No tienes invitaciones',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20, // Tamaño de fuente deseado
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
                                'Error al obtener el nombre del remitente');
                          }

                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (userSnapshot.data!.docs.isEmpty) {
                            return Text(
                              'Remitente no encontrado',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                              ),
                            );
                          }

                          var userData = userSnapshot.data!.docs.first.data()
                              as Map<String, dynamic>;
                          String senderName = userData['name'] ??
                              'Nombre no encontrado'; // Nombre del remitente
                          //String senderImage = userData['imageUrl'] ??
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
                                    'Error al obtener el nombre de la compañía');
                              }

                              if (companySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
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
                                leading: companyImageUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          companyImageUrl,
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipOval(
                                        child: Icon(
                                          Icons.business,
                                          size: 62,
                                        ),
                                      ),
                                title: Text(
                                  '$senderName te invita a unirte a $companyName como $category',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 8, 16, 8),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            acceptInvitation(
                                                companyId, category);
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(10),
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
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Aceptar',
                                            style: GoogleFonts.roboto(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 13,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            cancelInvitation(
                                                companyId, category);
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(
                                                  10), // Ajusta el padding del botón según sea necesario
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
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                    color: Colors
                                                        .red), // Borde blanco
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Rechazar',
                                            style: GoogleFonts.roboto(
                                              color: Colors.red,
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
