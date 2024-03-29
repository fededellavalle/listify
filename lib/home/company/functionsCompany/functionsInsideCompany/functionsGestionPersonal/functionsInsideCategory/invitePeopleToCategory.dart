import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../styles/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:unicons/unicons.dart';
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

  Future<void> sendInvitation(String inviteEmail, User? user) async {
    // Save the invitation in the database
    await FirebaseFirestore.instance.collection('invitations').add({
      'sender': user?.email,
      'recipient': inviteEmail,
      'company': widget.companyData['companyId'],
      'category': widget.categoryName,
      'status': 'pending',
    });

    print('Invitacion enviada a $inviteEmail');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Crear Categoria de Personal",
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: userController,
              decoration: InputDecoration(
                hintText: 'Email del usuario al cual quieres invitar',
                hintStyle: TextStyle(
                    color: Colors
                        .grey), // Color del hint text (texto de sugerencia)
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors
                          .white), // Color del borde cuando está habilitado
                  borderRadius: BorderRadius.circular(10.0), // Radio del borde
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.white), // Color del borde cuando está enfocado
                  borderRadius: BorderRadius.circular(10.0), // Radio del borde
                ),
              ),
              style: TextStyle(
                  color:
                      Colors.white), // Color del texto ingresado por el usuario
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Obtener el nombre de la categoría y el email del usuario a invitar
                    String categoryName = widget.categoryName;
                    String inviteEmail =
                        userController.text; // Reemplaza con el email a invitar

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
                        if (!widget.emails.contains(inviteEmail)) {
                          // Obtener el documento de la categoría personal
                          DocumentSnapshot categorySnapshot =
                              await categoryRef.get();

                          // Verificar si la categoría existe
                          if (categorySnapshot.exists) {
                            // Obtener los datos del documento como un Map<String, dynamic>
                            Map<String, dynamic>? categoryData =
                                categorySnapshot.data()
                                    as Map<String, dynamic>?;

                            // Verificar que los datos no sean nulos y obtener la lista de invitaciones
                            List<dynamic> invitations =
                                categoryData?['invitations'] ?? [];

                            // Verificar si el email de invitación ya está en la lista
                            if (invitations.contains(inviteEmail)) {
                              // Mostrar mensaje de error si el email ya fue invitado anteriormente
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error'),
                                    content: Text(
                                        'El email ya fue invitado anteriormente.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Cerrar el AlertDialog
                                        },
                                        child: Text('Ok'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              await sendInvitation(inviteEmail, user);

                              invitations.add(inviteEmail);

                              // Actualizar el documento de la categoría con la nueva lista de invitaciones
                              await categoryRef
                                  .update({'invitations': invitations});

                              userController.clear();

                              // Mostrar mensaje de éxito al enviar la invitación
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Invitación Enviada'),
                                    content: Text(
                                        'La invitación fue enviada exitosamente.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Cerrar el AlertDialog
                                          Navigator.of(context)
                                              .pop(); // Volver a la pantalla anterior
                                          Navigator.of(context)
                                              .pop(); // Volver a la pantalla anterior
                                        },
                                        child: Text('OK'),
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
                                  title: Text('Error'),
                                  content: Text('La categoría no existe.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el AlertDialog
                                      },
                                      child: Text('Ok'),
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
                                title: Text('Error'),
                                content: Text(
                                    'El usuario al que esta invitando ya pertenece a la categoria'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Cerrar el AlertDialog
                                    },
                                    child: Text('Ok'),
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
                              title: Text('Error'),
                              content: Text(
                                'No puedes invitarte a ti mismo',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Cerrar el AlertDialog
                                  },
                                  child: Text('Ok'),
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
                            title: Text('Error'),
                            content: Text(
                              'Por favor, ingrese el nombre de la categoría y el email del usuario a invitar.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cerrar el AlertDialog
                                },
                                child: Text('Ok'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: buttonPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Invitar a unirse'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    userController.clear();

                    Navigator.pop(context);
                  },
                  style: buttonSecondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cancelar',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
