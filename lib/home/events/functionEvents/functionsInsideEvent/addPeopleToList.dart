import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddPeopleToList extends StatefulWidget {
  final Map<String, dynamic> list;
  final String eventId;
  final String companyId;

  const AddPeopleToList({
    super.key,
    required this.list,
    required this.eventId,
    required this.companyId,
  });

  @override
  State<AddPeopleToList> createState() => _AddPeopleToListState();
}

class _AddPeopleToListState extends State<AddPeopleToList> {
  late TextEditingController _nameController;
  late String userId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  void _addPerson() async {
    setState(() {
      isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Verificar si el nombre ya existe en la lista del usuario actual
      var userEventListRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .doc(widget.eventId)
          .collection('eventLists')
          .doc(widget.list['listName']);

      var userEventListSnapshot = await userEventListRef.get();
      var userEventListData = userEventListSnapshot.data();

      if (userEventListData != null &&
          userEventListData.containsKey('membersList')) {
        var membersList = userEventListData['membersList'];

        if (membersList is Map<String, dynamic> &&
            membersList.containsKey(userId) &&
            membersList[userId]['members'] != null) {
          var members = membersList[userId]['members'];
          if (members.any((member) => member['name'] == name)) {
            // El nombre ya existe en la lista del usuario actual
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Error',
                    style: TextStyle(fontFamily: 'SFPro'),
                  ),
                  content: Text(
                    'El nombre ya está en tu lista.',
                    style: TextStyle(fontFamily: 'SFPro'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'OK',
                        style: TextStyle(fontFamily: 'SFPro'),
                      ),
                    ),
                  ],
                );
              },
            );
            setState(() {
              isLoading = false;
            });
            return; // Salir de la función si el nombre ya está en la lista
          }
        }

        if (membersList is Map<String, dynamic>) {
          for (var key in membersList.keys) {
            var members = membersList[key]['members'];
            if (members.any((member) => member['name'] == name)) {
              // El nombre existe en la lista de otro usuario
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Error',
                      style: TextStyle(fontFamily: 'SFPro'),
                    ),
                    content: Text(
                      'El nombre ya está en la lista de otro usuario.',
                      style: TextStyle(fontFamily: 'SFPro'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: TextStyle(fontFamily: 'SFPro'),
                        ),
                      ),
                    ],
                  );
                },
              );
              setState(() {
                isLoading = false;
              });
              return; // Salir de la función si el nombre ya está en otra lista
            }
          }
        }
      }

      // El nombre no existe en ninguna lista, agregarlo a la lista del usuario actual
      try {
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .doc(widget.list['listName']);

        // Actualizar 'membersList' usando arrayUnion para agregar el nuevo miembro
        await listDoc.update({
          'membersList.$userId.members': FieldValue.arrayUnion([
            {'name': name, 'assisted': false},
          ]),
        });

        _nameController.clear();
      } catch (e) {
        print('Error updating membersList: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Debe ingresar un nombre.',
          style: TextStyle(
            fontFamily: 'SFPro',
          ),
        )),
      );
    }
  }

  void _removePerson(String name) async {
    if (name.isNotEmpty) {
      // Mostrar un diálogo de confirmación
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmar Eliminación',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar a $name de la lista?',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // No eliminar
                child: Text(
                  'Cancelar',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirmar eliminar
                child: Text(
                  'Eliminar',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Update Firestore
        try {
          DocumentReference listDoc = FirebaseFirestore.instance
              .collection('companies')
              .doc(widget.companyId)
              .collection('myEvents')
              .doc(widget.eventId)
              .collection('eventLists')
              .doc(widget.list['listName']);

          // Actualizar 'membersList' usando arrayRemove para eliminar el miembro
          await listDoc.update({
            'membersList.$userId.members': FieldValue.arrayRemove([
              {
                'name': name,
                'assisted': false
              }, // Incluye todos los campos necesarios para identificar el elemento
            ]),
          });
        } catch (e) {
          print('Error updating membersList: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista de ${widget.list['listName']}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(widget.companyId)
                  .collection('myEvents')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (context, eventSnapshot) {
                if (!eventSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var eventData =
                    eventSnapshot.data!.data() as Map<String, dynamic>?;
                if (eventData == null || eventData['eventState'] != 'Active') {
                  return Center(
                    child: Text(
                      'El evento no está activo. No se pueden agregar personas.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.list_alt_outlined,
                            color: Colors.grey,
                            size: 20 * scaleFactor,
                          ),
                          hintText: 'Escribir el nombre de la persona',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z\s]+$')),
                        ],
                        maxLength: 25,
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20 * scaleFactor,
                          ),
                          SizedBox(width: 5 * scaleFactor),
                          Expanded(
                            child: Text(
                              'Solo se permiten ingresar letras',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14 * scaleFactor,
                                fontFamily: 'SFPro',
                              ),
                              overflow: TextOverflow
                                  .visible, // Permitir que el texto se envuelva
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          onPressed: isLoading ? null : _addPerson,
                          color: skyBluePrimary,
                          child: isLoading
                              ? CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Añadir nombre a lista',
                                  style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    fontFamily: 'SFPro',
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 20 * scaleFactor,
                          ),
                          SizedBox(width: 5 * scaleFactor),
                          Text(
                            'Personas en tu Lista:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3 * scaleFactor),
                      Row(
                        children: [
                          Text(
                            'Puedes añadir hasta 150 personas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('companies')
                              .doc(widget.companyId)
                              .collection('myEvents')
                              .doc(widget.eventId)
                              .collection('eventLists')
                              .doc(widget.list['listName'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            var eventListData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            if (eventListData == null ||
                                !eventListData.containsKey('membersList')) {
                              return Text(
                                'No hay miembros en esta lista.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              );
                            }

                            var membersList = eventListData['membersList'];
                            if (membersList is! Map<String, dynamic>) {
                              return Text(
                                'No hay miembros en esta lista.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              );
                            }

                            return membersList.containsKey(userId)
                                ? ListView.builder(
                                    itemCount:
                                        1, // Solo un elemento, ya que solo estamos mostrando la lista del usuario actual
                                    itemBuilder: (context, index) {
                                      var memberGroup = membersList[userId];
                                      var members = memberGroup['members'];

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: members.length,
                                        itemBuilder: (context, index) {
                                          var member = members[index];
                                          return ListTile(
                                            title: Text(
                                              '${member['name']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16 * scaleFactor,
                                                fontFamily: 'SFPro',
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                CupertinoIcons.clear,
                                                color: Colors.red,
                                                size: 20 * scaleFactor,
                                              ),
                                              onPressed: () {
                                                _removePerson(member['name']);
                                                setState(() {
                                                  members.removeAt(index);
                                                  if (members.isEmpty) {
                                                    membersList.remove(userId);
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      'No hay miembros en tu lista.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16 * scaleFactor,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


/*

Aca se agrega el nombre del usuario que hace la lista
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddPeopleToList extends StatefulWidget {
  final Map<String, dynamic> list;
  final String eventId;
  final String companyId;

  const AddPeopleToList({
    super.key,
    required this.list,
    required this.eventId,
    required this.companyId,
  });

  @override
  State<AddPeopleToList> createState() => _AddPeopleToListState();
}

class _AddPeopleToListState extends State<AddPeopleToList> {
  late TextEditingController _nameController;
  late String userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _addCurrentUserToList();
    }
  }

  Future<void> _addCurrentUserToList() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          String name = userData['name'] ?? '';
          String lastname = userData['lastname'] ?? '';
          String fullName = name;
          if (lastname.isNotEmpty) {
            fullName += ' $lastname';
          }
          await _addUserToList(fullName);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _addUserToList(String fullName) async {
    var listDoc = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('myEvents')
        .doc(widget.eventId)
        .collection('eventLists')
        .doc(widget.list['listName']);
    var listSnapshot = await listDoc.get();
    var listData = listSnapshot.data() as Map<String, dynamic>?;

    if (listData != null && listData.containsKey('membersList')) {
      var membersList = listData['membersList'];

      if (membersList is Map<String, dynamic> &&
          membersList.containsKey(userId) &&
          membersList[userId]['members'] != null) {
        var members = membersList[userId]['members'];
        if (members.any((member) => member['name'] == fullName)) {
          return; // El usuario ya está en la lista
        }
      }
    }

    try {
      await listDoc.update({
        'membersList.$userId.members': FieldValue.arrayUnion([
          {'name': fullName, 'assisted': false},
        ]),
      });
    } catch (e) {
      print('Error adding user to list: $e');
    }
  }

  void _addPerson() async {
    setState(() {
      isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Verificar si el nombre ya existe en la lista del usuario actual
      var userEventListRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .doc(widget.eventId)
          .collection('eventLists')
          .doc(widget.list['listName']);

      var userEventListSnapshot = await userEventListRef.get();
      var userEventListData = userEventListSnapshot.data();

      if (userEventListData != null &&
          userEventListData.containsKey('membersList')) {
        var membersList = userEventListData['membersList'];

        if (membersList is Map<String, dynamic> &&
            membersList.containsKey(userId) &&
            membersList[userId]['members'] != null) {
          var members = membersList[userId]['members'];
          if (members.any((member) => member['name'] == name)) {
            // El nombre ya existe en la lista del usuario actual
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Error',
                    style: TextStyle(fontFamily: 'SFPro'),
                  ),
                  content: Text(
                    'El nombre ya está en tu lista.',
                    style: TextStyle(fontFamily: 'SFPro'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'OK',
                        style: TextStyle(fontFamily: 'SFPro'),
                      ),
                    ),
                  ],
                );
              },
            );
            setState(() {
              isLoading = false;
            });
            return; // Salir de la función si el nombre ya está en la lista
          }
        }

        if (membersList is Map<String, dynamic>) {
          for (var key in membersList.keys) {
            var members = membersList[key]['members'];
            if (members.any((member) => member['name'] == name)) {
              // El nombre existe en la lista de otro usuario
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Error',
                      style: TextStyle(fontFamily: 'SFPro'),
                    ),
                    content: Text(
                      'El nombre ya está en la lista de otro usuario.',
                      style: TextStyle(fontFamily: 'SFPro'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: TextStyle(fontFamily: 'SFPro'),
                        ),
                      ),
                    ],
                  );
                },
              );
              setState(() {
                isLoading = false;
              });
              return; // Salir de la función si el nombre ya está en otra lista
            }
          }
        }
      }

      // El nombre no existe en ninguna lista, agregarlo a la lista del usuario actual
      try {
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .doc(widget.list['listName']);

        // Actualizar 'membersList' usando arrayUnion para agregar el nuevo miembro
        await listDoc.update({
          'membersList.$userId.members': FieldValue.arrayUnion([
            {'name': name, 'assisted': false},
          ]),
        });

        _nameController.clear();
      } catch (e) {
        print('Error updating membersList: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Debe ingresar un nombre.',
          style: TextStyle(
            fontFamily: 'SFPro',
          ),
        )),
      );
    }
  }

  void _removePerson(String name) async {
    if (name.isNotEmpty) {
      // Mostrar un diálogo de confirmación
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmar Eliminación',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar a $name de la lista?',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // No eliminar
                child: Text(
                  'Cancelar',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirmar eliminar
                child: Text(
                  'Eliminar',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Update Firestore
        try {
          DocumentReference listDoc = FirebaseFirestore.instance
              .collection('companies')
              .doc(widget.companyId)
              .collection('myEvents')
              .doc(widget.eventId)
              .collection('eventLists')
              .doc(widget.list['listName']);

          // Actualizar 'membersList' usando arrayRemove para eliminar el miembro
          await listDoc.update({
            'membersList.$userId.members': FieldValue.arrayRemove([
              {
                'name': name,
                'assisted': false
              }, // Incluye todos los campos necesarios para identificar el elemento
            ]),
          });
        } catch (e) {
          print('Error updating membersList: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista de ${widget.list['listName']}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(widget.companyId)
                  .collection('myEvents')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (context, eventSnapshot) {
                if (!eventSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var eventData =
                    eventSnapshot.data!.data() as Map<String, dynamic>?;
                if (eventData == null || eventData['eventState'] != 'Active') {
                  return Center(
                    child: Text(
                      'El evento no está activo. No se pueden agregar personas.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.list_alt_outlined,
                            color: Colors.grey,
                            size: 20 * scaleFactor,
                          ),
                          hintText: 'Escribir el nombre de la persona',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z\s]+$')),
                        ],
                        maxLength: 25,
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          onPressed: isLoading ? null : _addPerson,
                          color: skyBluePrimary,
                          child: isLoading
                              ? CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Añadir nombre a lista',
                                  style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    fontFamily: 'SFPro',
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 20 * scaleFactor,
                          ),
                          SizedBox(width: 5 * scaleFactor),
                          Text(
                            'Personas en tu Lista:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3 * scaleFactor),
                      Row(
                        children: [
                          Text(
                            'Puedes añadir hasta 150 personas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14 * scaleFactor,
                              fontFamily: 'SFPro',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('companies')
                              .doc(widget.companyId)
                              .collection('myEvents')
                              .doc(widget.eventId)
                              .collection('eventLists')
                              .doc(widget.list['listName'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            var eventListData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            if (eventListData == null ||
                                !eventListData.containsKey('membersList')) {
                              return Text(
                                'No hay miembros en esta lista.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              );
                            }

                            var membersList = eventListData['membersList'];
                            if (membersList is! Map<String, dynamic>) {
                              return Text(
                                'No hay miembros en esta lista.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * scaleFactor,
                                  fontFamily: 'SFPro',
                                ),
                              );
                            }

                            return membersList.containsKey(userId)
                                ? ListView.builder(
                                    itemCount:
                                        1, // Solo un elemento, ya que solo estamos mostrando la lista del usuario actual
                                    itemBuilder: (context, index) {
                                      var memberGroup = membersList[userId];
                                      var members = memberGroup['members'];

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: members.length,
                                        itemBuilder: (context, index) {
                                          var member = members[index];
                                          return ListTile(
                                            title: Text(
                                              '${member['name']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16 * scaleFactor,
                                                fontFamily: 'SFPro',
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                CupertinoIcons.clear,
                                                color: Colors.red,
                                                size: 20 * scaleFactor,
                                              ),
                                              onPressed: () {
                                                _removePerson(member['name']);
                                                setState(() {
                                                  members.removeAt(index);
                                                  if (members.isEmpty) {
                                                    membersList.remove(userId);
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      'No hay miembros en tu lista.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16 * scaleFactor,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

 */