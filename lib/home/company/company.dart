//import 'dart:ffi';

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

// Fetch company data for the current user

class _CompanyPageState extends State<CompanyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Mis Empresas'),
                Tab(text: 'Empresas Invitadas'),
              ],
              indicatorColor: Color.fromARGB(255, 242, 187,
                  29), // Color del indicador cuando está seleccionado
              labelColor: Color.fromARGB(255, 242, 187,
                  29), // Color del texto cuando está seleccionado
              unselectedLabelColor:
                  Colors.grey, // Color del texto cuando no está seleccionado
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserCompanies(),
          _buildInvitedCompanies(),
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
          Icons.add_business,
          size: 24,
          color: Colors.black,
        ), // Icono animado de Unicons
        label: Text(
          'Agregar empresa',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildUserCompanies() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchUserCompanyData(widget.uid),
            builder: (context, companySnapshot) {
              if (companySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (companySnapshot.hasError) {
                return Center(child: Text('Error fetching company data'));
              } else if (companySnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_business, color: Colors.white, size: 40),
                      SizedBox(height: 5),
                      Text('No tienes ninguna compañía a tu nombre',
                          style: GoogleFonts.roboto(color: Colors.white)),
                      SizedBox(height: 5),
                      Text('Crea una ya',
                          style: GoogleFonts.roboto(color: Colors.white)),
                    ],
                  ),
                );
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
                            Colors.transparent,
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.all(20),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvitedCompanies() {
    return Column(
      children: [
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
              } else if (relationshipSnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(UniconsLine.envelope, color: Colors.white, size: 40),
                      SizedBox(height: 5),
                      Text('No estas invitado ninguna compañía',
                          style: GoogleFonts.roboto(color: Colors.white)),
                    ],
                  ),
                );
              } else {
                return ListView(
                  children: [
                    for (var companyData in relationshipSnapshot.data!)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('companies')
                            .where('username',
                                isEqualTo: companyData['companyUsername'])
                            .limit(1)
                            .get()
                            .then((snapshot) => snapshot.docs.first),
                        builder: (context, companySnapshot) {
                          if (companySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (companySnapshot.hasError) {
                            return Center(
                                child: Text('Error fetching company data'));
                          } else {
                            Map<String, dynamic> companyInfo =
                                companySnapshot.data!.data()
                                    as Map<String, dynamic>;

                            return ElevatedButton(
                              onPressed: () {
                                // Handle button press for company relationships
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.transparent,
                                ),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  EdgeInsets.all(20),
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (companyInfo['imageUrl'] != null)
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              companyInfo['imageUrl']),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          companyInfo['name'] ?? '',
                                          style: GoogleFonts.roboto(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '@${companyInfo['username'] ?? ''}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Eres parte de ${companyData['category']}',
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
                            );
                          }
                        },
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

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
    String? uid,
  ) {
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
          var companyRelationships =
              userData['companyRelationship'] as List<dynamic>? ?? [];
          print(companyRelationships);

          return companyRelationships.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      });
    } else {
      return Stream.empty();
    }
  }
}
