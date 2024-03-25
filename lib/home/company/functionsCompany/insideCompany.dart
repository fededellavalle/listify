import 'package:flutter/material.dart';

// Define la clase del widget de la empresa
class CompanyWidget extends StatelessWidget {
  final Map<String, dynamic> companyData;

  const CompanyWidget({
    Key? key,
    required this.companyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String companyName = companyData['name'] ?? '';
    String companyImageUrl = companyData['imageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(companyName),
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (companyImageUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(companyImageUrl),
                radius: 100, // Tamaño del avatar
              ),
            SizedBox(height: 20),
            Text(
              'Nombre de la empresa: $companyName',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'URL de la imagen: $companyImageUrl',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
