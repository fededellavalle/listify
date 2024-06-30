import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/statisticsPage.dart';
import 'package:flutter/cupertino.dart';
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
    var formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(date);
    return formattedDate;
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
          '${widget.list['listName']}',
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
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(
                    eventId: widget.eventId,
                    companyId: widget.companyId,
                    list: widget.list,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 20 * scaleFactor,
                ),
                SizedBox(width: 5 * scaleFactor),
                Text(
                  'Listas de ${widget.list['listName']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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

                  var eventListData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  if (eventListData == null ||
                      !eventListData.containsKey('membersList')) {
                    return Text(
                      'No hay miembros en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    );
                  }

                  var membersList = eventListData['membersList'];

                  if (membersList is List) {
                    return Text(
                      'No hay miembros en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    );
                  }

                  // Ensure membersList is a Map
                  membersList = membersList as Map<String, dynamic>;

                  // Collect all member IDs to fetch their names
                  List<String> memberIds = membersList.keys.toList();

                  return FutureBuilder<Map<String, String>>(
                    future: fetchMemberNames(memberIds),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      Map<String, String> memberNames = snapshot.data!;

                      Timestamp? listStartNormalTime =
                          eventListData['listStartTime'];
                      Timestamp? listEndNormalTime =
                          eventListData['listEndTime'];
                      Timestamp? listStartExtraTime =
                          eventListData['listStartExtraTime'];
                      Timestamp? listEndExtraTime =
                          eventListData['listEndExtraTime'];

                      return ListView.builder(
                        itemCount: membersList.length,
                        itemBuilder: (context, index) {
                          String memberId = membersList.keys.elementAt(index);
                          var memberGroup = membersList[memberId];
                          var members = memberGroup['members'];

                          String memberName =
                              memberNames[memberId] ?? 'Usuario: $memberId';

                          int registeredCount = members.length;
                          int assistedCount = members
                              .where((member) => member['assisted'] == true)
                              .length;

                          return ExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lista de $memberName',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SFPro',
                                    fontSize: 16 * scaleFactor,
                                  ),
                                ),
                                Text(
                                  'Registrados: $registeredCount, Asistidos: $assistedCount',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'SFPro',
                                    fontSize: 14 * scaleFactor,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              for (var member in members)
                                ListTile(
                                  title: Text(
                                    '${member['name']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SFPro',
                                      fontSize: 14 * scaleFactor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member['assisted']
                                            ? 'Asistió'
                                            : 'No asistió',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SFPro',
                                          fontSize: 12 * scaleFactor,
                                        ),
                                      ),
                                      if (member['assisted'])
                                        Text(
                                          'Hora de asistencia: ${formatTimestamp(member['assistedAt'])}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'SFPro',
                                            fontSize: 12 * scaleFactor,
                                          ),
                                        ),
                                      if (member['assisted'] &&
                                          listStartExtraTime != null &&
                                          listEndExtraTime != null &&
                                          member['assistedAt'].toDate().isAfter(
                                              listStartExtraTime.toDate()) &&
                                          member['assistedAt']
                                              .toDate()
                                              .isBefore(
                                                  listEndExtraTime.toDate()))
                                        Text(
                                          'Asistió en extra time',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontFamily: 'SFPro',
                                            fontSize: 12 * scaleFactor,
                                          ),
                                        )
                                      else if (member['assisted'] &&
                                          listStartNormalTime != null &&
                                          listEndNormalTime != null &&
                                          member['assistedAt'].toDate().isAfter(
                                              listStartNormalTime.toDate()) &&
                                          member['assistedAt']
                                              .toDate()
                                              .isBefore(
                                                  listEndNormalTime.toDate()))
                                        Text(
                                          'Asistió en tiempo normal',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontFamily: 'SFPro',
                                            fontSize: 12 * scaleFactor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.red,
                                      size: 20 * scaleFactor,
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
