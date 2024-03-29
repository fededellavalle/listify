import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/button.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  late String? currentUserEmail; // Email del usuario actual

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    currentUserEmail = user
        ?.email; // Reemplaza esto con la lógica para obtener el email del usuario actual
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
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
                stream: FirebaseFirestore.instance
                    .collection('invitations')
                    .where('recipient', isEqualTo: currentUserEmail)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error al cargar las invitaciones');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Text('No hay invitaciones para mostrar');
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
                          'Sin mensaje'; // Mensaje de la invitación
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

                          print('Sender: $sender');

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
                          String senderImage = userData['imageUrl'] ??
                              'Imagen no encontrada'; // Nombre del remitente

                          print('Name: $senderName');

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

                              print('Company Name: $companyName');

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
                                contentPadding: EdgeInsets.fromLTRB(16, 8, 16,
                                    8), // Ajuste del espacio interior
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Lógica para aceptar la invitación
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(
                                                  10), // Ajusta el padding del botón según sea necesario
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
                                            width:
                                                8), // Espacio entre los botones
                                        ElevatedButton(
                                          onPressed: () {
                                            // Lógica para cancelar la invitación
                                          },
                                          style: ButtonStyle(
                                            overlayColor: MaterialStateProperty
                                                .all<Color>(Colors
                                                    .grey), // Color del overlay (sombra) al presionar el botón
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
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              EdgeInsets.all(
                                                  10), // Ajusta el padding del botón según sea necesario
                                            ),
                                          ),
                                          child: Text(
                                            'Cancelar',
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
