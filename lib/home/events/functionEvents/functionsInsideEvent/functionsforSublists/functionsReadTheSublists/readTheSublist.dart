import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadTheSublist extends StatefulWidget {
  final Map<String, dynamic> list;
  final String sublistName;
  final String eventId;
  final String companyId;

  const ReadTheSublist({
    super.key,
    required this.companyId,
    required this.eventId,
    required this.list,
    required this.sublistName,
  });

  @override
  State<ReadTheSublist> createState() => _ReadTheSublistState();
}

class _ReadTheSublistState extends State<ReadTheSublist> {
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

    DocumentReference listDoc = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('myEvents')
        .doc(widget.eventId)
        .collection('eventLists')
        .doc(widget.list['listName']);

    try {
      var listSnapshot = await listDoc.get();
      var listData = listSnapshot.data() as Map<String, dynamic>?;

      if (listData != null && listData.containsKey('sublists')) {
        var sublists = listData['sublists'] as Map<String, dynamic>;
        for (var sublistKey in sublists.keys) {
          if (sublists[sublistKey].containsKey(widget.sublistName)) {
            var sublist = sublists[sublistKey][widget.sublistName]
                as Map<String, dynamic>;
            var members = List<Map<String, dynamic>>.from(sublist['members']);

            for (int i = 0; i < members.length; i++) {
              if (members[i]['name'] == memberName) {
                members[i]['assisted'] = !currentValue;
                if (!currentValue) {
                  members[i]['assistedAt'] = Timestamp.now();
                } else {
                  members[i].remove('assistedAt');
                }
              }
            }

            await listDoc.update({
              'sublists.$sublistKey.${widget.sublistName}.members': members,
            });
          }
        }
      }
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
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Sublista ${widget.sublistName}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
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
                  .collection('eventLists')
                  .doc(widget.list['listName'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var listData = snapshot.data!.data() as Map<String, dynamic>?;

                if (listData == null || !listData.containsKey('sublists')) {
                  return Center(
                    child: Text(
                      'No hay personas en esta sublista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  );
                }

                var allMembers = <Map<String, dynamic>>[];

                var sublists = listData['sublists'] as Map<String, dynamic>;
                sublists.forEach((userId, userSublists) {
                  if (userSublists.containsKey(widget.sublistName)) {
                    var sublist = userSublists[widget.sublistName]
                        as Map<String, dynamic>;
                    var members =
                        List<Map<String, dynamic>>.from(sublist['members']);
                    allMembers.addAll(members);
                  }
                });

                if (allMembers.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay personas en esta sublista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  );
                }

                var filteredMembers = allMembers.where((member) {
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
            ),
          ),
        ],
      ),
    );
  }
}
