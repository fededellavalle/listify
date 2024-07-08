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

  Future<Map<String, dynamic>> calculateGeneratedMoney() async {
    double totalNormalTimeMoney = 0.0;
    double totalExtraTimeMoney = 0.0;
    Map<String, double> listMoneyMap = {};

    var eventListsSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('myEvents')
        .doc(eventId)
        .collection('eventLists')
        .get();

    for (var doc in eventListsSnapshot.docs) {
      var listData = doc.data();
      String listName = listData['listName'];

      double ticketPrice = listData['ticketPrice']?.toDouble() ?? 0.0;
      double ticketExtraPrice = listData['ticketExtraPrice']?.toDouble() ?? 0.0;

      Timestamp? listStartNormalTime = listData['listStartTime'];
      Timestamp? listEndNormalTime = listData['listEndTime'];
      Timestamp? listStartExtraTime = listData['listStartExtraTime'];
      Timestamp? listEndExtraTime = listData['listEndExtraTime'];

      double normalTimeMoney = 0.0;
      double extraTimeMoney = 0.0;

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

      double listTotalMoney = normalTimeMoney + extraTimeMoney;
      listMoneyMap[listName] = listTotalMoney;
      totalNormalTimeMoney += normalTimeMoney;
      totalExtraTimeMoney += extraTimeMoney;
    }

    return {
      'totalMoney': totalNormalTimeMoney + totalExtraTimeMoney,
      'listMoneyMap': listMoneyMap,
    };
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('myEvents')
            .doc(eventId)
            .snapshots(),
        builder: (context, eventSnapshot) {
          if (!eventSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var eventData = eventSnapshot.data!.data() as Map<String, dynamic>?;
          if (eventData == null) {
            return Center(
              child: Text(
                'No se encontraron datos del evento.',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 16 * scaleFactor,
                ),
              ),
            );
          }

          double ticketPrice = eventData['eventTicketValue']?.toDouble() ?? 0.0;
          int ticketsSold = eventData['ticketsSold']?.toInt() ?? 0;
          double moneyFromTickets = ticketPrice * ticketsSold;

          return StreamBuilder<QuerySnapshot>(
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
                print(listData);

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
                        totalRegistered += members.length;
                        for (var member in members) {
                          if (member['assisted'] == true) {
                            totalAssisted += 1;
                            assistedLogs.add({
                              'name': member['name'],
                              'assistedAt': member['assistedAt'],
                              'listName': listData['listName'],
                              'ticketAmount': (member['assistedAt']
                                          .toDate()
                                          .isAfter(
                                              listStartExtraTime!.toDate()) &&
                                      member['assistedAt']
                                          .toDate()
                                          .isBefore(listEndExtraTime!.toDate()))
                                  ? listData['ticketExtraPrice']
                                  : (member['assistedAt'].toDate().isAfter(
                                              listStartNormalTime!.toDate()) &&
                                          member['assistedAt']
                                              .toDate()
                                              .isBefore(
                                                  listEndNormalTime!.toDate()))
                                      ? listData['ticketPrice']
                                      : 0.0,
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
                              'listName': listData['listName'],
                              'ticketAmount': (member['assistedAt']
                                          .toDate()
                                          .isAfter(
                                              listStartExtraTime!.toDate()) &&
                                      member['assistedAt']
                                          .toDate()
                                          .isBefore(listEndExtraTime!.toDate()))
                                  ? listData['ticketExtraPrice']
                                  : (member['assistedAt'].toDate().isAfter(
                                              listStartNormalTime!.toDate()) &&
                                          member['assistedAt']
                                              .toDate()
                                              .isBefore(
                                                  listEndNormalTime!.toDate()))
                                      ? listData['ticketPrice']
                                      : 0.0,
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
                    Text(
                      'Entradas generales vendidas: $ticketsSold',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    FutureBuilder<Map<String, dynamic>>(
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
                          var data = moneySnapshot.data!;
                          double totalMoneyLists = data['totalMoney'] as double;
                          double totalMoney =
                              totalMoneyLists + moneyFromTickets;
                          Map<String, double> listMoneyMap =
                              data['listMoneyMap'] as Map<String, double>;

                          return ExpansionTile(
                            title: Text(
                              'Dinero generado: \$${totalMoney.toStringAsFixed(2)}',
                              style: TextStyle(
                                color:
                                    totalMoney >= 0 ? Colors.green : Colors.red,
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            ),
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalles adicionales:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SFPro',
                                      fontSize: 14 * scaleFactor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Entradas generales: \$${moneyFromTickets.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SFPro',
                                      fontSize: 14 * scaleFactor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  for (var entry in listMoneyMap.entries)
                                    Text(
                                      '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SFPro',
                                        fontSize: 14 * scaleFactor,
                                      ),
                                    ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    Text(
                      'Registro de Asistencias:',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: assistedLogs.length,
                        itemBuilder: (context, index) {
                          var log = assistedLogs[index];
                          var assistedAt = log['assistedAt'] as Timestamp;
                          var formattedDate = formatTimestamp(assistedAt);

                          return ListTile(
                            title: Text(
                              log['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 14 * scaleFactor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'SFPro',
                                    fontSize: 12 * scaleFactor,
                                  ),
                                ),
                                Text(
                                  log['listName'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'SFPro',
                                    fontSize: 12 * scaleFactor,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              log['ticketAmount'] != null
                                  ? '+\$${log['ticketAmount'].toStringAsFixed(2)}'
                                  : '',
                              style: TextStyle(
                                color: log['ticketAmount'] >= 0 ||
                                        log['ticketAmount'] != null
                                    ? Colors.green
                                    : Colors.red,
                                fontFamily: 'SFPro',
                                fontSize: 14 * scaleFactor,
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
          );
        },
      ),
    );
  }
}
