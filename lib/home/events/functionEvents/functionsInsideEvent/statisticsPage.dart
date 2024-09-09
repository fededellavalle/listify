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
        'normalTimeCount': 0,
        'normalTimeMoneyCount': 0,
        'extraTimeCount': 0,
        'extraTimeMoneyCount': 0,
      };
    }

    var eventListData = eventListSnapshot.data() as Map<String, dynamic>;
    if (!eventListData.containsKey('membersList')) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
        'normalTimeCount': 0,
        'normalTimeMoneyCount': 0,
        'extraTimeCount': 0,
      };
    }

    var membersList = eventListData['membersList'];
    if (membersList is List) {
      return {
        'totalMembers': 0,
        'totalAssisted': 0,
        'assistedTimes': [],
        'normalTimeCount': 0,
        'normalTimeMoneyCount': 0,
        'extraTimeCount': 0,
        'extraTimeMoneyCount': 0,
      };
    }

    // Ensure membersList is a Map
    membersList = membersList as Map<String, dynamic>;

    // Calculate statistics
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

    for (var memberGroup in membersList.values) {
      var members = memberGroup['members'];
      if (members != null && members is List) {
        totalMembers += members.length;
        for (var member in members) {
          if (member['assisted'] == true) {
            totalAssisted += 1;
            assistedTimes.add(member['assistedAt'] as Timestamp);

            DateTime assistedDateTime = member['assistedAt'].toDate();
            if (listStartExtraTime != null &&
                listEndExtraTime != null &&
                assistedDateTime.isAfter(listStartExtraTime.toDate()) &&
                assistedDateTime.isBefore(listEndExtraTime.toDate())) {
              extraTimeCount++;
              extraTimeMoneyCount = extraTimeMoneyCount + ticketExtraPrice;
            } else if (listStartNormalTime != null &&
                listEndNormalTime != null &&
                assistedDateTime.isAfter(listStartNormalTime.toDate()) &&
                assistedDateTime.isBefore(listEndNormalTime.toDate())) {
              normalTimeCount++;
              normalTimeMoneyCount = normalTimeMoneyCount + ticketPrice;
            }
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
      padding: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontFamily: 'SFPro',
                fontSize: 16 * scaleFactor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int totalMembers, int totalAssisted, double scaleFactor,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Distribución de Asistencias',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20 * scaleFactor),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(16 * scaleFactor),
          child: Center(
            child: PieChart(
              dataMap: {
                'Registradas': totalMembers.toDouble(),
                'Asistidas': totalAssisted.toDouble(),
              },
              chartType: ChartType.ring,
              ringStrokeWidth: 20 * scaleFactor,
              baseChartColor: Colors.grey[800]!,
              colorList: [Colors.purple, Colors.tealAccent],
              chartLegendSpacing: 32 * scaleFactor,
              chartRadius: MediaQuery.of(context).size.width / 2.5,
              legendOptions: LegendOptions(
                showLegends: true,
                legendPosition: LegendPosition.bottom,
                legendTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                legendShape: BoxShape.circle,
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValuesOutside: false,
                chartValueStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
                decimalPlaces: 1,
              ),
              animationDuration: Duration(milliseconds: 1200),
            ),
          ),
        ),
      ],
    );
  }
}
