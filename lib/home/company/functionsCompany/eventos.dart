import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../styles/button.dart';
import 'package:unicons/unicons.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

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
          'companyName',
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
              SizedBox(height: 20),
              SizedBox(height: 20),

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
                        onPressed: () {},
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
                                  UniconsSolid.calender,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Eventos de ',
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
                              'Gestionar Personal',
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
                                color:
                                    Colors.red, // Color de fondo del contenedor
                                borderRadius: BorderRadius.circular(
                                    8), // Opcional: radio de borde para el contenedor
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  UniconsLine.trash,
                                  size: 20, // Tamaño grande
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Eliminar Compañia',
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
