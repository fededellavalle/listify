import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'functionsCompany/insideCompany.dart';
import 'package:unicons/unicons.dart';
import 'functionsCompany/createCompany.dart';
import '../../styles/loading.dart';

class CompanyPage extends StatefulWidget {
  final String? uid;

  CompanyPage({this.uid});

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

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
              indicatorColor: Color(
                  0xFF74BEB8), // Color del indicador cuando está seleccionado
              labelColor:
                  Color(0xFF74BEB8), // Color del texto cuando está seleccionado
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
                  CreateCompany(uid: widget.uid),
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
        backgroundColor: Color(0xFF74BEB8),
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
                return Center(child: LoadingScreen());
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
                      CompanyButton(
                        companyData: companyData,
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
                return Center(child: LoadingScreen());
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

                            return CompanyButton(
                              companyData: companyInfo,
                              category: companyData['category'],
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

  Stream<List<Map<String, dynamic>>> _fetchUserCompanyRelationships(
      String? uid) {
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          var companyRelationships =
              userData['companyRelationship'] as List<dynamic>? ?? [];
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

class CompanyButton extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final String? category;

  CompanyButton({
    required this.companyData,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyWidget(
              companyData: companyData,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                companyData['imageUrl'] ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyData['name'] ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '@${companyData['username'] ?? ''}',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 2),
                  if (category != null)
                    Text(
                      'Eres parte de $category',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
