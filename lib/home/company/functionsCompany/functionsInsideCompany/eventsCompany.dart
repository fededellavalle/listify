import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEvents/eventsLog.dart';
import 'package:app_listas/home/company/functionsCompany/functionsInsideCompany/functionsEvents/eventsTemplates/eventsTemplates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../styles/button.dart';
import 'package:unicons/unicons.dart';
import 'functionsEvents/step1AddEvent.dart';

class EventosPage extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const EventosPage({
    super.key,
    required this.companyData,
  });

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Eventos de ${widget.companyData['name']}',
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Botones de acciones dentro de la empresa
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  child: Column(
                    children: [
                      //Eventos Boton
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      Step1AddEvent(
                                companyData: widget.companyData,
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
                              transitionDuration: Duration(milliseconds: 500),
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
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Icon(
                                  CupertinoIcons.calendar_badge_plus,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15 * scaleFactor),
                            Text(
                              'Crear nuevo evento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            Spacer(),
                            Icon(
                              CupertinoIcons.add,
                              size: 20 * scaleFactor,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),

                      // Gestionar Personal
                      ElevatedButton(
                        onPressed: () {},
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Icon(
                                  Icons.event_repeat,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15 * scaleFactor),
                            Text(
                              'Gestionar Eventos creados',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
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

                      // Editar Personal
                      ElevatedButton(
                        onPressed: () {},
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Icon(
                                  UniconsSolid.user_arrows,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15 * scaleFactor),
                            Text(
                              'Editar Personal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
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

              SizedBox(height: 20 * scaleFactor),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * scaleFactor),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  child: Column(
                    children: [
                      // Historial de Eventos
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventsLogPage(
                                companyId:
                                    widget.companyData['companyUsername'],
                              ),
                            ),
                          );
                        },
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Icon(
                                  Icons.event_note,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15 * scaleFactor),
                            Text(
                              'Historial de Eventos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
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
                      // Plantillas de Eventos
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventTemplatesPage(
                                companyData: widget.companyData,
                              ),
                            ),
                          );
                        },
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Icon(
                                  UniconsSolid.user_arrows,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15 * scaleFactor),
                            Text(
                              'Plantillas de Eventos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontFamily: 'SFPro',
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
              SizedBox(height: 20 * scaleFactor),
            ],
          ),
        ),
      ),
    );
  }
}
