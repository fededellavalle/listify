import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsideEvent extends StatefulWidget {
  final String companyRelationship;
  final bool isOwner;
  final String eventId;
  final String companyId;

  const InsideEvent({
    Key? key,
    required this.companyRelationship,
    required this.isOwner,
    required this.eventId,
    required this.companyId,
  }) : super(key: key);

  @override
  State<InsideEvent> createState() => _InsideEventState();
}

class _InsideEventState extends State<InsideEvent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .doc(widget.eventId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error al cargar los datos del evento');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Text('No se encontraron datos para el evento');
        }

        // Accede a los datos del evento desde el DocumentSnapshot
        var eventData = snapshot.data!.data()! as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text('Detalles del Evento'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isOwner && widget.companyRelationship == 'Owner')
                  Column(
                    children: [
                      Text(
                        'Relación de la Compañía: ${widget.companyRelationship}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),

                // Luego puedes acceder a las propiedades del evento de esta manera
                Text(
                  'Nombre del Evento: ${eventData['eventName']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Descripción: ${eventData['eventDescription']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Fecha de Inicio: ${eventData['eventStartDate']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Hora de Inicio: ${eventData['eventStartTime']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Hora de Fin: ${eventData['eventEndTime']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Estado del evento: ${eventData['eventState']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
