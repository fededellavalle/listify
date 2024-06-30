import 'dart:async';
import 'package:app_listas/styles/loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'functionEvents/insideEvent.dart';
import 'package:rxdart/rxdart.dart';

class EventsPage extends StatefulWidget {
  final String? uid;

  EventsPage({this.uid});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  bool hasEventsInFirstStream = false;
  bool hasEventsInSecondStream = false;
  bool _isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _checkFirstStreamEvents(),
      _checkSecondStreamEvents(),
    ]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _controller.forward();
    }
  }

  Future<void> _checkFirstStreamEvents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> companySnapshot =
          await FirebaseFirestore.instance
              .collection('companies')
              .where('ownerUid', isEqualTo: widget.uid)
              .get();

      List<String> companyIds =
          companySnapshot.docs.map((doc) => doc.id).toList();

      for (String companyId in companyIds) {
        QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('myEvents')
            .where('eventState', whereIn: ['Active', 'Live', 'Desactive'])
            .orderBy('eventStartTime')
            .get();

        if (eventSnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              hasEventsInFirstStream = true;
            });
          }
          break;
        }
      }
    } catch (error) {
      print('Error al comprobar eventos en el primer stream: $error');
    }
  }

  Future<void> _checkSecondStreamEvents() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          List<dynamic> companyRelationships =
              userData['companyRelationship'] ?? [];

          for (Map<String, dynamic> relationship in companyRelationships) {
            String companyUsername = relationship['companyUsername'];

            QuerySnapshot companySnapshot = await FirebaseFirestore.instance
                .collection('companies')
                .where('username', isEqualTo: companyUsername)
                .get();

            List<String> companyIds =
                companySnapshot.docs.map((doc) => doc.id).toList();

            for (String companyId in companyIds) {
              QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('myEvents')
                  .where('eventState', whereIn: ['Active', 'Live'])
                  .orderBy('eventStartTime')
                  .get();

              if (eventSnapshot.docs.isNotEmpty) {
                if (mounted) {
                  setState(() {
                    hasEventsInSecondStream = true;
                  });
                }
                break;
              }
            }
          }
        }
      }
    } catch (error) {
      print('Error al comprobar eventos en el segundo stream: $error');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMainContent(context, scaleFactor),
          if (_isLoading)
            Center(
              child: LoadingScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double scaleFactor) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mis Eventos',
                    style: TextStyle(
                      fontSize: 25 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'SFPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              _buildFirstEventList(scaleFactor),
              _buildSecondEventList(scaleFactor),
            ],
          ),
        ),
        _buildNoEventsMessage(scaleFactor),
      ],
    );
  }

  Widget _buildFirstEventList(double scaleFactor) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchUserCompanyData(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error al cargar los eventos',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<String> companyIds = snapshot.data!
            .map((e) => e['companyUsername'])
            .where((username) => username != null)
            .map((username) => username as String)
            .toList();

        return Column(
          children: companyIds.map((companyId) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('myEvents')
                  .where('eventState', whereIn: ['Active', 'Live', 'Desactive'])
                  .orderBy('eventStartTime')
                  .snapshots(),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.hasError) {
                  return Text(
                    'Error al cargar los eventos',
                    style: TextStyle(
                        fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
                  );
                }

                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = eventSnapshot.data!.docs;
                final hasEvents = events.isNotEmpty;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (hasEvents && !hasEventsInFirstStream && mounted) {
                    setState(() {
                      hasEventsInFirstStream = true;
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
                      scaleFactor: scaleFactor,
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

  Stream<List<Map<String, dynamic>>> _fetchUserCompanyData(String? uid) {
    if (uid != null) {
      var ownerStream = FirebaseFirestore.instance
          .collection('companies')
          .where('ownerUid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());

      var coOwnerStream = FirebaseFirestore.instance
          .collection('companies')
          .where('co-ownerUid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());

      return Rx.combineLatest2(ownerStream, coOwnerStream,
          (ownerCompanies, coOwnerCompanies) {
        ownerCompanies.addAll(coOwnerCompanies);
        return ownerCompanies;
      });
    } else {
      return Stream.empty();
    }
  }

  Widget _buildSecondEventList(double scaleFactor) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchUserEventsCompanyRelationships(widget.uid),
      builder: (context, relationshipSnapshot) {
        if (relationshipSnapshot.hasError) {
          return Text(
            'Error al cargar las relaciones de compañía',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
          );
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
                      'Error al cargar los eventos de la compañía $companyUsername',
                      style: TextStyle(
                          fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
                    );
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
                            .where('eventState', whereIn: ['Active', 'Live'])
                            .orderBy('eventStartTime')
                            .snapshots(),
                        builder: (context, eventSnapshot) {
                          if (eventSnapshot.hasError) {
                            return Text(
                              'Error al cargar los eventos',
                              style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontSize: 14 * scaleFactor),
                            );
                          }

                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (eventSnapshot.data != null &&
                                eventSnapshot.data!.docs.isNotEmpty &&
                                mounted) {
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
                                scaleFactor: scaleFactor,
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

  Widget _buildNoEventsMessage(double scaleFactor) {
    return Visibility(
      visible: !hasEventsInFirstStream && !hasEventsInSecondStream,
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'No hay eventos activos en este momento',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
            ),
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
  final double scaleFactor;

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
    required this.scaleFactor,
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
              _showNoPermissionDialog(context);
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
                  offset: Offset(0, 2 * scaleFactor),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                  child: Image.network(
                    eventImage,
                    width: 50 * scaleFactor,
                    height: 80 * scaleFactor,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16 * scaleFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      SizedBox(height: 4 * scaleFactor),
                      Text(
                        'Inicio: $formattedStartTime',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 2 * scaleFactor),
                      Text(
                        'Fin: $formattedEndTime',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
        Positioned(
          top: 15 * scaleFactor,
          right: 25 * scaleFactor,
          child: _buildEventStateIndicator(eventState, scaleFactor),
        ),
      ],
    );
  }

  void _showNoPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Permiso Denegado', style: TextStyle(fontFamily: 'SFPro')),
          content: Text('No tienes permiso para acceder a este evento.',
              style: TextStyle(fontFamily: 'SFPro')),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(fontFamily: 'SFPro')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventStateIndicator(String? eventState, double scaleFactor) {
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
        _BlinkingCircle(color: color, scaleFactor: scaleFactor),
        SizedBox(width: 4 * scaleFactor),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'SFPro',
            fontSize: 14 * scaleFactor,
          ),
        ),
      ],
    );
  }

  Future<bool> _checkPermission(String companyId, String category,
      String eventState, bool isOwner) async {
    try {
      if (isOwner) {
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
            return true;
          } else if (categoryData['permissions'].contains('Leer') &&
              eventState == 'Live') {
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
  final double scaleFactor;

  _BlinkingCircle({required this.color, required this.scaleFactor});

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
        width: 12 * widget.scaleFactor,
        height: 12 * widget.scaleFactor,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
