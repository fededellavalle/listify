import 'dart:async';
import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/sellTickets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadTheList extends StatefulWidget {
  final Map<String, dynamic> list;
  final String eventId;
  final String companyId;

  const ReadTheList({
    super.key,
    required this.companyId,
    required this.eventId,
    required this.list,
  });

  @override
  State<ReadTheList> createState() => _ReadTheListState();
}

class _ReadTheListState extends State<ReadTheList> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _toggleAttendance(String memberName, bool currentValue) async {
    if (currentValue) {
      bool confirm = await _showConfirmationDialog(context);
      if (!confirm) {
        return;
      }
    }

    QuerySnapshot eventListsSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('myEvents')
        .doc(widget.eventId)
        .collection('eventLists')
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    Timestamp now = Timestamp.now();

    for (QueryDocumentSnapshot doc in eventListsSnapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('membersList')) {
        var membersList = data['membersList'];
        if (membersList is Map<String, dynamic>) {
          membersList.forEach((userId, userData) {
            if (userData['members'] != null) {
              List<dynamic> members = userData['members'];
              for (int i = 0; i < members.length; i++) {
                if (members[i]['name'] == memberName) {
                  members[i]['assisted'] = !currentValue;
                  if (!currentValue) {
                    members[i]['assistedAt'] = now;
                  } else {
                    members[i].remove('assistedAt');
                  }
                }
              }
            }
          });

          batch.update(doc.reference, {'membersList': membersList});
        }
      }
    }

    try {
      await batch.commit();
      print('Attendance updated successfully');
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          content: Text(
            '¿Estás seguro de que quieres quitar la asistencia?',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'SFPro'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirmar',
                style: TextStyle(fontFamily: 'SFPro'),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista ${widget.list['listName']}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.confirmation_number, // Icono de tickets
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SellTickets(
                    eventId: widget.eventId,
                    companyId: widget.companyId,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.linearToEaseOut,
                          reverseCurve: Curves.easeIn,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0 * scaleFactor),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person_search_rounded,
                  color: Colors.white,
                  size: 20 * scaleFactor,
                ),
                hintText: 'Buscar Persona',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15 * scaleFactor),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(widget.companyId)
                  .collection('myEvents')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (context, eventSnapshot) {
                if (!eventSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var eventData =
                    eventSnapshot.data!.data() as Map<String, dynamic>?;
                if (eventData == null || eventData['eventState'] != 'Live') {
                  return Center(
                    child: Text(
                      'El evento ya ha finalizado.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                  );
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyId)
                      .collection('myEvents')
                      .doc(widget.eventId)
                      .collection('eventLists')
                      .doc(widget.list['listName'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var eventListData =
                        snapshot.data!.data() as Map<String, dynamic>?;

                    if (eventListData == null) {
                      return Center(
                        child: Text(
                          'No hay miembros en esta lista.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    Timestamp listEndTime = eventListData['listEndTime'];
                    Timestamp? listEndExtraTime =
                        eventListData['listEndExtraTime'];
                    Timestamp listStartTime = eventListData['listStartTime'];
                    Timestamp? listStartExtraTime =
                        eventListData['listStartExtraTime'];

                    if ((listStartExtraTime == null &&
                            listStartTime.toDate().isAfter(DateTime.now())) ||
                        (listStartExtraTime != null &&
                            listStartExtraTime
                                .toDate()
                                .isAfter(DateTime.now()) &&
                            listStartTime.toDate().isAfter(DateTime.now()))) {
                      return Center(
                        child: Text(
                          'La lista aún no está abierta.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    if ((listEndExtraTime == null &&
                            listEndTime.toDate().isBefore(DateTime.now())) ||
                        (listEndExtraTime != null &&
                            listEndExtraTime
                                .toDate()
                                .isBefore(DateTime.now()) &&
                            listEndTime.toDate().isBefore(DateTime.now()))) {
                      return Center(
                        child: Text(
                          'La lista se cerró.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    if (!eventListData.containsKey('membersList')) {
                      return Center(
                        child: Text(
                          'No hay miembros en esta lista.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    List<Map<String, dynamic>> membersList = [];

                    eventListData['membersList'].forEach((userId, userData) {
                      if (userData['members'] != null) {
                        for (var member in userData['members']) {
                          membersList.add(member);
                        }
                      }
                    });

                    membersList.sort((a, b) => a['name']
                        .toLowerCase()
                        .compareTo(b['name'].toLowerCase()));

                    List<Map<String, dynamic>> filteredMembersList =
                        _searchTerm.isEmpty
                            ? membersList
                            : membersList
                                .where((member) => member['name']
                                    .toLowerCase()
                                    .contains(_searchTerm))
                                .toList();

                    return ListView.builder(
                      itemCount: filteredMembersList.length,
                      itemBuilder: (context, index) {
                        var member = filteredMembersList[index];
                        bool isAssisted = member['assisted'] ?? false;

                        Timestamp? assistedAt = member['assistedAt'];
                        bool isWithinExtraTime = assistedAt != null &&
                            listStartExtraTime != null &&
                            listEndExtraTime != null &&
                            assistedAt
                                .toDate()
                                .isAfter(listStartExtraTime.toDate()) &&
                            assistedAt
                                .toDate()
                                .isBefore(listEndExtraTime.toDate());

                        return ListTile(
                          title: Text(
                            member['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SFPro',
                              fontSize: 14 * scaleFactor,
                            ),
                          ),
                          trailing: Switch(
                            value: isAssisted,
                            activeColor:
                                isWithinExtraTime ? Colors.blue : Colors.green,
                            onChanged: (value) {
                              _toggleAttendance(member['name'], isAssisted);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
