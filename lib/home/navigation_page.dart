import 'package:app_listas/styles/color.dart';
import 'package:app_listas/styles/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/services/auth_google.dart';
import '../login/login.dart';
import 'homePage/home.dart';
import 'events/events.dart';
import 'company/company.dart';
import 'invitations/invitations.dart';
import 'profile/profile.dart'; // Import the ProfilePage

class NavigationPage extends StatefulWidget {
  NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Default to Home
  late List<Widget> _widgetOptions;
  String? _profileImageUrl;
  String _firstName = '';
  String? _lastName = '';
  String _email = '';
  late String uid;
  bool _isLoading = true;
  late AnimationController _controller;
  late User? currentUser;
  late bool _trial = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await _getCurrentUserId();
    currentUser = FirebaseAuth.instance.currentUser;
    await _getUserData();
    _widgetOptions = <Widget>[
      HomePage(uid: uid),
      EventsPage(uid: uid),
      CompanyPage(uid: uid),
    ];
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
    }
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          _profileImageUrl = userData['imageUrl'] ?? '';
          _firstName = userData['name'] ?? '';
          _lastName = userData['lastname'] ?? '';
          _email = FirebaseAuth.instance.currentUser?.email ?? '';
          _trial = userData['trial'] ?? true;
        }
      }
    } catch (error) {
      print('Error obteniendo los datos del usuario: $error');
    }
  }

  Future<void> _activatePremiumTrial() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          if (userData['subscription'] == 'basic' &&
              userData['trial'] == false) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update({
              'subscription': 'premium',
              'trial': true,
              'trialStartDate': Timestamp.now(),
            });
            setState(() {
              _trial = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Has activado la prueba premium por 7 días.',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ya has usado la prueba premium o no eres un usuario básico.',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      print('Error activando la prueba premium: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error activando la prueba premium.',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
        ),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> _getNotifications() async* {
    List<Map<String, dynamic>> notifications = [];

    QuerySnapshot<Map<String, dynamic>> activeEventsCompanySnapshot =
        await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

    // Obtener relaciones de empresas del usuario
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      var companyRelationships =
          userData['companyRelationship'] as List<dynamic>? ?? [];

      // Crear una lista para todas las empresas (propias y relacionadas)
      List<String> companyIds = [];

      // Agregar empresas donde el usuario es el propietario
      for (var companyDoc in activeEventsCompanySnapshot.docs) {
        companyIds.add(companyDoc.id);
      }

      // Agregar empresas relacionadas
      for (var relationship in companyRelationships) {
        String companyUsername = relationship['companyUsername'];

        QuerySnapshot<Map<String, dynamic>> relatedCompanySnapshot =
            await FirebaseFirestore.instance
                .collection('companies')
                .where('username', isEqualTo: companyUsername)
                .get();

        for (var doc in relatedCompanySnapshot.docs) {
          companyIds.add(doc.id);
        }
      }

      // Obtener eventos activos y en vivo para todas las empresas
      for (String companyId in companyIds) {
        // Eventos activos
        QuerySnapshot activeEvents = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('myEvents')
            .where('eventState', isEqualTo: 'Active')
            .get();

        for (var eventDoc in activeEvents.docs) {
          notifications.add({
            'title': 'Evento Activo',
            'body': 'El evento ${eventDoc['eventName']} está activo.',
          });
        }

        // Eventos en vivo
        QuerySnapshot liveEvents = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('myEvents')
            .where('eventState', isEqualTo: 'Live')
            .get();

        for (var eventDoc in liveEvents.docs) {
          notifications.add({
            'title': 'Evento En Vivo',
            'body': 'El evento ${eventDoc['eventName']} está en vivo.',
          });
        }
      }
    }

    // Fetch new invitations
    QuerySnapshot invitationSnapshot = await FirebaseFirestore.instance
        .collection('invitations')
        .doc(currentUser!.email)
        .collection('receivedInvitations')
        .get();

    for (var invitationDoc in invitationSnapshot.docs) {
      notifications.add({
        'title': 'Nueva Invitación',
        'body': 'Tienes una nueva invitación de ${invitationDoc['company']}.',
      });
    }

    yield notifications;
  }

  Stream<int> _getInvitationCount() {
    return FirebaseFirestore.instance
        .collection('invitations')
        .doc(currentUser!.email)
        .collection('receivedInvitations')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: LoadingScreen(),
            ),
          )
        : FadeTransition(
            opacity: _controller,
            child: _buildMainContent(context),
          );
  }

  Widget _buildMainContent(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        drawer: Drawer(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  _lastName == null ? _firstName : '$_firstName $_lastName',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                accountEmail: Text(
                  _email,
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                currentAccountPicture: _profileImageUrl != null
                    ? GestureDetector(
                        onTap: () async {
                          final updatedProfileImageUrl = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(uid: uid),
                            ),
                          );

                          if (updatedProfileImageUrl != null) {
                            setState(() {
                              _profileImageUrl = updatedProfileImageUrl;
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_profileImageUrl!),
                        ),
                      )
                    : CircleAvatar(
                        child: IconButton(
                          icon: Icon(Icons.question_mark),
                          onPressed: () async {
                            final updatedProfileImageUrl = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(uid: uid),
                              ),
                            );

                            if (updatedProfileImageUrl != null) {
                              setState(() {
                                _profileImageUrl = updatedProfileImageUrl;
                              });
                            }
                          },
                        ),
                      ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
              ListTile(
                title: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                ),
                leading: Icon(
                  CupertinoIcons.home,
                  color: skyBluePrimary,
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: const Text(
                  'Eventos',
                  style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                ),
                leading: Icon(
                  CupertinoIcons.calendar,
                  color: skyBluePrimary,
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: Text(
                  'Empresas',
                  style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                ),
                leading: Icon(
                  CupertinoIcons.building_2_fill,
                  color: skyBluePrimary,
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                    Navigator.pop(context);
                  });
                },
              ),
              StreamBuilder<int>(
                stream: _getInvitationCount(),
                builder: (context, snapshot) {
                  int invitationCount = snapshot.data ?? 0;
                  return ListTile(
                    title: Text(
                      'Invitaciones',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                    ),
                    leading: Stack(
                      children: [
                        Icon(
                          CupertinoIcons.mail,
                          color: skyBluePrimary,
                        ),
                        if (invitationCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$invitationCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvitationsPage(),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Mi Perfil',
                  style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                ),
                leading: Icon(
                  CupertinoIcons.person,
                  color: skyBluePrimary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid),
                    ),
                  );
                },
              ),
              if (_trial != true)
                ListTile(
                  title: Text(
                    'Probar Premium 7 días',
                    style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                  ),
                  leading: Icon(
                    CupertinoIcons.star,
                    color: Colors.yellow,
                  ),
                  onTap: _activatePremiumTrial,
                ),
              ListTile(
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                ),
                leading: Icon(
                  CupertinoIcons.square_arrow_right,
                  color: skyBluePrimary,
                ),
                onTap: () async {
                  showCupertinoDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text(
                          'Cerrando sesión',
                          style: TextStyle(fontFamily: 'SFPro'),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Por favor, espere...',
                              style: TextStyle(fontFamily: 'SFPro'),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  await AuthService().signOut();
                  await AuthService().signOutGoogle();

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'SFPro'),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        print('Entrando a ig');
                      },
                      child: Image.asset(
                        'lib/assets/images/logo-exodo.png',
                        height: 45,
                        width: 75,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/images/listifyIconRecortada.png',
                      height: 30.0, // Ajusta el tamaño según tus necesidades
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Listify',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SFPro'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.notifications),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _getNotifications(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return ListTile(
                            leading: Icon(Icons.error, color: Colors.red),
                            title: Text('Error al cargar notificaciones'),
                          );
                        }

                        List<Map<String, dynamic>> notifications =
                            snapshot.data ?? [];

                        if (notifications.isEmpty) {
                          return ListTile(
                            leading: Icon(CupertinoIcons.bell_slash_fill),
                            title: Text(
                              'No hay notificaciones',
                              style: TextStyle(fontFamily: 'SFPro'),
                            ),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: notifications.map((notification) {
                              return ListTile(
                                leading: Icon(CupertinoIcons.bell_fill),
                                title: Text(
                                  notification['title'],
                                  style: TextStyle(fontFamily: 'SFPro'),
                                ),
                                subtitle: Text(
                                  notification['body'],
                                  style: TextStyle(fontFamily: 'SFPro'),
                                ),
                                onTap: () {
                                  // Handle notification tap
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                ];
              },
              offset: Offset(0, kToolbarHeight),
            ),
          ],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Color(0xFF74BEB8),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 12 * scaleFactor,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 12 * scaleFactor,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home, size: 24 * scaleFactor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar, size: 24 * scaleFactor),
              label: 'Mis Eventos',
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(CupertinoIcons.building_2_fill, size: 24 * scaleFactor),
              label: 'Mis Empresas',
            ),
          ],
        ),
      ),
    );
  }
}
