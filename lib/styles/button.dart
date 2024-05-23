import 'package:flutter/material.dart';

final ButtonStyle buttonPrimary = ButtonStyle(
  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
    EdgeInsets.all(20), // Ajusta el padding del botón según sea necesario
  ),
  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
  backgroundColor: MaterialStateProperty.all<Color>(
      Color(0xFF74BEB8)), // Cambia el color de fondo del botón
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
);
//Color.fromARGB(195, 1, 244, 244) Color del logo
//Color(0xFF74BEB8),
//Color.fromARGB(255, 242, 187, 29) color amarillo

final ButtonStyle buttonSecondary = ButtonStyle(
  overlayColor: MaterialStateProperty.all<Color>(
      Colors.grey), // Color del overlay (sombra) al presionar el botón
  backgroundColor: MaterialStateProperty.all<Color>(
      Colors.black), // Color de fondo del botón con opacidad
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: Colors.white), // Borde blanco
    ),
  ),
  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
    EdgeInsets.all(20), // Ajusta el padding del botón según sea necesario
  ),
);

final ButtonStyle buttonCompany = ButtonStyle(
  overlayColor: MaterialStateProperty.all<Color>(Colors.grey),
  backgroundColor: MaterialStateProperty.all<Color>(
    Colors.black.withOpacity(0.0),
  ),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
    EdgeInsets.all(12),
  ),
);
