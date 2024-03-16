import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'company.dart';
import 'events.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/services/auth_google.dart';
import '../login/login.dart';

class NavigationPage extends StatefulWidget {
  final String? uid;
  final String? userName;

  NavigationPage({this.uid, this.userName});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  String? _profileImageUrl; // URL de la foto de perfil del usuario

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(userName: widget.userName),
      EventsPage(),
      CompanyPage(uid: widget.uid),
    ];
    // Obtener la URL de la foto de perfil del usuario
    _getProfileImageUrl();
  }

  Future<void> _getProfileImageUrl() async {
    try {
      // Obtener la URL de la imagen desde la base de datos
      String? imageUrl = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
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

  Future<String> _getLastName(String? uid) async {
  String lastName = '';
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        lastName = userSnapshot.get('apellido');
      }
    } catch (error) {
      print('Error obteniendo el apellido del usuario: $error');
    }
    return lastName;
  }

  // Método para obtener el correo electrónico del usuario desde la autenticación
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
      backgroundColor: Colors.black.withOpacity(0.9),
      drawer: Drawer(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: FutureBuilder<String>(
              future: _getLastName(widget.uid), // Llama al método para obtener el apellido
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Cargando...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                String lastName = snapshot.data ?? '';
                return Text('${widget.userName} ${lastName}');
              },
            ),
            accountEmail: FutureBuilder<String>(
              future: _getEmail(), // Llama al método para obtener el correo electrónico
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
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(_profileImageUrl!),
                    )
                  : CircleAvatar(
                      child: IconButton(
                        icon: Icon(Icons.question_mark),
                        onPressed: () {},
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
                color: Color.fromARGB(255, 242, 187, 29), // Cambia el color del icono a negro
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
                'Events',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.event,
                color: Color.fromARGB(255, 242, 187, 29), // Cambia el color del icono a negro
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
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
                Icons.business,
                color: Color.fromARGB(255, 242, 187, 29), // Cambia el color del icono a negro
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text(
                'Company',
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Icons.business,
                color: Color.fromARGB(255, 242, 187, 29), // Cambia el color del icono a negro
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
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 242, 187, 29), // Cambia el color del icono a negro
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, // Evita que se cierre la alerta al tocar fuera de ella
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Cerrando sesión'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(), // Indicador de carga
                          SizedBox(height: 16), // Espacio adicional
                          Text('Por favor, espere...'), // Mensaje de espera
                        ],
                      ),
                    );
                  },
                );

                // Realizar el cierre de sesión en Firebase y Google
                await FirebaseAuth.instance.signOut();
                await AuthService().signOutGoogle();

                // Cerrar la alerta y navegar a la pantalla de inicio de sesión
                Navigator.of(context).pop(); // Cerrar la alerta
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Reemplaza LoginPage con el nombre correcto de tu widget de inicio de sesión
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          if (_profileImageUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(_profileImageUrl!),
            )
          else
            IconButton(
              icon: Icon(Icons.question_mark),
              onPressed: () {},
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Mis Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
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