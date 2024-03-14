import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String? userName; // Cambia a String? para hacerlo opcional

  HomePage({this.userName}); // Modifica el constructor para que userName sea opcional

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
              'Bienvenido, ${userName}', // Verifica si userName es nulo
              style: TextStyle(fontSize: 24.0),
            ),
    );
  }
}



