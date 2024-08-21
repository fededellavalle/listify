import 'package:flutter/material.dart';

class HelpDialog {
  static Future<void> showHelpDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ayuda',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El nombre de cada persona no puede exceder de 25 letras.',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                SizedBox(height: 8),
                Text(
                  'No puedes ingresar acentos. (El sistema te borrará el texto ingresado automáticamente)',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                SizedBox(height: 8),
                Text(
                  'Para ingresar varios nombres a la vez debes separarlos con comas (,). Por ejemplo:',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                SizedBox(height: 8),
                Text(
                  'Oscar Perez, Matias Cerbato, Elon Musk',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'El sistema verifica las otras listas creadas si ya se ha ingresado el nombre el cual quieres ingresar.',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'SFPro'),
              ),
            ),
          ],
        );
      },
    );
  }
}
