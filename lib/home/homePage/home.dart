import 'package:app_listas/home/events/functionEvents/insideEvent.dart';
import 'package:app_listas/home/profile/profile.dart';
import 'package:app_listas/styles/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final String? uid;

  HomePage({this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = '';
  int _liveEvents = 0;
  int _activeEvents = 0;
  int _desactiveEvents = 0;
  DateTime _selectedDate = DateTime.now();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getFirstName(widget.uid);
    _countEvents();
    _getProfileImageUrl();
  }

  Future<void> _getFirstName(String? uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        String firstname = userSnapshot.get('name');
        setState(() {
          _firstName = firstname;
        });
      }
    } catch (error) {
      print('Error obteniendo el nombre del usuario: $error');
    }
  }

  Future<void> _getProfileImageUrl() async {
    try {
      String? imageUrl = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get()
          .then((doc) => doc.data()?['imageUrl']);

      if (imageUrl != null) {
        setState(() {
          _profileImageUrl = imageUrl;
        });
      }
    } catch (error) {
      print('Error obteniendo la URL de la foto de perfil: $error');
    }
  }

  Future<void> _countEvents() async {
    try {
      QuerySnapshot liveEventsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('myEvents')
          .where('eventState', isEqualTo: 'Live')
          .get();
      QuerySnapshot activeEventsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('myEvents')
          .where('eventState', isEqualTo: 'Active')
          .get();
      QuerySnapshot desactiveEventsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('myEvents')
          .where('eventState', isEqualTo: 'Desactive')
          .get();

      setState(() {
        _liveEvents = liveEventsSnapshot.size;
        _activeEvents = activeEventsSnapshot.size;
        _desactiveEvents = desactiveEventsSnapshot.size;
      });
    } catch (error) {
      print('Error al contar los eventos: $error');
    }
  }

  Future<void> _handleRefresh() async {
    await _countEvents();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: skyBluePrimary,
        height: 50 * scaleFactor,
        backgroundColor: Colors.black,
        showChildOpacityTransition: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(scaleFactor),
              _buildCalendar(scaleFactor),
              _buildCategories(scaleFactor),
              _buildEventSummary(scaleFactor),
              _buildEventList(scaleFactor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _profileImageUrl != null
              ? GestureDetector(
                  onTap: () async {
                    final updatedProfileImageUrl = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: widget.uid),
                      ),
                    );

                    if (updatedProfileImageUrl != null) {
                      setState(() {
                        _profileImageUrl = updatedProfileImageUrl;
                      });
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_profileImageUrl!),
                    radius: 24 * scaleFactor,
                  ),
                )
              : CircleAvatar(
                  radius: 24 * scaleFactor,
                  child: IconButton(
                    icon: Icon(Icons.question_mark, color: Colors.white),
                    onPressed: () async {
                      final updatedProfileImageUrl = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: widget.uid),
                        ),
                      );

                      if (updatedProfileImageUrl != null) {
                        setState(() {
                          _profileImageUrl = updatedProfileImageUrl;
                        });
                      }
                    },
                  ),
                ),
          SizedBox(width: 16 * scaleFactor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $_firstName',
                style: TextStyle(
                  fontSize: 24.0 * scaleFactor,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFPro',
                ),
              ),
              Text(
                'Veamos qué está pasando hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 16 * scaleFactor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;
          return GestureDetector(
            onTap: () => _selectDate(date),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE').format(date),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
                SizedBox(height: 4 * scaleFactor),
                Container(
                  padding: EdgeInsets.all(8 * scaleFactor),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategories(double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryCard('Concierto', Icons.music_note, scaleFactor),
          _buildCategoryCard('Deportes', Icons.sports_soccer, scaleFactor),
          _buildCategoryCard('Educación', Icons.school, scaleFactor),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(16 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30 * scaleFactor),
          SizedBox(height: 8 * scaleFactor),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary(double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          _buildEventCard(
              'Eventos en Vivo', _liveEvents, Colors.redAccent, scaleFactor),
          SizedBox(height: 16 * scaleFactor),
          _buildEventCard('Eventos Activos', _activeEvents, Colors.greenAccent,
              scaleFactor),
          SizedBox(height: 16 * scaleFactor),
          _buildEventCard(
              'Eventos Desactivos', _desactiveEvents, Colors.grey, scaleFactor),
        ],
      ),
    );
  }

  Widget _buildEventCard(
      String title, int count, Color color, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(16 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.bold,
              fontFamily: 'SFPro',
            ),
          ),
          Container(
            padding: EdgeInsets.all(8 * scaleFactor),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12 * scaleFactor),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(double scaleFactor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos Populares',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.bold,
              fontFamily: 'SFPro',
            ),
          ),
          SizedBox(height: 16 * scaleFactor),
          FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error al cargar los eventos',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  'No hay eventos disponibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                );
              }

              return Column(
                children: snapshot.data!.map((doc) {
                  var event = doc.data() as Map<String, dynamic>;
                  var startTime = event['eventStartTime'] as Timestamp;
                  var formattedStartTime =
                      DateFormat('dd/MM/yyyy HH:mm').format(startTime.toDate());

                  return _buildEventItem(
                    event['eventName'],
                    event['eventImage'],
                    formattedStartTime,
                    scaleFactor,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchEvents() async {
    QuerySnapshot companySnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .where('subscription', isEqualTo: 'Premium')
        .get();

    if (companySnapshot.docs.isEmpty) {
      return [];
    }

    List<DocumentSnapshot> companyDocs = companySnapshot.docs;
    companyDocs.shuffle();

    List<DocumentSnapshot> selectedCompanyDocs = companyDocs.take(3).toList();

    List<DocumentSnapshot> eventDocs = [];

    for (DocumentSnapshot companyDoc in selectedCompanyDocs) {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyDoc.id)
          .collection('myEvents')
          .where('eventState', isEqualTo: 'Active')
          .limit(1)
          .get();

      if (eventSnapshot.docs.isNotEmpty) {
        eventDocs.add(eventSnapshot.docs.first);
      }
    }

    return eventDocs;
  }

  Widget _buildEventItem(
    String eventName,
    String eventImage,
    String formattedStartTime,
    double scaleFactor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16 * scaleFactor),
      padding: EdgeInsets.all(16 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
            child: Image.network(
              eventImage,
              width: 80 * scaleFactor,
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
                    color: Colors.white,
                    fontSize: 16 * scaleFactor,
                    fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ],
      ),
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
  });

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Stack(
      children: [
        InkWell(
          onTap: () async {
            bool hasPermission = await _checkPermission(companyId,
                companyRelationship, eventState ?? 'Active', isOwner);
            if (hasPermission) {
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
            } else {
              print('No tienes permiso para acceder a este evento.');
            }
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
                      Text(eventName,
                          style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'SFPro')),
                      SizedBox(height: 4 * scaleFactor),
                      Text('Inicio: $formattedStartTime',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          )),
                      SizedBox(height: 2 * scaleFactor),
                      Text('Fin: $formattedEndTime',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
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
      default:
        color = Colors.grey;
        text = 'Desactivo';
    }

    return Row(
      children: [
        _BlinkingCircle(color: color),
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

  Future<bool> _checkPermission(String companyId, String category,
      String eventState, bool isOwner) async {
    try {
      if (isOwner == true) {
        return true;
      } else {
        DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('personalCategories')
            .doc(category)
            .get();

        if (categorySnapshot.exists) {
          Map<String, dynamic> categoryData =
              categorySnapshot.data() as Map<String, dynamic>;

          if (categoryData['permissions'].contains('Escribir') &&
              eventState == 'Active') {
            print('Podes escribir');
            return true;
          } else if (categoryData['permissions'].contains('Leer') &&
              eventState == 'Live') {
            print('Podes Leer');
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    } catch (e) {
      print('Error al verificar permisos: $e');
      return false;
    }
  }
}

class _BlinkingCircle extends StatefulWidget {
  final Color color;

  _BlinkingCircle({required this.color});

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
        width: 12 * MediaQuery.of(context).size.width / 375.0,
        height: 12 * MediaQuery.of(context).size.width / 375.0,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
