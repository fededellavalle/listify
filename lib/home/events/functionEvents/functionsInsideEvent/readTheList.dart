import 'dart:async';
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

                    if ((listStartExtraTime == null &&
                            listStartTime.toDate().isAfter(DateTime.now())) ||
                        (listStartExtraTime != null &&
                            listStartExtraTime
                                .toDate()
                                .isAfter(DateTime.now()) &&
                            listStartTime.toDate().isAfter(DateTime.now()))) {
                      return Center(
                        child: Text(
                          'La lista no está abierta aún.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    var membersList = eventListData['membersList'];
                    if (membersList is List) {
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

                    if (membersList is Map<String, dynamic>) {
                      List<Map<String, dynamic>> members = [];
                      membersList.forEach((userId, userData) {
                        if (userData['members'] != null) {
                          members.addAll(List<Map<String, dynamic>>.from(
                              userData['members']));
                        }
                      });

                      var filteredMembers = members.where((member) {
                        return member['name']
                            .toString()
                            .toLowerCase()
                            .contains(_searchTerm);
                      }).toList();

                      filteredMembers.sort((a, b) => a['name']
                          .toString()
                          .toLowerCase()
                          .compareTo(b['name'].toString().toLowerCase()));

                      return ListView.builder(
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          var member = filteredMembers[index];
                          return ListTile(
                            title: Text(
                              member['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            ),
                            trailing: Switch(
                              activeColor: isWithinExtraTime(
                                      member['assitedAt'],
                                      listEndTime,
                                      listEndExtraTime)
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                              value: member['assisted'] ?? false,
                              onChanged: (bool newValue) {
                                _toggleAttendance(member['name'],
                                    member['assisted'] ?? false);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Formato de miembros no reconocido.',
                          style: TextStyle(
                            color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  bool isWithinExtraTime(Timestamp assistedAt, Timestamp listEndTime,
      Timestamp? listEndExtraTime) {
    DateTime assistedAtDate = assistedAt.toDate();
    DateTime listEndTimeDate = listEndTime.toDate();
    if (listEndExtraTime != null) {
      DateTime listEndExtraTimeDate = listEndExtraTime.toDate();
      return assistedAtDate.isAfter(listEndTimeDate) &&
          assistedAtDate.isBefore(listEndExtraTimeDate);
    }
    return false;
  }
}
