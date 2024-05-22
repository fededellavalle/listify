import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String? uid;

  HomePage({this.uid});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void initState() {
    super.initState();
    _getFirstName(widget.uid);
  }

  String _firstName = '';

  Future<void> _getFirstName(String? uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        String firstname = userSnapshot.get('name');
        setState(() {
          _firstName = firstname;
        });
      }
    } catch (error) {
      print('Error obteniendo el nombre del usuario: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Bienvenido, ${_firstName}', // Verifica si userName es nulo
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}
