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

  // Fetch company data for the current user
  Stream<List<Map<String, dynamic>>> _fetchUserCompanyData(String? uid) {
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('companies')
          .where('ownerUid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                String companyId = doc.id;
                String companyName = doc['name'];
                String companyUser = doc['username'];
                String ownerUid = doc['ownerUid'];
                String? imageUrl = doc['imageUrl'];

                return {
                  'companyId': companyId,
                  'name': companyName,
                  'username': companyUser,
                  'ownerUid': ownerUid,
                  'imageUrl': imageUrl,
                };
              }).toList());
    } else {
      return Stream.empty();
    }
  }

  // Fetch company relationships for the current user
  Stream<List<Map<String, dynamic>>> _fetchUserCompanyRelationships(
      String? uid) {
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          // Verifica si el documento existe antes de intentar acceder al campo
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          var companyRelationships = userData['companyRelationship'] ??
              []; // Obtén el campo 'companyRelationships' o una lista vacía si no está presente
          print(companyRelationships);

          return companyRelationships;
        } else {
          return [];
        }
      });
    } else {
      return Stream.empty();
    }
  }

  /*Future<List<Map<String, dynamic>>> _fetchCompanyData(String? uid) async {
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
          String ownerUid = (doc.data() as Map<String, dynamic>)['ownerUid'];
          String? imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];

          Map<String, dynamic> companyData = {
            'companyId': companyId,
            'name': companyName,
            'username': companyUser,
            'ownerUid': ownerUid,
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
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Text(
            'Mis Empresas',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchUserCompanyData(widget.uid),
              builder: (context, companySnapshot) {
                if (companySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (companySnapshot.hasError) {
                  return Center(child: Text('Error fetching company data'));
                } else {
                  return ListView(
                    children: [
                      for (var companyData in companySnapshot.data!)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompanyWidget(
                                  companyData: companyData,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.black.withOpacity(0.0),
                            ),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.all(20),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                                      image:
                                          NetworkImage(companyData['imageUrl']),
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
                        height: 1,
                        thickness: 1,
                        color: Colors.white,
                        indent: 8,
                        endIndent: 8,
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }
              },
            ),
          ),
          Text(
            'Empresas con las que tengo relacion',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchUserCompanyRelationships(widget.uid),
              builder: (context, relationshipSnapshot) {
                if (relationshipSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (relationshipSnapshot.hasError) {
                  return Center(
                      child: Text('Error fetching company relationships'));
                } else {
                  return ListView(
                    children: [
                      for (var companyData in relationshipSnapshot.data!)
                        ElevatedButton(
                          onPressed: () {
                            // Handle button press for company relationships
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.black.withOpacity(0.0),
                            ),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.all(20),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                                      image:
                                          NetworkImage(companyData['imageUrl']),
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
                        height: 1,
                        thickness: 1,
                        color: Colors.white,
                        indent: 8,
                        endIndent: 8,
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }
              },
            ),
          ),
        ],
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
