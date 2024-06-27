import 'package:app_listas/styles/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InviteCoOwner extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const InviteCoOwner({
    super.key,
    required this.companyData,
  });

  @override
  State<InviteCoOwner> createState() => _InviteCoOwnerState();
}

class _InviteCoOwnerState extends State<InviteCoOwner> {
  TextEditingController userController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;
    return Scaffold(
      backgroundColor: Colors.black,
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
            Wrap(
              children: [
                Text(
                  'Invitemos a un amigo para que sea Co-Owner',
                  style: TextStyle(
                    fontSize: 25 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ingresa un email de alguna persona que quieras que se una a tu empresa para que te ayude a dirigirla.',
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
                counterText: '',
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
              maxLength: 60,
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
      'company': widget.companyData['companyUsername'],
      'position': 'Co-Owner',
    });

    print('Invitacion enviada a $inviteEmail');
  }

  Future<void> handleInvitation(double scaleFactor) async {
    String inviteEmail = userController.text.trim();

    DocumentReference ownerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.companyData['ownerUid']);
    DocumentSnapshot ownerSnapshot = await ownerRef.get();
    Map<String, dynamic>? ownerData =
        ownerSnapshot.data() as Map<String, dynamic>?;

    String ownerEmail = ownerData?['email'] ?? 'No se encontro email';

    if (inviteEmail.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user?.email != inviteEmail) {
        if (ownerEmail == inviteEmail) {
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
                  'No puedes invitarte a ti mismo.',
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

          userController.clear();

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
                'No puedes invitar al owner',
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
