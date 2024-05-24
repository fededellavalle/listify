import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../styles/button.dart';
import 'package:unicons/unicons.dart';
import 'functionsInsideEvent/addPeopleToList.dart';
import 'functionsInsideEvent/readTheList.dart';
import 'functionsInsideEvent/eventDetails.dart';

class InsideEvent extends StatefulWidget {
  final String companyRelationship;
  final bool isOwner;
  final String eventId;
  final String companyId;

  const InsideEvent({
    Key? key,
    required this.companyRelationship,
    required this.isOwner,
    required this.eventId,
    required this.companyId,
  }) : super(key: key);

  @override
  State<InsideEvent> createState() => _InsideEventState();
}

class _InsideEventState extends State<InsideEvent> {
  List<Map<String, dynamic>> eventListsData = [];

  @override
  void initState() {
    super.initState();
    fetchEventLists();
  }

  Future<void> fetchEventLists() async {
    try {
      CollectionReference<Map<String, dynamic>> eventListsCollection =
          FirebaseFirestore.instance
              .collection('companies')
              .doc(widget.companyId)
              .collection('myEvents')
              .doc(widget.eventId)
              .collection('eventLists');

      QuerySnapshot<Map<String, dynamic>> eventsnapshot =
          await eventListsCollection.get();

      List<Map<String, dynamic>> listsData = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in eventsnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        listsData.add(data); // Agregar datos a la lista
      }

      setState(() {
        eventListsData = listsData; // Actualizar la lista de datos
      });
    } catch (e) {
      print('Error al obtener las listas de eventos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .doc(widget.eventId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error al cargar los datos del evento',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Text(
            'No se encontraron datos para el evento',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
          );
        }

        // Accede a los datos del evento desde el DocumentSnapshot
        var eventData = snapshot.data!.data()! as Map<String, dynamic>;

        if (!widget.isOwner && widget.companyRelationship != 'Owner') {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('companies')
                .doc(widget.companyId)
                .collection('personalCategories')
                .doc(widget.companyRelationship)
                .snapshots(),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              // Accede a los datos de la categoría personal desde el DocumentSnapshot
              var categoryData =
                  categorySnapshot.data!.data()! as Map<String, dynamic>;

              return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: Text(
                    eventData['eventName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 18 * scaleFactor,
                    ),
                  ),
                  iconTheme: IconThemeData(
                    color: Colors.white, // Color blanco para los iconos
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
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!widget.isOwner &&
                          categoryData['permissions'].contains('Escribir') &&
                          eventData['eventState'] == 'Active')
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0 * scaleFactor),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700.withOpacity(0.4),
                              borderRadius:
                                  BorderRadius.circular(10 * scaleFactor),
                            ),
                            child: Column(
                              children: [
                                for (var list in eventListsData)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              AddPeopleToList(
                                            list: list,
                                            eventId: widget.eventId,
                                            companyId: widget.companyId,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.linearToEaseOut,
                                                  reverseCurve: Curves.easeIn,
                                                ),
                                              ),
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    style: buttonCompany,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                                8 * scaleFactor),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8.0 * scaleFactor),
                                            child: Icon(
                                              Icons.group_add_rounded,
                                              size: 20 * scaleFactor,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15 * scaleFactor),
                                        Flexible(
                                          child: Text(
                                            'Añadir gente a lista ${list['listName']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18 * scaleFactor,
                                              fontFamily: 'SFPro',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          UniconsLine.angle_right_b,
                                          size: 20 * scaleFactor,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (!widget.isOwner &&
                          categoryData['permissions'].contains('Escribir') &&
                          eventData['eventState'] == 'Live')
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0 * scaleFactor),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700.withOpacity(0.4),
                              borderRadius:
                                  BorderRadius.circular(10 * scaleFactor),
                            ),
                            child: Column(
                              children: [
                                for (var list in eventListsData)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              ReadTheList(
                                            list: list,
                                            eventId: widget.eventId,
                                            companyId: widget.companyId,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.linearToEaseOut,
                                                  reverseCurve: Curves.easeIn,
                                                ),
                                              ),
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    style: buttonCompany,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade300,
                                            borderRadius: BorderRadius.circular(
                                                8 * scaleFactor),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8.0 * scaleFactor),
                                            child: Icon(
                                              Icons.person_pin_rounded,
                                              size: 20 * scaleFactor,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15 * scaleFactor),
                                        Flexible(
                                          child: Text(
                                            'Dar asistencia en lista ${list['listName']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18 * scaleFactor,
                                              fontFamily: 'SFPro',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          UniconsLine.angle_right_b,
                                          size: 20 * scaleFactor,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text(
                eventData['eventName'],
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 18 * scaleFactor,
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white, // Color blanco para los iconos
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (eventData['eventState'] == 'Active')
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        child: Column(
                          children: [
                            for (var list in eventListsData)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          AddPeopleToList(
                                        list: list,
                                        eventId: widget.eventId,
                                        companyId: widget.companyId,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.linearToEaseOut,
                                              reverseCurve: Curves.easeIn,
                                            ),
                                          ),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                style: buttonCompany,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(
                                            8 * scaleFactor),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(8.0 * scaleFactor),
                                        child: Icon(
                                          Icons.group_add_rounded,
                                          size: 20 * scaleFactor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15 * scaleFactor),
                                    Flexible(
                                      child: Text(
                                        'Añadir gente a lista ${list['listName']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18 * scaleFactor,
                                          fontFamily: 'SFPro',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (eventData['eventState'] == 'Live')
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        child: Column(
                          children: [
                            for (var list in eventListsData)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          ReadTheList(
                                        list: list,
                                        eventId: widget.eventId,
                                        companyId: widget.companyId,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.linearToEaseOut,
                                              reverseCurve: Curves.easeIn,
                                            ),
                                          ),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                style: buttonCompany,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade300,
                                        borderRadius: BorderRadius.circular(
                                            8 * scaleFactor),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(8.0 * scaleFactor),
                                        child: Icon(
                                          Icons.person_pin_rounded,
                                          size: 20 * scaleFactor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15 * scaleFactor),
                                    Flexible(
                                      child: Text(
                                        'Dar asistencia en lista ${list['listName']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18 * scaleFactor,
                                          fontFamily: 'SFPro',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                      child: Column(
                        children: [
                          for (var list in eventListsData)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EventDetails(
                                      eventId: widget.eventId,
                                      companyId: widget.companyId,
                                      list: list,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.linearToEaseOut,
                                            reverseCurve: Curves.easeIn,
                                          ),
                                        ),
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(
                                          8 * scaleFactor),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0 * scaleFactor),
                                      child: Icon(
                                        Icons.library_books_outlined,
                                        size: 20 * scaleFactor,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15 * scaleFactor),
                                  Flexible(
                                    child: Text(
                                      'Resumen de ${list['listName']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18 * scaleFactor,
                                        fontFamily: 'SFPro',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
