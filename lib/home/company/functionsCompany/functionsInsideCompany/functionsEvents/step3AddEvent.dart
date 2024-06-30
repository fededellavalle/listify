import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'list_item.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../../styles/button.dart';
import 'package:uuid/uuid.dart';

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
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Paso 3: Confirmar Evento',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 16 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 225 * scaleFactor, // Altura deseada para la imagen
                    width: 100 * scaleFactor, // Ancho deseado para la imagen
                    child: Image.file(
                      widget.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10 * scaleFactor),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 16 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Text(
                        'Valor de la Entrada: \$${widget.ticketValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Text(
                        'Fecha de Inicio: ${widget.startDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(widget.startDateTime!) : 'No especificada'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),
                      Text(
                        'Fecha de Fin: ${widget.endDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(widget.endDateTime!) : 'No especificada'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20 * scaleFactor),
              Text(
                'Listas Disponibles:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 16 * scaleFactor,
                ),
              ),
              SizedBox(height: 10 * scaleFactor),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                        ),
                        subtitle: Text(
                          'Tipo de lista: ${widget.lists[index].type}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'SFPro',
                            fontSize: 12 * scaleFactor,
                          ),
                        ),
                      ),
                      SizedBox(
                          height:
                              5 * scaleFactor), // Espacio entre los elementos
                      Text(
                        'La lista va a funcionar desde ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedStartDate ?? DateTime.now())} hasta ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedEndDate ?? DateTime.now())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(
                              255, 242, 187, 29), // Color del texto
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      if (widget.lists[index].addExtraTime)
                        Text(
                          'y con un extra de tiempo desde ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedStartExtraDate ?? DateTime.now())} hasta ${DateFormat('dd-MM-yyyy HH:mm').format(widget.lists[index].selectedEndExtraDate ?? DateTime.now())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(
                                255, 242, 187, 29), // Color del texto
                            fontFamily: 'SFPro',
                            fontSize: 14 * scaleFactor,
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10 * scaleFactor),
              if (widget.template == null)
                SwitchListTile(
                  title: Text(
                    'Guardar plantilla del Evento para próximos',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                  value: _guardarPlantilla,
                  onChanged: (newValue) {
                    setState(() {
                      _guardarPlantilla = newValue;
                    });
                  },
                  activeColor: Colors.green,
                ),
              SizedBox(height: 10 * scaleFactor),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLoading = true;
                          });
                          validateAndCreateEvent(context);
                        },
                  style: buttonPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? SizedBox(
                              width: 23 * scaleFactor,
                              height: 23 * scaleFactor,
                              child: CircularProgressIndicator(
                                strokeWidth: 2 * scaleFactor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              'Crear Evento',
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                fontFamily: 'SFPro',
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

  void validateAndCreateEvent(BuildContext context) {
    DateTime currentTime = DateTime.now();
    DateTime startTime = widget.startDateTime ?? currentTime;

    if (startTime.isBefore(currentTime.add(Duration(hours: 6)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La fecha de inicio debe ser al menos 6 horas después de la hora actual.',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14,
            ),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    createEvent(context);
  }

  Future<void> createEvent(BuildContext context) async {
    String uuid = Uuid().v4();

    try {
      // Subir la imagen y obtener su URL
      Reference ref = FirebaseStorage.instance.ref().child(
          'company_images/${widget.companyData['companyUsername']}/myEvents/$uuid.jpg');
      UploadTask uploadTask = ref.putFile(widget.image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Crear un documento para el evento
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['companyUsername'])
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
          .doc(widget.companyData['companyUsername'])
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
          if (listItem.addExtraTime == true) ...{
            'listStartExtraTime': listItem.selectedStartExtraDate,
            'listEndExtraTime': listItem.selectedEndExtraDate,
            'ticketExtraPrice': listItem.ticketExtraPrice,
          }
        });
      }

      if (_guardarPlantilla) {
        await saveTemplate();
      }

      // Mostrar el AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          double scaleFactor = MediaQuery.of(context).size.width / 375.0;
          return AlertDialog(
            title: Text(
              'Evento Creado',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 18 * scaleFactor,
              ),
            ),
            content: Text(
              'El evento ${widget.name} se ha creado correctamente.',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 16 * scaleFactor,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14 * scaleFactor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al crear el evento: $e',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14,
            ),
          ),
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
        .doc(widget.companyData['companyUsername'])
        .collection('eventTemplates')
        .get();

    if (templateSnapshot.size >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ya tienes 3 plantillas guardadas. Elimina una para poder guardar una nueva.',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14,
            ),
          ),
        ),
      );
      return;
    }

    // Guardar la plantilla
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyUsername'])
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
        content: Text(
          'Plantilla guardada exitosamente.',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
