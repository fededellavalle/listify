import 'dart:async';
import 'package:app_listas/home/events/functionEvents/insideEvent.dart';
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

class EventButton extends StatelessWidget {
  final String eventId;
  final String companyId;
  final String eventName;
  final String eventImage;
  final String formattedStartTime;
  final String formattedEndTime;
  final String companyRelationship;
  final bool isOwner;
  final String? eventState;
  final double scaleFactor;

  EventButton({
    required this.eventId,
    required this.companyId,
    required this.eventName,
    required this.eventImage,
    required this.formattedStartTime,
    required this.formattedEndTime,
    required this.companyRelationship,
    required this.isOwner,
    required this.eventState,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            ;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InsideEvent(
                  companyRelationship: companyRelationship,
                  isOwner: isOwner,
                  eventId: eventId,
                  companyId: companyId,
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16 * scaleFactor),
            margin: EdgeInsets.symmetric(
                vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12 * scaleFactor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4 * scaleFactor,
                  offset: Offset(0, 2 * scaleFactor),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                  child: Image.network(
                    eventImage,
                    width: 50 * scaleFactor,
                    height: 80 * scaleFactor,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16 * scaleFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      SizedBox(height: 4 * scaleFactor),
                      Text(
                        'Inicio: $formattedStartTime',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 2 * scaleFactor),
                      Text(
                        'Fin: $formattedEndTime',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Colors.white, size: 24 * scaleFactor),
              ],
            ),
          ),
        ),
        Positioned(
          top: 15 * scaleFactor,
          right: 25 * scaleFactor,
          child: _buildEventStateIndicator(eventState, scaleFactor),
        ),
      ],
    );
  }

  Widget _buildEventStateIndicator(String? eventState, double scaleFactor) {
    Color color;
    String text;

    switch (eventState) {
      case 'Active':
        color = Colors.green;
        text = 'Activo';
        break;
      case 'Live':
        color = Colors.red;
        text = 'En Vivo';
        break;
      case 'Finished':
        color = Colors.blue;
        text = 'Finalizado';
        break;
      default:
        color = Colors.grey;
        text = 'Desactivo';
    }

    return Row(
      children: [
        _BlinkingCircle(color: color, scaleFactor: scaleFactor),
        SizedBox(width: 4 * scaleFactor),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'SFPro',
            fontSize: 14 * scaleFactor,
          ),
        ),
      ],
    );
  }
}

class _BlinkingCircle extends StatefulWidget {
  final Color color;
  final double scaleFactor;

  _BlinkingCircle({required this.color, required this.scaleFactor});

  @override
  __BlinkingCircleState createState() => __BlinkingCircleState();
}

class __BlinkingCircleState extends State<_BlinkingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 12 * widget.scaleFactor,
        height: 12 * widget.scaleFactor,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
