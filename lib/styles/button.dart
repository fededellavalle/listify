import 'package:flutter/material.dart';
import 'color.dart';

final ButtonStyle buttonPrimary = ElevatedButton.styleFrom(
  minimumSize: Size(327, 50),
  backgroundColor: white, // Usa orange como color de fondo
  elevation: 0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(50),
    ),
  ),
);
