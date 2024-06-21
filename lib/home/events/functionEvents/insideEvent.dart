import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/functionsforSublists/addSublistToList.dart';
import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/functionsforSublists/eventSublistsDetails.dart';
import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/functionsforSublists/readTheSublists.dart';
import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/liveEventStatistics.dart';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../styles/button.dart';
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

  Future<void> _updateEventState(String newState) async {
    bool? confirmUpdate = await _showConfirmationDialog(context, newState);

    if (confirmUpdate == true) {
      try {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .update({'eventState': newState});
        print('Estado del evento actualizado a: $newState');
      } catch (e) {
        print('Error al actualizar el estado del evento: $e');
      }
    } else {
      print('Actualización de estado cancelada o sin confirmar.');
    }
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String newState) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        double scaleFactor = MediaQuery.of(context).size.width / 375.0;
        return AlertDialog(
          title: Text(
            'Confirmar Actualización',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 18 * scaleFactor),
          ),
          content: Text(
            '¿Estás seguro de que quieres actualizar el estado del evento a "$newState"?',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 16 * scaleFactor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style:
                    TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirmar',
                style:
                    TextStyle(fontFamily: 'SFPro', fontSize: 14 * scaleFactor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900, // Fondo gris
          title: Text(
            'Confirmar borrado',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SFPro',
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres borrar este evento?',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'SFPro',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Volver',
                style: TextStyle(
                  color: skyBluePrimary,
                  fontFamily: 'SFPro',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Borrar',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'SFPro',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento borrado exitosamente'),
          ),
        );

        Navigator.of(context).pop(); // Navega de vuelta a la página anterior
      } catch (e) {
        print('Error al borrar el evento: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al borrar el evento'),
          ),
        );
      }
    }
  }

  bool _canDeactivateEvent(DateTime eventStartTime) {
    final now = DateTime.now();
    final timeDifference = eventStartTime.difference(now);
    return timeDifference.inHours >= 6;
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
        DateTime eventStartTime =
            (eventData['eventStartTime'] as Timestamp).toDate();

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
                                      if (list['allowSublists'] == true) {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                AddSublistsToList(
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
                                                    curve:
                                                        Curves.linearToEaseOut,
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
                                      } else {
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
                                                    curve:
                                                        Curves.linearToEaseOut,
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
                                      }
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
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (!widget.isOwner &&
                          categoryData['permissions'].contains('Leer') &&
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
                                  if (list['listType'] == 'Lista de Asistencia')
                                    ElevatedButton(
                                      onPressed: () {
                                        if (list['allowSublists'] == true) {
                                          print('entro aca');
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  SublistsPage(
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
                                                      curve: Curves
                                                          .linearToEaseOut,
                                                      reverseCurve:
                                                          Curves.easeIn,
                                                    ),
                                                  ),
                                                  child: child,
                                                );
                                              },
                                              transitionDuration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          );
                                        } else {
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
                                                      curve: Curves
                                                          .linearToEaseOut,
                                                      reverseCurve:
                                                          Curves.easeIn,
                                                    ),
                                                  ),
                                                  child: child,
                                                );
                                              },
                                              transitionDuration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          );
                                        }
                                      },
                                      style: buttonCompany,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(
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
                  if (eventData['eventState'] == 'Desactive')
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: ElevatedButton(
                        onPressed: () {
                          _updateEventState('Active');
                        },
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Activar Evento',
                              style: TextStyle(
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (eventData['eventState'] == 'Live' ||
                      eventData['eventState'] == 'Active')
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                      child: Column(
                        children: [
                          if (_canDeactivateEvent(eventStartTime) ||
                              eventData['eventState'] == 'Active')
                            ElevatedButton(
                              onPressed: () {
                                _updateEventState('Desactive');
                              },
                              style: buttonCompany,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Desactivar Evento',
                                    style: TextStyle(
                                      fontSize: 18 * scaleFactor,
                                      fontFamily: 'SFPro',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Column(
                            children: [
                              if (!_canDeactivateEvent(eventStartTime)) ...[
                                Text(
                                  'No puedes desactivar el evento una vez activado y antes de que comience dentro de 6 horas',
                                  style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    fontFamily: 'SFPro',
                                    color: Colors.redAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height: 10 *
                                        scaleFactor), // Espacio entre el texto y el botón
                                ElevatedButton(
                                  onPressed: () {
                                    // Lógica para cancelar o borrar el evento
                                    _deleteEvent();
                                  },
                                  style: buttonCompany,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cancelar Evento',
                                        style: TextStyle(
                                          fontSize: 18 * scaleFactor,
                                          fontFamily: 'SFPro',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                              Container(
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
                                          if (list['allowSublists'] == true) {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    AddSublistsToList(
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
                                                        curve: Curves
                                                            .linearToEaseOut,
                                                        reverseCurve:
                                                            Curves.easeIn,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration:
                                                    Duration(milliseconds: 500),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
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
                                                        curve: Curves
                                                            .linearToEaseOut,
                                                        reverseCurve:
                                                            Curves.easeIn,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration:
                                                    Duration(milliseconds: 500),
                                              ),
                                            );
                                          }
                                        },
                                        style: buttonCompany,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(
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
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 5,
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
                              if (list['listType'] == 'Lista de Asistencia')
                                ElevatedButton(
                                  onPressed: () {
                                    if (list['allowSublists'] == true) {
                                      print('entro aca');
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              SublistsPage(
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
                                    } else {
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
                                    }
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
                  const SizedBox(
                    height: 5,
                  ),
                  if (eventData['eventState'] == 'Live' ||
                      eventData['eventState'] == 'Active')
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
                                  if (list['allowSublists'] == true) {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            EventSublistDetails(
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
                                  } else {
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
                                  }
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
                  const SizedBox(
                    height: 5,
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
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        LiveEventStatisticsPage(
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
                                      'Estadisticas en vivo sobre ${eventData['eventName']}',
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
