import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'list_item.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../../styles/button.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class Step3AddEvent extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final List<ListItem> lists;
  File? image;
  final Map<String, dynamic> companyData;
  final Map<String, dynamic>? template;

  Step3AddEvent({
    Key? key,
    required this.name,
    required this.ticketValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.lists,
    required this.image,
    required this.companyData,
    this.template,
  }) : super(key: key);

  @override
  State<Step3AddEvent> createState() => _Step3AddEventState();
}

class _Step3AddEventState extends State<Step3AddEvent> {
  bool _guardarPlantilla = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Paso 3: Confirmar Evento',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 225, // Altura deseada para la imagen
                    width: 100, // Ancho deseado para la imagen
                    child: Image.file(
                      widget.image!,
                      fit: BoxFit
                          .cover, // Ajusta la imagen para que cubra el espacio especificado
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Valor de la Entrada: \$${widget.ticketValue.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha de Inicio: ${widget.startDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(widget.startDateTime!) : 'No especificada'}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha de Fin: ${widget.endDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(widget.endDateTime!) : 'No especificada'}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Listas Disponibles:',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.lists.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          'Nombre: ${widget.lists[index].name}',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Tipo de lista: ${widget.lists[index].type}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 5), // Espacio entre los elementos
                      Text(
                        'La lista va a funcionar desde ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedStartDate ?? DateTime.now())} hasta ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedEndDate ?? DateTime.now())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(
                              255, 242, 187, 29), // Color del texto
                        ),
                      ),
                      if (widget.lists[index].addExtraTime)
                        Text(
                          'y con un extra de tiempo desde ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedStartExtraDate ?? DateTime.now())} hasta ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedEndExtraDate ?? DateTime.now())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(
                                255, 242, 187, 29), // Color del texto
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              if (widget.template != null)
                SwitchListTile(
                  title: Text(
                    'Guardar plantilla del Evento para próximos',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _guardarPlantilla,
                  onChanged: (newValue) {
                    setState(() {
                      _guardarPlantilla = newValue;
                    });
                  },
                  activeColor: Color.fromARGB(255, 242, 187, 29),
                ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLoading = true;
                          });
                          createEvent(context);
                        },
                  style: buttonPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              'Crear Evento',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createEvent(BuildContext context) async {
    String uuid = Uuid().v4();

    try {
      // Subir la imagen y obtener su URL
      Reference ref = FirebaseStorage.instance.ref().child(
          'company_images/${widget.companyData['companyId']}/myEvents/$uuid.jpg');
      UploadTask uploadTask = ref.putFile(widget.image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Crear un documento para el evento
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['companyId'])
          .collection('myEvents')
          .doc(uuid)
          .set({
        'eventName': widget.name,
        'eventTicketValue': widget.ticketValue,
        'eventStartTime': widget.startDateTime,
        'eventEndTime': widget.endDateTime,
        'eventImage': imageUrl,
        'eventState': 'Desactive',
      });

      // Colección de listas de eventos
      CollectionReference eventListsCollection = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['companyId'])
          .collection('myEvents')
          .doc(uuid)
          .collection('eventLists');

      // Agregar cada lista como un documento en la colección de listas de eventos
      for (var listItem in widget.lists) {
        await eventListsCollection.doc(listItem.name).set({
          'listName': listItem.name,
          'listType': listItem.type,
          'listStartTime': listItem.selectedStartDate,
          'listEndTime': listItem.selectedEndDate,
          'ticketPrice': listItem.ticketPrice,
          'membersList': [],
          'allowSublists': listItem.allowSublists,
        });
      }

      if (_guardarPlantilla) {
        await saveTemplate();
      }

      // Mostrar el AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Evento Creado'),
            content:
                Text('El evento ${widget.name} se ha creado correctamente.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el evento: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveTemplate() async {
    // Verificar el número de plantillas existentes
    QuerySnapshot templateSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('eventTemplates')
        .get();

    if (templateSnapshot.size >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ya tienes 3 plantillas guardadas. Elimina una para poder guardar una nueva.'),
        ),
      );
      return;
    }

    // Guardar la plantilla
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('eventTemplates')
        .add({
      'eventName': widget.name,
      'eventTicketValue': widget.ticketValue,
      'eventStartTime': widget.startDateTime,
      'eventEndTime': widget.endDateTime,
      'eventImage': widget.image != null ? widget.image!.path : null,
      'lists': widget.lists.map((listItem) {
        return {
          'listName': listItem.name,
          'listType': listItem.type,
          'listStartTime': listItem.selectedStartDate,
          'listEndTime': listItem.selectedEndDate,
          'ticketPrice': listItem.ticketPrice,
          'addExtraTime': listItem.addExtraTime,
          'selectedStartExtraDate': listItem.selectedStartExtraDate,
          'selectedEndExtraDate': listItem.selectedEndExtraDate,
          'ticketExtraPrice': listItem.ticketExtraPrice,
          'allowSublists': listItem.allowSublists,
        };
      }).toList(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plantilla guardada exitosamente.'),
      ),
    );
  }
}
