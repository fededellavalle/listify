import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsPage extends StatelessWidget {
  final String eventId;
  final String companyId;
  final Map<String, dynamic> list;

  StatisticsPage({
    required this.eventId,
    required this.companyId,
    required this.list,
  });

  Future<Map<String, dynamic>> fetchStatistics() async {
    DocumentSnapshot eventListSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('myEvents')
        .doc(eventId)
        .collection('eventLists')
        .doc(list['listName'])
        .get();

    if (!eventListSnapshot.exists) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
      };
    }

    var eventListData = eventListSnapshot.data() as Map<String, dynamic>;
    if (!eventListData.containsKey('membersList')) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
      };
    }

    var membersList = eventListData['membersList'];
    if (membersList is List) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
      };
    }

    // Ensure membersList is a Map
    membersList = membersList as Map<String, dynamic>;

    // Calculate statistics
    num totalMembers = 0;
    num totalAssisted = 0;
    List<Timestamp> assistedTimes = [];

    for (var memberGroup in membersList.values) {
      var members = memberGroup['members'];
      if (members != null && members is List) {
        totalMembers += members.length;
        for (var member in members) {
          if (member['assisted'] == true) {
            totalAssisted += 1;
            assistedTimes.add(member['assistedAt'] as Timestamp);
          }
        }
      }
    }

    return {
      'totalMembers': totalMembers,
      'totalAssisted': totalAssisted,
      'assistedTimes': assistedTimes,
    };
  }

  Map<String, dynamic> mostFrequentTime(List<Timestamp> timestamps) {
    if (timestamps.isEmpty) return {"hour": "No data", "count": 0};

    Map<String, int> timeFrequency = {};

    for (var timestamp in timestamps) {
      String hour = DateFormat('HH').format(timestamp.toDate());
      if (timeFrequency.containsKey(hour)) {
        timeFrequency[hour] = timeFrequency[hour]! + 1;
      } else {
        timeFrequency[hour] = 1;
      }
    }

    String mostFrequent = timeFrequency.keys.first;
    for (var time in timeFrequency.keys) {
      if (timeFrequency[time]! > timeFrequency[mostFrequent]!) {
        mostFrequent = time;
      }
    }

    return {"hour": mostFrequent, "count": timeFrequency[mostFrequent]};
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
          'Estadísticas',
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStatistics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          int totalMembers = snapshot.data!['totalMembers'] as int;
          int totalAssisted = snapshot.data!['totalAssisted'] as int;
          List<Timestamp> assistedTimes =
              (snapshot.data!['assistedTimes'] as List<dynamic>)
                  .cast<Timestamp>();

          Map<String, dynamic> frequentTimeData =
              mostFrequentTime(assistedTimes);
          String frequentTime = frequentTimeData["hour"];
          int frequentTimeCount = frequentTimeData["count"];

          return Padding(
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Column(
              children: [
                if (totalMembers == 0)
                  Text(
                    'No hay miembros en esta lista.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  )
                else ...[
                  Text(
                    'Total de personas registradas: $totalMembers',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'Total de personas asistidas: $totalAssisted',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'Hora más frecuente de asistencia: ${frequentTime}h ($frequentTimeCount personas)',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  Expanded(
                    child: Center(
                      child: PieChart(
                        dataMap: {
                          'Registradas': totalMembers.toDouble(),
                          'Asistidas': totalAssisted.toDouble(),
                        },
                        chartType: ChartType.ring,
                        colorList: [Colors.blue, Colors.red],
                        legendOptions: LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.right,
                          legendTextStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                          chartValueStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
