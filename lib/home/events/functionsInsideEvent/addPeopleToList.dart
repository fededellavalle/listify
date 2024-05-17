import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../styles/button.dart';

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

  void _addPersonToList() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        // Inicializa eventList si no existe
        widget.list['eventLists'] = widget.list['eventLists'] ?? [];

        // Encuentra el objeto de lista actual
        bool listFound = false;

        for (var list in widget.list['eventLists']) {
          if (list['listName'] == widget.list['listName']) {
            // Inicializa membersList si no existe
            list['membersList'] = list['membersList'] ?? [];

            bool userFound = false;

            for (var memberGroup in list['membersList']) {
              if (memberGroup['property']['uid'] == userId) {
                memberGroup['members'].add({
                  'name': name,
                  'assisted': false,
                });
                userFound = true;
                break;
              }
            }

            if (!userFound) {
              list['membersList'].add({
                'property': {
                  'uid': userId,
                },
                'members': [
                  {
                    'name': name,
                    'assisted': false,
                  },
                ],
              });
            }

            listFound = true;
            break;
          }
        }

        if (!listFound) {
          widget.list['eventLists'].add({
            'listName': widget.list['listName'],
            'membersList': [
              {
                'property': {
                  'uid': userId,
                },
                'members': [
                  {
                    'name': name,
                    'assisted': false,
                  },
                ],
              },
            ],
          });
        }
      });

      // Update Firestore
      try {
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .doc(widget.list['listName']);

        print(listDoc);

        // Verificar si el campo 'membersList' ya existe
        var docSnapshot = await listDoc.get();

        // Actualizar 'membersList' usando arrayUnion para agregar el nuevo miembro
        await listDoc.update({
          'membersList.$userId.members': FieldValue.arrayUnion([
            {'name': name, 'assisted': false},
          ]),
        });
      } catch (e) {
        print('Error updating membersList: $e');
      }

      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.list['listName']}',
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.list_alt_outlined,
                  color: Color.fromARGB(255, 242, 187, 29),
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
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 158, 128, 36),
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addPersonToList,
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.list['eventLists']?.length ?? 0,
              itemBuilder: (context, index) {
                final listGroup = widget.list['eventLists'][index];
                if (listGroup['listName'] != widget.list['listName']) {
                  return Container(); // Skip lists that don't match the current listName
                }
                return ExpansionTile(
                  title: Text(
                    'Lista: ${listGroup['listName']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  children: [
                    for (var memberGroup in listGroup['membersList'])
                      ExpansionTile(
                        title: Text(
                          'Usuario: ${memberGroup['property']['uid']}',
                          style: TextStyle(color: Colors.white),
                        ),
                        children: [
                          for (var member in memberGroup['members'])
                            ListTile(
                              title: Text(
                                'Persona: ${member['name']}',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle:
                                  Text('Asistencia: ${member['assisted']}'),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    memberGroup['members'].remove(member);
                                    if (memberGroup['members'].isEmpty) {
                                      listGroup['membersList']
                                          .remove(memberGroup);
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
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
