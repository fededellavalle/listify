import 'package:app_listas/home/invitations/invitations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'company/company.dart';
import 'events/events.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/services/auth_google.dart';
import '../login/login.dart';
import 'package:unicons/unicons.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({
    super.key,
  });

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  String? _profileImageUrl;
  String _firstName = '';
  late String uid;

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _getProfileImageUrl();
    _getFirstName(uid);
    _widgetOptions = <Widget>[
      HomePage(
        uid: uid,
      ),
      EventsPage(
        uid: uid,
      ),
      CompanyPage(uid: uid),
    ];
  }

  Future<void> _getProfileImageUrl() async {
    try {
      // Obtener la URL de la imagen desde la base de datos
      String? imageUrl = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) => doc.data()?['imageUrl']);

      if (imageUrl != null) {
        setState(() {
          _profileImageUrl = imageUrl;
        });
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
        setState(() {
          _firstName = firstname;
        });
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () {
                        print('Entrando a perfil');
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_profileImageUrl!),
                      ),
                    )
                  : CircleAvatar(
                      child: IconButton(
                        icon: Icon(Icons.question_mark),
                        onPressed: () {
                          print('Entrando a perfil');
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
            ListTile(
              title: const Text(
                'Invitaciones',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                UniconsLine.envelope_alt,
                color: Color.fromARGB(255, 242, 187, 29),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvitationsPage(),
                  ),
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

                await FirebaseAuth.instance.signOut();
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
        title: Text(
          'Listify',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.notifications),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Mensaje 1'),
                  onTap: () {
                    // Acción al seleccionar el primer elemento del menú
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Mensaje 2'),
                  onTap: () {
                    // Acción al seleccionar el segundo elemento del menú
                  },
                ),
              ),
              // Agrega más elementos del menú si es necesario
            ],
            offset: Offset(0,
                kToolbarHeight), // Ajusta la posición vertical del menú emergente
          ),
          if (_profileImageUrl != null)
            GestureDetector(
              onTap: () {
                print('Entrando a perfil');
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(_profileImageUrl!),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.question_mark),
              onPressed: () {
                print('Entrando a perfil');
              },
            ),
          SizedBox(width: 8),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color.fromARGB(255, 242, 187, 29),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(UniconsLine.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(UniconsLine.calendar_alt),
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

/*

class _NavigationPageState extends State<NavigationPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.event,
                text: 'Mis Eventos',
              ),
              GButton(
                icon: Icons.cabin,
                text: 'Mi Empresa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/