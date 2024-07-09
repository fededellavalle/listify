import 'dart:async';
import 'package:app_listas/styles/eventButton.dart';
import 'package:app_listas/styles/eventButtonSkeleton.dart';
import 'package:app_listas/styles/loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
                .where('companyUsername', isEqualTo: companyUsername)
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
          return Center(child: EventButtonSkeleton(scaleFactor: scaleFactor));
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
                  return Center(
                      child: EventButtonSkeleton(scaleFactor: scaleFactor));
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
          return Center(child: EventButtonSkeleton(scaleFactor: scaleFactor));
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
                    .where('companyUsername', isEqualTo: companyUsername)
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
                    return Center(
                        child: EventButtonSkeleton(scaleFactor: scaleFactor));
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
                            return Center(
                                child: EventButtonSkeleton(
                                    scaleFactor: scaleFactor));
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
