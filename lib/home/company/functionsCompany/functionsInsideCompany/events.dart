import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Eventos de ${widget.companyData['name']}',
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Botones de acciones dentro de la empresa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700
                        .withOpacity(0.4), // Color de fondo del Container
                    borderRadius: BorderRadius.circular(10), // Radio de borde
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
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Alineación al inicio
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .green, // Color de fondo del contenedor
                                borderRadius: BorderRadius.circular(
                                    8), // Opcional: radio de borde para el contenedor
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  UniconsLine.calendar_alt,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Crear nuevo evento',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.add,
                              size: 20, // Tamaño grande
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
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Alineación al inicio
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Color de fondo del contenedor
                                borderRadius: BorderRadius.circular(
                                    8), // Opcional: radio de borde para el contenedor
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.event_repeat,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Gestionar Eventos creados',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              UniconsLine.angle_right_b,
                              size: 20, // Tamaño grande
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),

                      //
                      ElevatedButton(
                        onPressed: () {},
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Alineación al inicio
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Color de fondo del contenedor
                                borderRadius: BorderRadius.circular(
                                    8), // Opcional: radio de borde para el contenedor
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  UniconsSolid.user_arrows,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Editar Personal',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              UniconsLine.angle_right_b,
                              size: 20, // Tamaño grande
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700
                        .withOpacity(0.4), // Color de fondo del Container
                    borderRadius: BorderRadius.circular(10), // Radio de borde
                  ),
                  child: Column(
                    children: [
                      //
                      ElevatedButton(
                        onPressed: () {},
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Alineación al inicio
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Color de fondo del contenedor
                                borderRadius: BorderRadius.circular(
                                    8), // Opcional: radio de borde para el contenedor
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.event_note,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Historial de Eventos',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              UniconsLine.angle_right_b,
                              size: 20, // Tamaño grande
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
