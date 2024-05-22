import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventDetails extends StatefulWidget {
  final String eventId;
  final String companyId;
  final Map<String, dynamic> list;

  EventDetails({
    required this.eventId,
    required this.companyId,
    required this.list,
  });

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Future<Map<String, String>> fetchMemberNames(List<String> memberIds) async {
    Map<String, String> memberNames = {};

    for (String memberId in memberIds) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData['lastname'] != null) {
          String fullName = '${userData['name']} ${userData['lastname']}';
          memberNames[memberId] = fullName;
        } else {
          String fullName = '${userData['name']}';
          memberNames[memberId] = fullName;
        }
      }
    }

    return memberNames;
  }

  String formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    var formattedDate = DateFormat('dd-MM-yyyy hh:mm').format(date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.list['listName']}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  'Listas de ${widget.list['listName']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
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
                if (eventListData == null ||
                    !eventListData.containsKey('membersList')) {
                  return Text(
                    'No hay miembros en esta lista.',
                    style: TextStyle(color: Colors.white),
                  );
                }

                var membersList =
                    eventListData['membersList'] as Map<String, dynamic>;

                // Collect all member IDs to fetch their names
                List<String> memberIds = membersList.keys.toList();

                // Calculate statistics
                num localTotalMembers = 0;
                num localTotalAssisted = 0;

                for (var memberGroup in membersList.values) {
                  var members = memberGroup['members'];
                  localTotalMembers += members.length;
                  localTotalAssisted += members
                      .where((member) => member['assisted'] == true)
                      .length;
                }

                return FutureBuilder<Map<String, String>>(
                  future: fetchMemberNames(memberIds),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    Map<String, String> memberNames = snapshot.data!;

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: membersList.length,
                          itemBuilder: (context, index) {
                            String memberId = membersList.keys.elementAt(index);
                            var memberGroup = membersList[memberId];
                            var members = memberGroup['members'];

                            String memberName =
                                memberNames[memberId] ?? 'Usuario: $memberId';

                            return ExpansionTile(
                              title: Text(
                                'Lista de $memberName',
                                style: TextStyle(color: Colors.white),
                              ),
                              children: [
                                for (var member in members)
                                  ListTile(
                                    title: Text(
                                      '${member['name']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member['assisted']
                                              ? 'Asistió'
                                              : 'No asistió',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        if (member['assisted'])
                                          Text(
                                            'Hora de asistencia: ${formatTimestamp(member['assistedAt'])}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          members.remove(member);
                                          if (members.isEmpty) {
                                            membersList.remove(memberId);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Estadísticas:',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          'Total de personas registradas: $localTotalMembers',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          'Total de personas asistidas: $localTotalAssisted',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
