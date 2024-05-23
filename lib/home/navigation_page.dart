import 'package:app_listas/styles/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicons/unicons.dart';
import '../login/services/auth_google.dart';
import '../login/login.dart';
import 'homePage/home.dart';
import 'events/events.dart';
import 'company/company.dart';
import 'invitations/invitations.dart';
import 'profile/profile.dart'; // Import the ProfilePage
import 'dart:async'; // Importar la librería para usar StreamController

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
  late String uid;
  bool _isLoading = true;
  late AnimationController _controller;
  late User? currentUser; // Usuario actual

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
    await _getProfileImageUrl();
    await _getFirstName(uid);
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

  Future<void> _getProfileImageUrl() async {
    try {
      String? imageUrl = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) => doc.data()?['imageUrl']);

      if (imageUrl != null) {
        _profileImageUrl = imageUrl;
      }
    } catch (error) {
      print('Error obteniendo la URL de la foto de perfil: $error');
    }
  }

  Future<void> _getFirstName(String? uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        String firstname = userSnapshot.get('name');
        _firstName = firstname;
      }
    } catch (error) {
      print('Error obteniendo el nombre del usuario: $error');
    }
  }

  Future<String> _getLastName(String? uid) async {
    String lastName = '';
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        lastName = userSnapshot.get('lastname');
      }
    } catch (error) {
      print('Error obteniendo el apellido del usuario: $error');
    }
    return lastName;
  }

  Future<String> _getEmail() async {
    String email = '';
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email = user.email ?? '';
      }
    } catch (error) {
      print('Error obteniendo el correo electrónico del usuario: $error');
    }
    return email;
  }

  Stream<List<Map<String, dynamic>>> _getNotifications() async* {
    List<Map<String, dynamic>> notifications = [];

    // Fetch active events
    QuerySnapshot<Map<String, dynamic>> activeEventsSnapshot =
        await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

    for (var companyDoc in activeEventsSnapshot.docs) {
      QuerySnapshot activeEvents = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyDoc.id)
          .collection('myEvents')
          .where('eventState', isEqualTo: 'Active')
          .get();
      for (var eventDoc in activeEvents.docs) {
        notifications.add({
          'title': 'Evento Activo',
          'body': 'El evento ${eventDoc['eventName']} está activo.',
        });
      }
    }

    // Fetch live events
    QuerySnapshot<Map<String, dynamic>> liveEventsSnapshot =
        await FirebaseFirestore.instance
            .collection('companies')
            .where('ownerUid', isEqualTo: uid)
            .get();

    for (var companyDoc in liveEventsSnapshot.docs) {
      QuerySnapshot liveEvents = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyDoc.id)
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

    // Fetch new invitations
    QuerySnapshot invitationSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('receivedInvitations')
        .where('status', isEqualTo: 'pending')
        .get();

    for (var invitationDoc in invitationSnapshot.docs) {
      notifications.add({
        'title': 'Nueva Invitación',
        'body':
            'Tienes una nueva invitación de ${invitationDoc['companyName']}.',
      });
    }

    yield notifications;
  }

  Stream<int> _getInvitationCount() {
    return FirebaseFirestore.instance
        .collection('invitations')
        .doc(currentUser!.email) // Uso del email del usuario actual
        .collection(
            'receivedInvitations') // Subcolección de invitaciones recibidas
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
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: FutureBuilder<String>(
                future: _getLastName(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Cargando...');
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  String lastName = snapshot.data ?? '';
                  return Text(
                      lastName.isEmpty ? _firstName : '$_firstName $lastName');
                },
              ),
              accountEmail: FutureBuilder<String>(
                future: _getEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Cargando...');
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  String email = snapshot.data ?? '';
                  return Text(email);
                },
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
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.home,
                color: Color.fromARGB(255, 242, 187, 29),
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
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.event,
                color: Color.fromARGB(255, 242, 187, 29),
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
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Icons.business,
                color: Color.fromARGB(255, 242, 187, 29),
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
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Stack(
                    children: [
                      Icon(
                        UniconsLine.envelope_alt,
                        color: Color.fromARGB(255, 242, 187, 29),
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
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 242, 187, 29),
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Cerrando sesión'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Por favor, espere...'),
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
                  MaterialPageRoute(
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
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      print('Entrando a ig');
                    },
                    child: Image.asset(
                      'lib/assets/images/logo-exodo.png',
                      height: 45,
                      width: 60,
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
                    ),
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                          leading: Icon(Icons.notifications_off),
                          title: Text('No hay notificaciones'),
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: notifications.map((notification) {
                            return ListTile(
                              leading: Icon(Icons.notifications),
                              title: Text(notification['title']),
                              subtitle: Text(notification['body']),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Mis Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(UniconsLine.building),
            label: 'Mis Empresas',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
