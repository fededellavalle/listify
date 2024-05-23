import 'dart:async';
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
        Map<String, dynamic> membersList = data['membersList'];
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
          title: Text('Confirmar'),
          content: Text('¿Estás seguro de que quieres quitar la asistencia?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista ${widget.list['listName']}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.person_search_rounded, color: Colors.white),
                hintText: 'Buscar Persona',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              style: TextStyle(color: Colors.white),
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
                      style: TextStyle(color: Colors.white),
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
                        child: Text('No hay miembros en esta lista.',
                            style: TextStyle(color: Colors.white)),
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
                          style: TextStyle(color: Colors.white),
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
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!eventListData.containsKey('membersList')) {
                      return Center(
                        child: Text('No hay miembros en esta lista.',
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    var membersList =
                        eventListData['membersList'] as Map<String, dynamic>;
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
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Switch(
                            activeColor: Colors.green.shade600,
                            value: member['assisted'] ?? false,
                            onChanged: (bool newValue) {
                              _toggleAttendance(
                                  member['name'], member['assisted'] ?? false);
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
