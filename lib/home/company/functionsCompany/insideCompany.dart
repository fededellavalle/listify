import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';
import '../../../styles/button.dart';
import 'functionsInsideCompany/gestionPersonal.dart';
import 'functionsInsideCompany/events.dart';

class CompanyWidget extends StatelessWidget {
  final Map<String, dynamic> companyData;

  const CompanyWidget({
    Key? key,
    required this.companyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String companyName = companyData['name'] ?? '';
    String companyImageUrl = companyData['imageUrl'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          companyName,
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              if (companyImageUrl.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(companyImageUrl),
                  radius: 80,
                ),
              SizedBox(height: 20),
              Text(
                '$companyName',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '@${companyData['username'] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      EventosPage(
                                companyData: companyData,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1,
                                        0), // Posición inicial (fuera de la pantalla a la derecha)
                                    end: Offset
                                        .zero, // Posición final (centro de la pantalla)
                                  ).animate(animation),
                                  child: child,
                                );
                              },
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
                              'Eventos de ${companyData['name'] ?? ''}',
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      GestionPersonal(
                                companyData: companyData,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1,
                                        0), // Posición inicial (fuera de la pantalla a la derecha)
                                    end: Offset
                                        .zero, // Posición final (centro de la pantalla)
                                  ).animate(animation),
                                  child: child,
                                );
                              },
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
