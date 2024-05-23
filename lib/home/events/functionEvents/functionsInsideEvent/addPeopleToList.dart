import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../styles/button.dart';
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
          userEventListData.containsKey('membersList') &&
          userEventListData['membersList'].containsKey(userId) &&
          userEventListData['membersList'][userId]['members'] != null) {
        var members = userEventListData['membersList'][userId]['members'];
        if (members.any((member) => member['name'] == name)) {
          // El nombre ya existe en la lista del usuario actual
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('El nombre ya está en tu lista.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return; // Salir de la función si el nombre ya está en la lista
        }
      }

      if (userEventListData != null &&
          userEventListData.containsKey('membersList')) {
        var membersList =
            userEventListData['membersList'] as Map<String, dynamic>;
        for (var key in membersList.keys) {
          var members = membersList[key]['members'];
          if (members.any((member) => member['name'] == name)) {
            // El nombre existe en la lista de otro usuario
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content:
                      Text('El nombre ya está en la lista de otro usuario.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return; // Salir de la función si el nombre ya está en otra lista
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
      }
    }
  }

  void _removePerson(String name) async {
    if (name.isNotEmpty) {
      // Mostrar un diálogo de confirmación
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmar Eliminación'),
            content: Text(
                '¿Estás seguro de que quieres eliminar a $name de la lista?'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // No eliminar
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirmar eliminar
                child: Text('Eliminar'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista de ${widget.list['listName']}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.list_alt_outlined,
                          color: Colors.grey,
                        ),
                        hintText: 'Escribir el nombre de la persona',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z\s]+$')),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addPerson,
                        style: buttonPrimary,
                        child: Text(
                          'Añadir nombre a lista',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Personas en tu Lista:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Text(
                          'Puedes añadir hasta 150 personas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<DocumentSnapshot>(
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
                            style: TextStyle(color: Colors.white),
                          );
                        }

                        var membersList = eventListData['membersList']
                            as Map<String, dynamic>;

                        return membersList.containsKey(userId)
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    1, // Solo un elemento, ya que solo estamos mostrando la lista del usuario actual
                                itemBuilder: (context, index) {
                                  var memberGroup = membersList[userId];
                                  var members = memberGroup['members'];

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: members.length,
                                    itemBuilder: (context, index) {
                                      var member = members[index];
                                      return ListTile(
                                        title: Text(
                                          'Persona: ${member['name']}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                            'Asistencia: ${member['assisted']}'),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.red,
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
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
