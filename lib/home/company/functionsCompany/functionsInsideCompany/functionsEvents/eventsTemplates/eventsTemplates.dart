import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEvents/step1AddEvent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventTemplatesPage extends StatelessWidget {
  final Map<String, dynamic> companyData;

  const EventTemplatesPage({
    Key? key,
    required this.companyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Plantillas de Eventos',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('companies')
            .doc(companyData['companyId'])
            .collection('eventTemplates')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar plantillas',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 16 * scaleFactor,
                ),
              ),
            );
          }

          final templates = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              if (index < templates.length) {
                final template =
                    templates[index].data() as Map<String, dynamic>;

                return ListTile(
                  title: Text(
                    template['eventName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor de la Entrada: \$${template['eventTicketValue'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      Text(
                        'Fecha de Inicio: ${template['eventStartTime'] != null ? DateFormat('dd/MM/yyyy HH:mm').format((template['eventStartTime'] as Timestamp).toDate()) : 'No especificada'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      Text(
                        'Fecha de Fin: ${template['eventEndTime'] != null ? DateFormat('dd/MM/yyyy HH:mm').format((template['eventEndTime'] as Timestamp).toDate()) : 'No especificada'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Step1AddEvent(
                          companyData: companyData,
                          template: template,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return ListTile(
                  title: Text(
                    'Slot vacío',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
