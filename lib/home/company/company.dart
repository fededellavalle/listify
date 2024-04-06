import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'functionsCompany/insideCompany.dart';
import 'package:unicons/unicons.dart';
import 'functionsCompany/createCompany.dart';

class CompanyPage extends StatefulWidget {
  final String? uid;

  CompanyPage({this.uid});

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  void initState() {
    super.initState();
  }

  void _openCompanyDetails(Map<String, dynamic> companyData) {
    print('Company Data: $companyData');
    print("entre al boton");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyWidget(companyData: companyData),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCompanyData(String? uid) async {
    if (uid != null) {
      try {
        QuerySnapshot companySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

        List<Map<String, dynamic>> companies = [];

        await Future.forEach(companySnapshot.docs, (doc) async {
          String companyId = doc.id;
          String companyName = (doc.data() as Map<String, dynamic>)['name'];
          String companyUser = (doc.data() as Map<String, dynamic>)['username'];
          String? imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];

          Map<String, dynamic> companyData = {
            'companyId': companyId,
            'name': companyName,
            'username': companyUser,
            'imageUrl': imageUrl,
          };

          companies.add(companyData);
        });

        print(companies);
        return companies;
      } catch (e) {
        print('Error fetching company data: $e');
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Color de fondo del Scaffold
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else {
            List<Map<String, dynamic>> companies = [];

            snapshot.data?.docs.forEach((doc) {
              String companyId = doc.id;
              String companyName = doc['name'];
              String companyUser = doc['username'];
              String? imageUrl = doc['imageUrl'];

              Map<String, dynamic> companyData = {
                'companyId': companyId,
                'name': companyName,
                'username': companyUser,
                'imageUrl': imageUrl,
              };
              companies.add(companyData);
            });

            if (companies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Todavía no tienes empresa. ¿Quieres crear una ya?',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CreateCompany(
                              uid: widget.uid,
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
                      child: Text('Agregar una empresa'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                for (var companyData in companies) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  CompanyWidget(
                            companyData: companyData,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.black.withOpacity(0.0),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(20),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (companyData['imageUrl'] != null)
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(companyData['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.question_mark),
                            onPressed: () {},
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyData['name'] ?? '',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '@${companyData['username'] ?? ''}',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Siguiente evento: @${companyData['username'] ?? ''}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          UniconsLine.angle_right_b,
                          size: 40,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    // Divider para la línea
                    height: 1, // Altura de la línea
                    thickness: 1, // Grosor de la línea
                    color: Colors.white, // Color de la línea
                    indent: 8, // Espacio a la izquierda de la línea
                    endIndent: 8, // Espacio a la derecha de la línea
                  ),
                ],
                SizedBox(height: 20),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CreateCompany(
                uid: widget.uid,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
        backgroundColor: Color.fromARGB(255, 242, 187, 29),
        icon: Icon(
          UniconsLine.plus_circle,
          size: 24,
        ), // Icono animado de Unicons
        label: const Text(
          'Agregar empresa',
        ),
      ),
    );
  }
}
