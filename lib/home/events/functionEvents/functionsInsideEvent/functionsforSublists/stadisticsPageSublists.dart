import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsPageSublists extends StatelessWidget {
  final String eventId;
  final String companyId;
  final Map<String, dynamic> list;

  StatisticsPageSublists({
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
        'normalTimeCount': 0,
        'normalTimeMoneyCount': 0.00,
        'extraTimeCount': 0,
        'extraTimeMoneyCount': 0.00,
      };
    }

    var eventListData = eventListSnapshot.data() as Map<String, dynamic>;
    if (!eventListData.containsKey('sublists')) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
        'normalTimeCount': 0,
        'normalTimeMoneyCount': 0.0,
        'extraTimeCount': 0,
        'extraTimeMoneyCount': 0.0,
      };
    }

    var sublists = eventListData['sublists'] as Map<String, dynamic>;

    num totalMembers = 0;
    num totalAssisted = 0;
    List<Timestamp> assistedTimes = [];
    int normalTimeCount = 0;
    int extraTimeCount = 0;
    double normalTimeMoneyCount = 0;
    double extraTimeMoneyCount = 0;

    Timestamp? listStartNormalTime = eventListData['listStartTime'];
    Timestamp? listEndNormalTime = eventListData['listEndTime'];
    Timestamp? listStartExtraTime = eventListData['listStartExtraTime'];
    Timestamp? listEndExtraTime = eventListData['listEndExtraTime'];

    double ticketPrice = eventListData['ticketPrice']?.toDouble() ?? 0.0;
    double ticketExtraPrice =
        eventListData['ticketExtraPrice']?.toDouble() ?? 0.0;

    // Recorremos cada sublista y sus miembros
    for (var sublist in sublists.values) {
      var members = List<Map<String, dynamic>>.from(sublist['members']);
      totalMembers += members.length;

      for (var member in members) {
        if (member['assisted'] == true) {
          totalAssisted++;
          Timestamp assistedAt = member['assistedAt'];
          assistedTimes.add(assistedAt);

          // Contamos las asistencias en tiempo normal y extra
          if (listStartExtraTime != null &&
              listEndExtraTime != null &&
              assistedAt.toDate().isAfter(listStartExtraTime.toDate()) &&
              assistedAt.toDate().isBefore(listEndExtraTime.toDate())) {
            extraTimeCount++;
            extraTimeMoneyCount += ticketExtraPrice;
          } else if (listStartNormalTime != null &&
              listEndNormalTime != null &&
              assistedAt.toDate().isAfter(listStartNormalTime.toDate()) &&
              assistedAt.toDate().isBefore(listEndNormalTime.toDate())) {
            normalTimeCount++;
            normalTimeMoneyCount += ticketPrice;
          }
        }
      }
    }

    return {
      'totalMembers': totalMembers,
      'totalAssisted': totalAssisted,
      'assistedTimes': assistedTimes,
      'normalTimeCount': normalTimeCount,
      'normalTimeMoneyCount': normalTimeMoneyCount,
      'extraTimeCount': extraTimeCount,
      'extraTimeMoneyCount': extraTimeMoneyCount,
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
          int normalTimeCount = snapshot.data!['normalTimeCount'] as int;
          int extraTimeCount = snapshot.data!['extraTimeCount'] as int;
          double normalTimeMoneyCount =
              snapshot.data!['normalTimeMoneyCount'] as double;
          double extraTimeMoneyCount =
              snapshot.data!['extraTimeMoneyCount'] as double;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (totalMembers == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Todavía no hay personas registradas en esta lista',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 16 * scaleFactor,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.person_crop_circle_fill_badge_xmark,
                        color: Colors.white,
                        size: 20 *
                            scaleFactor, // Tamaño del icono ajustable según scaleFactor
                      ),
                    ],
                  )
                else ...[
                  _buildStatisticTile(
                    'Total de personas registradas:',
                    '$totalMembers',
                    scaleFactor,
                    Colors.white,
                  ),
                  _buildStatisticTile(
                    'Total de personas asistidas:',
                    '$totalAssisted',
                    scaleFactor,
                    Colors.white,
                  ),
                  _buildStatisticTile(
                    'Asistencias en tiempo normal:',
                    '$normalTimeCount',
                    scaleFactor,
                    Colors.green,
                  ),
                  _buildStatisticTile(
                    'Dinero generado en tiempo normal:',
                    '\$${normalTimeMoneyCount.toStringAsFixed(2)}',
                    scaleFactor,
                    Colors.green,
                  ),
                  _buildStatisticTile(
                    'Asistencias en tiempo extra:',
                    '$extraTimeCount',
                    scaleFactor,
                    Colors.blue,
                  ),
                  _buildStatisticTile(
                    'Dinero generado en tiempo extra:',
                    '\$${extraTimeMoneyCount.toStringAsFixed(2)}',
                    scaleFactor,
                    Colors.blue,
                  ),
                  _buildStatisticTile(
                    frequentTime == 'No data'
                        ? 'No hay asistencias en este momento'
                        : 'Hora más frecuente de asistencia: ${frequentTime}h ($frequentTimeCount personas)',
                    '',
                    scaleFactor,
                    Colors.white,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  _buildPieChart(
                    totalMembers,
                    totalAssisted,
                    scaleFactor,
                    context,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticTile(
      String title, String value, double scaleFactor, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scaleFactor),
      child: Text(
        '$title $value',
        style: TextStyle(
          fontFamily: 'SFPro',
          color: textColor,
          fontSize: 14 * scaleFactor,
        ),
      ),
    );
  }

  Widget _buildPieChart(int totalMembers, int totalAssisted, double scaleFactor,
      BuildContext context) {
    Map<String, double> dataMap = {
      "Asistidos": totalAssisted.toDouble(),
      "No asistidos": (totalMembers - totalAssisted).toDouble(),
    };

    return PieChart(
      dataMap: dataMap,
      colorList: [
        Colors.green,
        Colors.red,
      ],
      chartRadius: MediaQuery.of(context).size.width / 2,
      chartLegendSpacing: 32,
      chartType: ChartType.ring,
      centerText: "Asistencia",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: 12 * scaleFactor,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValues: true,
        chartValueStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: 12 * scaleFactor,
        ),
      ),
    );
  }
}
