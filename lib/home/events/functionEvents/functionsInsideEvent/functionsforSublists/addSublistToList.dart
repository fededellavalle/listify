import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/functionsforSublists/functionsAddSublistToList/addPeopletoSublist.dart';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddSublistsToList extends StatefulWidget {
  final Map<String, dynamic> list;
  final String eventId;
  final String companyId;

  const AddSublistsToList({
    super.key,
    required this.list,
    required this.eventId,
    required this.companyId,
  });

  @override
  State<AddSublistsToList> createState() => _AddSublistsToListState();
}

class _AddSublistsToListState extends State<AddSublistsToList> {
  late TextEditingController _sublistNameController;
  late String userId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _sublistNameController = TextEditingController();
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

  void _addSublist() async {
    setState(() {
      isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final sublistName = _sublistNameController.text.trim();
    if (sublistName.isNotEmpty) {
      try {
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .doc(widget.list['listName']);

        // Verificar si el usuario ya tiene 6 sublistas
        var listSnapshot = await listDoc.get();
        var listData = listSnapshot.data() as Map<String, dynamic>?;

        if (listData != null && listData.containsKey('sublists')) {
          var sublists = listData['sublists'] as Map<String, dynamic>;

          if (sublists.containsKey(userId) &&
              (sublists[userId] as Map<String, dynamic>).length >= 6) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Error',
                    style: TextStyle(fontFamily: 'SFPro'),
                  ),
                  content: Text(
                    'No puedes añadir más de 6 sublistas.',
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
            return;
          }
        }

        // Verificar si el nombre de la sublista ya existe en otras listas de otros usuarios
        var allListsSnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .get();

        for (var doc in allListsSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('sublists')) {
            var allSublists = data['sublists'] as Map<String, dynamic>;
            for (var key in allSublists.keys) {
              var userSublists = allSublists[key] as Map<String, dynamic>;
              if (userSublists.containsKey(sublistName)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Error',
                        style: TextStyle(fontFamily: 'SFPro'),
                      ),
                      content: Text(
                        'El nombre de la sublista ya existe en otra lista de otro usuario.',
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
                return;
              }
            }
          }
        }

        // Agregar la nueva sublista con el creador en 'members'
        await listDoc.update({
          'sublists.$userId.$sublistName': {
            'members': [
              {'name': sublistName, 'assisted': false}
            ]
          },
        });

        _sublistNameController.clear();
      } catch (e) {
        print('Error updating sublists: $e');
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
            'Debe ingresar un nombre para la sublista.',
            style: TextStyle(
              fontFamily: 'SFPro',
            ),
          ),
        ),
      );
    }
  }

  void _deleteSublist(String sublistName) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Eliminación',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la sublista $sublistName?',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No eliminar
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
      try {
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyId)
            .collection('myEvents')
            .doc(widget.eventId)
            .collection('eventLists')
            .doc(widget.list['listName']);

        await listDoc.update({
          'sublists.$userId.$sublistName': FieldValue.delete(),
        });
      } catch (e) {
        print('Error deleting sublist: $e');
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
          'Sublistas de ${widget.list['listName']}',
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
            TextFormField(
              controller: _sublistNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.list_alt_outlined,
                  color: Colors.grey,
                  size: 20 * scaleFactor,
                ),
                hintText: 'Escribir el nombre de la sublista',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
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
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
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
                onPressed: isLoading ? null : _addSublist,
                color: skyBluePrimary,
                child: isLoading
                    ? CupertinoActivityIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Añadir sublista',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10 * scaleFactor),
            const Row(
              children: [
                Icon(
                  Icons.list_alt_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  'Sublistas Creadas:',
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
                  'Puedes crear hasta 6 sublistas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                      !eventListData.containsKey('sublists')) {
                    return Text(
                      'No hay sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    );
                  }

                  var sublists = eventListData['sublists'];
                  if (sublists is! Map<String, dynamic>) {
                    return Text(
                      'No hay sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    );
                  }

                  if (!sublists.containsKey(userId)) {
                    return Text(
                      'No tienes sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    );
                  }

                  var userSublists = sublists[userId] as Map<String, dynamic>;
                  var sortedSublists = userSublists.keys.toList()..sort();

                  return ListView.builder(
                    itemCount: sortedSublists.length,
                    itemBuilder: (context, index) {
                      var sublistName = sortedSublists[index];
                      return ListTile(
                        title: Text(
                          sublistName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * scaleFactor,
                            fontFamily: 'SFPro',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.add,
                                color: Colors.green,
                                size: 20 * scaleFactor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPeopleToSublist(
                                      list: widget.list,
                                      sublistName: sublistName,
                                      eventId: widget.eventId,
                                      companyId: widget.companyId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                                size: 20 * scaleFactor,
                              ),
                              onPressed: () {
                                _deleteSublist(sublistName);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPeopleToSublist(
                                list: widget.list,
                                sublistName: sublistName,
                                eventId: widget.eventId,
                                companyId: widget.companyId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
