import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEvents/list_item.dart';
import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEvents/step3AddEvent.dart';
import 'package:app_listas/styles/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Step2AddEventTemplate extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final Map<String, dynamic> companyData;
  final Map<String, dynamic>? template;

  Step2AddEventTemplate({
    Key? key,
    required this.name,
    required this.ticketValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.companyData,
    this.template,
  }) : super(key: key);

  @override
  _Step2AddEventTemplateState createState() => _Step2AddEventTemplateState();
}

class _Step2AddEventTemplateState extends State<Step2AddEventTemplate> {
  List<ListItem> _lists = [];

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _lists = (widget.template!['lists'] as List<dynamic>).map((list) {
        return ListItem(
          name: list['listName'],
          type: list['listType'],
          addExtraTime: list['addExtraTime'] ?? false,
          selectedStartDate: list['listStartTime']?.toDate(),
          selectedEndDate: list['listEndTime']?.toDate(),
          ticketPrice: list['ticketPrice'],
          selectedStartExtraDate: list['startExtraTime']?.toDate(),
          selectedEndExtraDate: list['endExtraTime']?.toDate(),
          ticketExtraPrice: list['ticketExtraPrice'],
          allowSublists: list['allowSublists'] ?? false,
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Paso 2: Listas del Evento',
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _lists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _lists[index].name,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Tipo: ${_lists[index].type}',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Step3AddEvent(
                      name: widget.name,
                      image: null,
                      ticketValue: widget.ticketValue,
                      startDateTime: widget.startDateTime,
                      endDateTime: widget.endDateTime,
                      lists: _lists,
                      companyData: widget.companyData,
                    ),
                  ),
                );
              },
              style: buttonPrimary,
              child: Text(
                'Siguiente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
