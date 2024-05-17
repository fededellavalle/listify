import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'insideEvent.dart';

class EventsPage extends StatefulWidget {
  final String? uid;

  EventsPage({
    this.uid,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primer Stream:', style: TextStyle(fontSize: 18)),
          _buildFirstEventList(),
          SizedBox(height: 20),
          Text('Segundo Stream:', style: TextStyle(fontSize: 18)),
          _buildSecondEventList(),
        ],
      ),
    );
  }

  Widget _buildFirstEventList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .where('ownerUid',
              isEqualTo: widget.uid) // Filtra por el uid del propietario
          .snapshots(),
      builder: (context, companySnapshot) {
        if (companySnapshot.hasError) {
          return Text('Error al cargar los eventos');
        }

        if (companySnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (companySnapshot.data == null ||
            companySnapshot.data!.docs.isEmpty) {
          return Text('No hay companias');
        }

        List<String> companyIds =
            companySnapshot.data!.docs.map((doc) => doc.id).toList();

        return Column(
          children: companyIds.map((companyId) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('myEvents')
                  .where('eventState', whereIn: ['Active', 'Live']).snapshots(),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.hasError) {
                  return Text('Error al cargar los eventos');
                }

                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (eventSnapshot.data == null ||
                    eventSnapshot.data!.docs.isEmpty) {
                  return Text('No se encontraron eventos');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: eventSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var event = eventSnapshot.data!.docs[index];
                    /*Map<String, dynamic> eventData =
                        event.data() as Map<String, dynamic>;*/
                    var eventId = event.id;

                    var startTime = event['eventStartTime']
                        as Timestamp; // Suponiendo que 'eventStartTime' es un Timestamp
                    var endTime = event['eventEndTime']
                        as Timestamp; // Suponiendo que 'eventEndTime' es un Timestamp

                    // Formatea las fechas utilizando la clase DateFormat de intl
                    var formattedStartTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(startTime.toDate());
                    var formattedEndTime =
                        DateFormat('dd/MM/yyyy HH:mm').format(endTime.toDate());

                    // Construye el widget del evento
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideEvent(
                              companyRelationship: 'Owner',
                              isOwner: true,
                              eventId: eventId,
                              companyId: companyId,
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(20),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['eventName']),
                                SizedBox(height: 2),
                                Text(
                                    'Inicio: $formattedStartTime - Fin: $formattedEndTime'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSecondEventList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchUserEventsCompanyRelationships(widget.uid),
      builder: (context, relationshipSnapshot) {
        if (relationshipSnapshot.hasError) {
          return Text('Error al cargar las relaciones de compañía');
        } else if (relationshipSnapshot.connectionState ==
            ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (relationshipSnapshot.data == null ||
            relationshipSnapshot.data!.isEmpty) {
          return Text('No hay relaciones de compañía disponibles');
        } else {
          // Obtén la lista de companyRelationships
          List<Map<String, dynamic>> companyRelationships =
              relationshipSnapshot.data!;

          print(companyRelationships);

          return Expanded(
            child: ListView.builder(
              itemCount: companyRelationships.length,
              itemBuilder: (context, index) {
                var companyUsername =
                    companyRelationships[index]['companyUsername'];
                var companyCategory = companyRelationships[index]['category'];

                // Ahora puedes usar companyUsername para filtrar los eventos
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('companies')
                      .where('username', isEqualTo: companyUsername)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                          'Error al cargar los eventos de la compañía $companyUsername');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Text(
                          'No hay eventos disponibles para la compañía $companyUsername');
                    }

                    print(companyCategory);

                    List<String> companyIds =
                        snapshot.data!.docs.map((doc) => doc.id).toList();

                    print(companyIds);

                    return Column(
                      children: companyIds.map((companyId) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('companies')
                              .doc(companyId)
                              .collection('myEvents')
                              .where('eventState',
                                  whereIn: ['Active', 'Live']).snapshots(),
                          builder: (context, eventSnapshot) {
                            if (eventSnapshot.hasError) {
                              return Text('Error al cargar los eventos');
                            }

                            if (eventSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (eventSnapshot.data == null ||
                                eventSnapshot.data!.docs.isEmpty) {
                              return Text('No se encontraron eventos');
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: eventSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var event = eventSnapshot.data!.docs[index];
                                /*Map<String, dynamic> eventData =
                                    event.data() as Map<String, dynamic>;*/
                                var eventId = event.id;

                                var startTime = event['eventStartTime']
                                    as Timestamp; // Suponiendo que 'eventStartTime' es un Timestamp
                                var endTime = event['eventEndTime']
                                    as Timestamp; // Suponiendo que 'eventEndTime' es un Timestamp

                                // Formatea las fechas utilizando la clase DateFormat de intl
                                var formattedStartTime =
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(startTime.toDate());
                                var formattedEndTime =
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(endTime.toDate());

                                // Construye el widget del evento

                                return ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsideEvent(
                                          companyRelationship: companyCategory,
                                          isOwner: false,
                                          eventId: eventId,
                                          companyId: companyId,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.transparent,
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.all(20),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(event['eventName']),
                                            SizedBox(height: 2),
                                            Text(
                                                'Inicio: $formattedStartTime - Fin: $formattedEndTime'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _fetchUserEventsCompanyRelationships(
    String? uid,
  ) {
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          // Verifica si el documento existe antes de intentar acceder al campo
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          var companyRelationships =
              userData['companyRelationship'] as List<dynamic>? ?? [];
          print(companyRelationships);

          return companyRelationships.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      });
    } else {
      return Stream.empty();
    }
  }
}
