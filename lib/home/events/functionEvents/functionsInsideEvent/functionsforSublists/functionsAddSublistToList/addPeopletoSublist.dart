import 'package:app_listas/styles/color.dart';
import 'package:app_listas/styles/helpDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddPeopleToSublist extends StatefulWidget {
  final Map<String, dynamic> list;
  final String sublistName;
  final String eventId;
  final String companyId;

  const AddPeopleToSublist({
    super.key,
    required this.list,
    required this.sublistName,
    required this.eventId,
    required this.companyId,
  });

  @override
  State<AddPeopleToSublist> createState() => _AddPeopleToSublistState();
}

class _AddPeopleToSublistState extends State<AddPeopleToSublist> {
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

  void _addPersonToSublist() async {
    setState(() {
      isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final names = _nameController.text.trim();

    if (names.isNotEmpty) {
      // Dividir los nombres usando la coma como delimitador
      List<String> nameList =
          names.split(',').map((name) => name.trim()).toList();

      // Verificar y agregar cada nombre
      for (String name in nameList) {
        if (name.isNotEmpty) {
          await _addSinglePersonToSublist(name);
        }
      }

      _nameController
          .clear(); // Limpiar el campo después de agregar los nombres
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debe ingresar al menos un nombre.',
            style: TextStyle(
              fontFamily: 'SFPro',
            ),
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addSinglePersonToSublist(String name) async {
    // Formatea el nombre para que la primera letra de cada palabra sea mayúscula
    String formattedName = capitalizeName(name);

    // Verifica que el nombre no exceda las 25 letras
    if (formattedName.length > 25) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            content: Text(
              'El nombre no puede exceder de 25 letras.',
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
      return; // Salir de la función si el nombre excede las 25 letras
    }

    var listDoc = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('myEvents')
        .doc(widget.eventId)
        .collection('eventLists')
        .doc(widget.list['listName']);

    var listSnapshot = await listDoc.get();
    var listData = listSnapshot.data() as Map<String, dynamic>?;

    if (listData != null &&
        listData.containsKey('sublists') &&
        listData['sublists'].containsKey(userId) &&
        listData['sublists'][userId].containsKey(widget.sublistName)) {
      var sublist = listData['sublists'][userId][widget.sublistName]
          as Map<String, dynamic>;

      if (sublist.containsKey('members')) {
        var members = sublist['members'] as List<dynamic>;

        // Verificar si la sublista ya tiene más de 25 miembros
        if (members.length >= 25) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                content: Text(
                  'No puedes añadir más de 25 personas a una sublista.',
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

        // Verificar si el nombre ya existe en la sublista
        if (members.any((member) => member['name'] == formattedName)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
                content: Text(
                  'El nombre "$formattedName" ya está en esta sublista.',
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

    // El nombre no existe en la sublista actual, agregarlo a la sublista
    try {
      await listDoc.update({
        'sublists.$userId.${widget.sublistName}.members':
            FieldValue.arrayUnion([
          {'name': formattedName, 'assisted': false},
        ]),
      });
    } catch (e) {
      print('Error adding person to sublist: $e');
    }
  }

  String capitalizeName(String name) {
    return name
        .split(' ') // Divide el nombre en palabras
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' '); // Vuelve a unir las palabras
  }

  void _removePerson(String name) async {
    if (name.isNotEmpty) {
      // Verificar si el nombre que se quiere eliminar es igual al nombre de la sublista
      if (name.toLowerCase() == widget.sublistName.toLowerCase()) {
        _showErrorDialog(
            'No puedes eliminar a $name porque es el nombre principal de la sublista.');
        return;
      }

      // Mostrar un diálogo de confirmación
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirmar Eliminación',
              style: TextStyle(fontFamily: 'SFPro'),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar a $name de la sublista?',
              style: const TextStyle(fontFamily: 'SFPro'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // No eliminar
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirmar eliminar
                child: const Text(
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

          await listDoc.update({
            'sublists.$userId.${widget.sublistName}.members':
                FieldValue.arrayRemove([
              {'name': name, 'assisted': false},
            ]),
          });
        } catch (e) {
          print('Error removing person from sublist: $e');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(fontFamily: 'SFPro'),
          ),
          content: Text(
            message,
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
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Sublista ${widget.sublistName}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help, // Icono de tickets
              color: Colors.white,
            ),
            onPressed: () {
              HelpDialog.showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.grey,
                  size: 20 * scaleFactor,
                ),
                hintText: 'Escribir nombres separados por comas',
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[a-zA-ZñÑ,\s]+$'),
                ),
              ],
              maxLength: null, // Permitir cualquier cantidad de texto
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
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
                onPressed: isLoading ? null : _addPersonToSublist,
                color: skyBluePrimary,
                child: isLoading
                    ? CupertinoActivityIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Añadir persona a sublista',
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
                  CupertinoIcons.person,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  'Personas en la sublista:',
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
                  'Puedes añadir hasta 25 personas',
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

                  var listData = snapshot.data!.data() as Map<String, dynamic>?;

                  if (listData == null ||
                      !listData.containsKey('sublists') ||
                      !listData['sublists'].containsKey(userId) ||
                      !listData['sublists'][userId]
                          .containsKey(widget.sublistName) ||
                      !listData['sublists'][userId][widget.sublistName]
                          .containsKey('members')) {
                    return Text(
                      'No hay personas en esta sublista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    );
                  }

                  var members = listData['sublists'][userId][widget.sublistName]
                      ['members'] as List<dynamic>;

                  if (members.isEmpty) {
                    return Text(
                      'No hay personas en esta sublista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    );
                  }

                  members.sort((a, b) => a['name'].compareTo(b['name']));

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      var member = members[index];
                      return ListTile(
                        title: Text(
                          member['name'],
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
                            });
                          },
                        ),
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
