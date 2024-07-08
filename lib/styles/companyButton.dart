import 'package:app_listas/home/company/functionsCompany/insideCompany.dart';
import 'package:flutter/material.dart';

class CompanyButton extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final String? category;
  final double scaleFactor;
  final bool isOwner;

  CompanyButton({
    required this.companyData,
    this.category,
    required this.scaleFactor,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isOwner) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyWidget(
                companyData: companyData,
                isOwner: true,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyWidget(
                companyData: companyData,
                isOwner: false,
                companyCategory: category,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16 * scaleFactor),
        margin: EdgeInsets.symmetric(
            vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4 * scaleFactor,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                companyData['imageUrl'] ?? '',
                width: 70 * scaleFactor,
                height: 70 * scaleFactor,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyData['name'] ?? '',
                    style: TextStyle(
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SFPro',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * scaleFactor),
                  Text(
                    '@${companyData['companyUsername'] ?? ''}',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 2 * scaleFactor),
                  if (category != null)
                    Text(
                      'Eres parte de $category',
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white, size: 24 * scaleFactor),
          ],
        ),
      ),
    );
  }
}
