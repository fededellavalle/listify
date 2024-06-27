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
        'name': widget.name,
        'ticketValue': widget.ticketValue,
        'startDateTime': widget.startDateTime,
        'endDateTime': widget.endDateTime,
        'lists': widget.lists
            .map((list) => {
                  'name': list.name,
                  'type': list.type,
                  'selectedStartDate': list.selectedStartDate,
                  'selectedEndDate': list.selectedEndDate,
                  'addExtraTime': list.addExtraTime,
                  'selectedStartExtraDate': list.selectedStartExtraDate,
                  'selectedEndExtraDate': list.selectedEndExtraDate,
                })
            .toList(),
        'image': imageUrl,
      });

      // Guardar la plantilla si se seleccionó la opción
      if (_guardarPlantilla) {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyData['companyId'])
            .collection('eventTemplates')
            .doc(uuid)
            .set({
          'name': widget.name,
          'ticketValue': widget.ticketValue,
          'startDateTime': widget.startDateTime,
          'endDateTime': widget.endDateTime,
          'lists': widget.lists
              .map((list) => {
                    'name': list.name,
                    'type': list.type,
                    'selectedStartDate': list.selectedStartDate,
                    'selectedEndDate': list.selectedEndDate,
                    'addExtraTime': list.addExtraTime,
                    'selectedStartExtraDate': list.selectedStartExtraDate,
                    'selectedEndExtraDate': list.selectedEndExtraDate,
                  })
              .toList(),
          'image': imageUrl,
        });
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Evento creado exitosamente.',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14,
            ),
          ),
        ),
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
}
