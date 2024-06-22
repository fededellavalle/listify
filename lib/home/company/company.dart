import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicons/unicons.dart';
import 'functionsCompany/insideCompany.dart';
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
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

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
                Tab(
                  child: Text(
                    'Mis Empresas',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Empresas Invitadas',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                ),
              ],
              indicatorColor: Color(0xFF74BEB8),
              labelColor: Color(0xFF74BEB8),
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserCompanies(scaleFactor),
          _buildInvitedCompanies(scaleFactor),
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
          CupertinoIcons.add,
          size: 24 * scaleFactor,
          color: Colors.black,
        ),
        label: Text(
          'Agregar empresa',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'SFPro',
            fontSize: 14 * scaleFactor,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCompanies(double scaleFactor) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchUserCompanyData(widget.uid),
            builder: (context, companySnapshot) {
              if (companySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: LoadingScreen());
              } else if (companySnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error fetching company data',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (companySnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_business,
                          color: Colors.white, size: 40 * scaleFactor),
                      SizedBox(height: 5 * scaleFactor),
                      Text(
                        'No tienes ninguna compañía a tu nombre',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.white,
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 5 * scaleFactor),
                      Text(
                        'Crea una ya',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.white,
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView(
                  children: [
                    for (var companyData in companySnapshot.data!)
                      CompanyButton(
                        companyData: companyData,
                        scaleFactor: scaleFactor,
                        isOwner: true,
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

  Widget _buildInvitedCompanies(double scaleFactor) {
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
                  child: Text(
                    'Error fetching company relationships',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (relationshipSnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(UniconsLine.envelope,
                          color: Colors.white, size: 40 * scaleFactor),
                      SizedBox(height: 5 * scaleFactor),
                      Text(
                        'No estas invitado a ninguna compañía',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          color: Colors.white,
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
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
                              child: Text(
                                'Error fetching company data',
                                style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontSize: 14 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else {
                            Map<String, dynamic> companyInfo =
                                companySnapshot.data!.data()
                                    as Map<String, dynamic>;

                            return CompanyButton(
                              companyData: companyInfo,
                              category: companyData['category'],
                              scaleFactor: scaleFactor,
                              isOwner: false,
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
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList())
          .asyncExpand((ownerCompanies) {
        return FirebaseFirestore.instance
            .collection('companies')
            .where('co-ownerUid', isEqualTo: uid)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList())
            .map((coOwnerCompanies) {
          ownerCompanies.addAll(coOwnerCompanies);
          return ownerCompanies;
        });
      });
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
  final double scaleFactor;
  final bool isOwner;

  CompanyButton({
    required this.companyData,
    this.category,
    required this.scaleFactor,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isOwner) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyWidget(
                companyData: companyData,
                isOwner: true,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyWidget(
                companyData: companyData,
                isOwner: false,
                companyCategory: category,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16 * scaleFactor),
        margin: EdgeInsets.symmetric(
            vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4 * scaleFactor,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                companyData['imageUrl'] ?? '',
                width: 70 * scaleFactor,
                height: 70 * scaleFactor,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyData['name'] ?? '',
                    style: TextStyle(
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SFPro',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * scaleFactor),
                  Text(
                    '@${companyData['username'] ?? ''}',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontFamily: 'SFPro',
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 2 * scaleFactor),
                  if (category != null)
                    Text(
                      'Eres parte de $category',
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white, size: 24 * scaleFactor),
          ],
        ),
      ),
    );
  }
}
