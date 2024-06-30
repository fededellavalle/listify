import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LiveEventStatisticsPage extends StatelessWidget {
  final String eventId;
  final String companyId;

  LiveEventStatisticsPage({
    required this.eventId,
    required this.companyId,
  });

  String formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    var formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(date);
    return formattedDate;
  }

  Future<double> calculateGeneratedMoney() async {
    double normalTimeMoney = 0.0;
    double extraTimeMoney = 0.0;

    var eventListsSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('myEvents')
        .doc(eventId)
        .collection('eventLists')
        .get();

    for (var doc in eventListsSnapshot.docs) {
      var listData = doc.data();

      double ticketPrice = listData['ticketPrice']?.toDouble() ?? 0.0;
      double ticketExtraPrice = listData['ticketExtraPrice']?.toDouble() ?? 0.0;

      Timestamp? listStartNormalTime = listData['listStartTime'];
      Timestamp? listEndNormalTime = listData['listEndTime'];
      Timestamp? listStartExtraTime = listData['listStartExtraTime'];
      Timestamp? listEndExtraTime = listData['listEndExtraTime'];

      if (listData['allowSublists'] == true) {
        var sublists = listData['sublists'] as Map<String, dynamic>;
        sublists.forEach((userId, userSublists) {
          if (userSublists is Map<String, dynamic>) {
            userSublists.forEach((sublistName, sublistData) {
              var members = sublistData['members'] as List<dynamic>;
              for (var member in members) {
                if (member['assisted'] == true) {
                  var assistedAt = (member['assistedAt'] as Timestamp).toDate();

                  if (assistedAt.isAfter(listStartExtraTime!.toDate()) &&
                      assistedAt.isBefore(listEndExtraTime!.toDate())) {
                    extraTimeMoney += ticketExtraPrice;
                  } else if (assistedAt
                          .isAfter(listStartNormalTime!.toDate()) &&
                      assistedAt.isBefore(listEndNormalTime!.toDate())) {
                    normalTimeMoney += ticketPrice;
                  }
                }
              }
            });
          }
        });
      } else {
        var membersList = listData['membersList'] as Map<String, dynamic>;
        membersList.forEach((userId, userData) {
          if (userData['members'] != null) {
            var members = userData['members'] as List<dynamic>;
            for (var member in members) {
              if (member['assisted'] == true) {
                var assistedAt = (member['assistedAt'] as Timestamp).toDate();

                print('assistedAt: $assistedAt');
                print(
                    'listStartExtraTime!.toDate(): ${listStartExtraTime!.toDate()}');
                print(
                    'listEndExtraTime!.toDate(): ${listEndExtraTime!.toDate()}');

                if (assistedAt.isAfter(listStartExtraTime!.toDate()) &&
                    assistedAt.isBefore(listEndExtraTime!.toDate())) {
                  extraTimeMoney += ticketExtraPrice;
                } else if (assistedAt.isAfter(listStartNormalTime!.toDate()) &&
                    assistedAt.isBefore(listEndNormalTime!.toDate())) {
                  normalTimeMoney += ticketPrice;
                }
              }
            }
          }
        });
      }
    }

    return normalTimeMoney + extraTimeMoney;
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
          'Estadísticas en Vivo',
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
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('myEvents')
            .doc(eventId)
            .collection('eventLists')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          int totalRegistered = 0;
          int totalAssisted = 0;
          List<Map<String, dynamic>> assistedLogs = [];

          for (var doc in snapshot.data!.docs) {
            var listData = doc.data() as Map<String, dynamic>;

            if (listData['allowSublists'] == true) {
              var sublists = listData['sublists'] as Map<String, dynamic>;
              sublists.forEach((userId, userSublists) {
                if (userSublists is Map<String, dynamic>) {
                  userSublists.forEach((sublistName, sublistData) {
                    var members = sublistData['members'] as List<dynamic>;
                    totalRegistered += members.length;
                    for (var member in members) {
                      if (member['assisted'] == true) {
                        totalAssisted += 1;
                        assistedLogs.add({
                          'name': member['name'],
                          'assistedAt': member['assistedAt'],
                        });
                      }
                    }
                  });
                }
              });
            } else {
              var membersList = listData['membersList'];
              if (membersList is Map<String, dynamic>) {
                membersList.forEach((userId, userData) {
                  if (userData['members'] != null) {
                    var members = userData['members'] as List<dynamic>;
                    totalRegistered += members.length;
                    for (var member in members) {
                      if (member['assisted'] == true) {
                        totalAssisted += 1;
                        assistedLogs.add({
                          'name': member['name'],
                          'assistedAt': member['assistedAt'],
                        });
                      }
                    }
                  }
                });
              }
            }
          }

          assistedLogs
              .sort((a, b) => b['assistedAt'].compareTo(a['assistedAt']));

          return Padding(
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrados: $totalRegistered',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
                Text(
                  'Asistidos: $totalAssisted',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),
                FutureBuilder<double>(
                  future: calculateGeneratedMoney(),
                  builder: (context, moneySnapshot) {
                    if (moneySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (moneySnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al calcular el dinero generado',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      );
                    } else {
                      double totalMoney = moneySnapshot.data!;

                      return Text(
                        'Dinero generado: \$${totalMoney.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'SFPro',
                          fontSize: 16 * scaleFactor,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 16 * scaleFactor),
                Text(
                  'Registro de Asistencias',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
                SizedBox(height: 8 * scaleFactor),
                Expanded(
                  child: ListView.builder(
                    itemCount: assistedLogs.length,
                    itemBuilder: (context, index) {
                      var log = assistedLogs[index];
                      return ListTile(
                        title: Text(
                          '${log['name']} asistió',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                        ),
                        subtitle: Text(
                          formatTimestamp(log['assistedAt']),
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'SFPro',
                            fontSize: 12 * scaleFactor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
