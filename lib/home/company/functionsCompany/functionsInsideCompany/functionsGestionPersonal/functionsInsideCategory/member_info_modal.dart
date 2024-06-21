import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberInfoModal extends StatelessWidget {
  final String userUid;
  final double scaleFactor;

  const MemberInfoModal({
    Key? key,
    required this.userUid,
    required this.scaleFactor,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchMemberInfo() async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchMemberInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar los datos del miembro'),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text('No se encontraron datos del miembro'),
          );
        }

        var memberData = snapshot.data!;
        String memberName = memberData['name'] ?? '';
        String memberApellido = memberData['lastname'] ?? '';
        String memberEmail = memberData['email'] ?? '';
        String memberInstagram = memberData['instagram'] ?? '';
        String memberPhone = memberData['phoneNumber'] ?? '';
        String memberNationality = memberData['nationality'] ?? '';
        String imageUrl = memberData['imageUrl'] ?? '';

        return AlertDialog(
          backgroundColor: Colors.black,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10 * scaleFactor),
                CircleAvatar(
                  radius: 50 * scaleFactor,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                SizedBox(height: 20 * scaleFactor),
                Text(
                  '$memberName $memberApellido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22 * scaleFactor,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                Text(
                  'Email: $memberEmail',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                Text(
                  'Instagram: $memberInstagram',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                Text(
                  'Telefono: $memberPhone',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                Text(
                  'Nacionalidad: $memberNationality',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16 * scaleFactor,
                  fontFamily: 'SFPro',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
