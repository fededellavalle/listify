import 'package:app_listas/styles/color.dart';
import 'package:flutter/material.dart';

InputDecoration buildInputDecoration({
  required String labelText,
  required double labelFontSize,
  required IconData prefixIcon,
  required double prefixIconSize,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(
      color: white,
      fontSize: labelFontSize,
      fontFamily: 'SFPro',
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: Colors.grey,
      size: prefixIconSize,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: skyBluePrimary,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: skyBlueSecondary,
      ),
    ),
  );
}
