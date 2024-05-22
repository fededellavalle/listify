import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'functionEvents/insideEvent.dart';

class EventsPage extends StatefulWidget {
  final String? uid;

  EventsPage({
    this.uid,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool hasEventsInFirstStream = false;
  bool hasEventsInSecondStream = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFirstEventList(),
                _buildSecondEventList(),
              ],
            ),
          ),
          _buildNoEventsMessage(),
        ],
      ),
    );
  }

  Widget _buildFirstEventList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .where('ownerUid', isEqualTo: widget.uid)
          .snapshots(),
      builder: (context, companySnapshot) {
        if (companySnapshot.hasError) {
          return Text('Error al cargar los eventos');
        }

        if (companySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                  .where('eventState',
                      whereIn: ['Active', 'Live', 'Desactive']).snapshots(),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.hasError) {
                  return Text('Error al cargar los eventos');
                }

                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = eventSnapshot.data!.docs;
                final hasEvents = events.isNotEmpty;

                // Actualizar el estado después de que la construcción haya completado
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (hasEvents && !hasEventsInSecondStream) {
                    setState(() {
                      // Usar una variable local en lugar de una global
                      hasEventsInSecondStream = true;
                    });
                  }
                });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: eventSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var event = eventSnapshot.data!.docs[index];
                    var eventId = event.id;
                    var startTime = event['eventStartTime'] as Timestamp;
                    var endTime = event['eventEndTime'] as Timestamp;
                    var formattedStartTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(startTime.toDate());
                    var formattedEndTime =
                        DateFormat('dd/MM/yyyy HH:mm').format(endTime.toDate());

                    return EventButton(
                      eventId: eventId,
                      companyId: companyId,
                      eventName: event['eventName'],
                      eventImage: event['eventImage'],
                      formattedStartTime: formattedStartTime,
                      formattedEndTime: formattedEndTime,
                      companyRelationship: 'Owner',
                      isOwner: true,
                      eventState: event['eventState'],
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
          return Center(child: CircularProgressIndicator());
        } else {
          List<Map<String, dynamic>> companyRelationships =
              relationshipSnapshot.data!;

          return Column(
            children: companyRelationships.map((relationship) {
              var companyUsername = relationship['companyUsername'];
              var companyCategory = relationship['category'];

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
                    return Center(child: CircularProgressIndicator());
                  }

                  List<String> companyIds =
                      snapshot.data!.docs.map((doc) => doc.id).toList();

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
                            return Center(child: CircularProgressIndicator());
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (eventSnapshot.data != null &&
                                eventSnapshot.data!.docs.isNotEmpty) {
                              if (!hasEventsInSecondStream) {
                                setState(() {
                                  hasEventsInSecondStream = true;
                                });
                              }
                            }
                          });

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: eventSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var event = eventSnapshot.data!.docs[index];
                              var eventId = event.id;
                              var eventState = event['eventState'];
                              var startTime =
                                  event['eventStartTime'] as Timestamp;
                              var endTime = event['eventEndTime'] as Timestamp;
                              var formattedStartTime =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(startTime.toDate());
                              var formattedEndTime =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(endTime.toDate());

                              return EventButton(
                                eventId: eventId,
                                companyId: companyId,
                                eventName: event['eventName'],
                                eventImage: event['eventImage'],
                                formattedStartTime: formattedStartTime,
                                formattedEndTime: formattedEndTime,
                                companyRelationship: companyCategory,
                                isOwner: false,
                                eventState: eventState,
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _fetchUserEventsCompanyRelationships(
      String? uid) {
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          var companyRelationships =
              userData['companyRelationship'] as List<dynamic>? ?? [];
          return companyRelationships.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      });
    } else {
      return Stream.empty();
    }
  }

  Widget _buildNoEventsMessage() {
    return Visibility(
      visible: !hasEventsInFirstStream && !hasEventsInSecondStream,
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'No hay eventos activos en este momento',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class EventButton extends StatelessWidget {
  final String eventId;
  final String companyId;
  final String eventName;
  final String eventImage;
  final String formattedStartTime;
  final String formattedEndTime;
  final String companyRelationship;
  final bool isOwner;
  final String? eventState;

  EventButton({
    required this.eventId,
    required this.companyId,
    required this.eventName,
    required this.eventImage,
    required this.formattedStartTime,
    required this.formattedEndTime,
    required this.companyRelationship,
    required this.isOwner,
    required this.eventState,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            bool hasPermission = await _checkPermission(companyId,
                companyRelationship, eventState ?? 'Active', isOwner);
            if (hasPermission) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsideEvent(
                    companyRelationship: companyRelationship,
                    isOwner: isOwner,
                    eventId: eventId,
                    companyId: companyId,
                  ),
                ),
              );
            } else {
              // Manejar la falta de permisos
              print('No tienes permiso para acceder a este evento.');
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    eventImage,
                    width: 50,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Inicio: $formattedStartTime',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 2),
                      Text('Fin: $formattedEndTime',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
        Positioned(
          top: 15,
          right: 25,
          child: _buildEventStateIndicator(eventState),
        ),
      ],
    );
  }

  Widget _buildEventStateIndicator(String? eventState) {
    Color color;
    String text;

    switch (eventState) {
      case 'Active':
        color = Colors.green;
        text = 'Activo';
        break;
      case 'Live':
        color = Colors.red;
        text = 'En Vivo';
        break;
      default:
        color = Colors.grey;
        text = 'Desactivo';
    }

    return Row(
      children: [
        _BlinkingCircle(color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<bool> _checkPermission(String companyId, String category,
      String eventState, bool isOwner) async {
    try {
      if (isOwner == true) {
        return true;
      } else {
        DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('personalCategories')
            .doc(category)
            .get();

        if (categorySnapshot.exists) {
          Map<String, dynamic> categoryData =
              categorySnapshot.data() as Map<String, dynamic>;

          if (categoryData['permissions'].contains('Escribir') &&
              eventState == 'Active') {
            print('Podes escribir');
            return true;
          } else if (categoryData['permissions'].contains('Leer') &&
              eventState == 'Live') {
            print('Podes Leer');
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    } catch (e) {
      print('Error al verificar permisos: $e');
      return false;
    }
  }
}

class _BlinkingCircle extends StatefulWidget {
  final Color color;

  _BlinkingCircle({required this.color});

  @override
  __BlinkingCircleState createState() => __BlinkingCircleState();
}

class __BlinkingCircleState extends State<_BlinkingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
