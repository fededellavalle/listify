import 'dart:async';
import 'package:app_listas/styles/eventButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app_listas/styles/loading.dart';

class EventsLogPage extends StatefulWidget {
  final String companyId;

  EventsLogPage({required this.companyId});

  @override
  _EventsLogPageState createState() => _EventsLogPageState();
}

class _EventsLogPageState extends State<EventsLogPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          'Historial de Eventos',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 20 * scaleFactor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          _buildMainContent(context, scaleFactor),
          if (_isLoading)
            Center(
              child: LoadingScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double scaleFactor) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .orderBy('eventStartTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los eventos',
              style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                  color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;
        if (events.isEmpty) {
          return Center(
            child: Text(
              'No hay eventos disponibles',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 16 * scaleFactor,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            var event = events[index];
            var eventId = event.id;
            var startTime = event['eventStartTime'] as Timestamp;
            var endTime = event['eventEndTime'] as Timestamp;
            var formattedStartTime =
                DateFormat('dd/MM/yyyy HH:mm').format(startTime.toDate());
            var formattedEndTime =
                DateFormat('dd/MM/yyyy HH:mm').format(endTime.toDate());

            return EventButton(
              eventId: eventId,
              companyId: widget.companyId,
              eventName: event['eventName'],
              eventImage: event['eventImage'],
              formattedStartTime: formattedStartTime,
              formattedEndTime: formattedEndTime,
              companyRelationship: 'Owner',
              isOwner: true,
              eventState: event['eventState'],
              scaleFactor: scaleFactor,
            );
          },
        );
      },
    );
  }
}
