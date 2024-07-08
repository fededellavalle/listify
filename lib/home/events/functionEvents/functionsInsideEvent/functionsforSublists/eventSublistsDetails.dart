import 'package:app_listas/styles/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventSublistDetails extends StatefulWidget {
  final String eventId;
  final String companyId;
  final Map<String, dynamic> list;

  EventSublistDetails({
    required this.eventId,
    required this.companyId,
    required this.list,
  });

  @override
  State<EventSublistDetails> createState() => _EventSublistDetailsState();
}

class _EventSublistDetailsState extends State<EventSublistDetails> {
  Future<Map<String, String>> fetchUserNames(List<String> userIds) async {
    Map<String, String> userNames = {};

    for (String userId in userIds) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String fullName = userData['lastname'] != null
            ? '${userData['name']} ${userData['lastname']}'
            : '${userData['name']}';
        userNames[userId] = fullName;
      }
    }

    return userNames;
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
                      child: LoadingScreen(),
                    );
                  }

                  var eventListData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  if (eventListData == null ||
                      !eventListData.containsKey('sublists')) {
                    return Text(
                      'No hay sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    );
                  }

                  var sublists =
                      eventListData['sublists'] as Map<String, dynamic>;
                  var userIds = sublists.keys.toList();

                  return FutureBuilder<Map<String, String>>(
                    future: fetchUserNames(userIds),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: LoadingScreen(),
                        );
                      }

                      Map<String, String> userNames = snapshot.data!;

                      Timestamp? listStartNormalTime =
                          eventListData['listStartTime'];
                      Timestamp? listEndNormalTime =
                          eventListData['listEndTime'];
                      Timestamp? listStartExtraTime =
                          eventListData['listStartExtraTime'];
                      Timestamp? listEndExtraTime =
                          eventListData['listEndExtraTime'];

                      return ListView.builder(
                        itemCount: sublists.length,
                        itemBuilder: (context, index) {
                          String userId = sublists.keys.elementAt(index);
                          var userSublists =
                              sublists[userId] as Map<String, dynamic>;
                          String userName =
                              userNames[userId] ?? 'Usuario: $userId';

                          int totalRegistered = 0;
                          int totalAssisted = 0;

                          userSublists.forEach((sublistName, sublistData) {
                            var members = List<Map<String, dynamic>>.from(
                                sublistData['members']);
                            totalRegistered += members.length;
                            totalAssisted += members
                                .where((member) => member['assisted'] == true)
                                .length;
                          });

                          return ExpansionTile(
                            title: Text(
                              'Sublistas de $userName',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            ),
                            subtitle: Text(
                              'Registrados: $totalRegistered, Asistidos: $totalAssisted',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'SFPro',
                                fontSize: 14 * scaleFactor,
                              ),
                            ),
                            children:
                                userSublists.keys.map<Widget>((sublistName) {
                              var sublist = userSublists[sublistName]
                                  as Map<String, dynamic>;
                              var members = List<Map<String, dynamic>>.from(
                                  sublist['members']);
                              int registeredCount = members.length;
                              int assistedCount = members
                                  .where((member) => member['assisted'] == true)
                                  .length;

                              return ExpansionTile(
                                title: Text(
                                  'Sublista: $sublistName',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SFPro',
                                    fontSize: 14 * scaleFactor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Registrados: $registeredCount, Asistidos: $assistedCount',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'SFPro',
                                    fontSize: 12 * scaleFactor,
                                  ),
                                ),
                                children: members.map<Widget>((member) {
                                  return ListTile(
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
                                            member['assistedAt']
                                                .toDate()
                                                .isAfter(listStartExtraTime
                                                    .toDate()) &&
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
                                            member['assistedAt']
                                                .toDate()
                                                .isAfter(listStartNormalTime
                                                    .toDate()) &&
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
                                  );
                                }).toList(),
                              );
                            }).toList(),
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
