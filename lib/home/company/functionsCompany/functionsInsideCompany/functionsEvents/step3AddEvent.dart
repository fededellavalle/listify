import 'package:flutter/material.dart';
import 'list_item.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class Step3AddEvent extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final List<ListItem> lists;
  File? image;

  Step3AddEvent({
    Key? key,
    required this.name,
    required this.ticketValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.lists,
    required this.image,
  }) : super(key: key);

  @override
  State<Step3AddEvent> createState() => _Step3AddEventState();
}

class _Step3AddEventState extends State<Step3AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Detalles del Evento'),
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
                        'Nombre del Evento: ${widget.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Valor de la Entrada: \$${widget.ticketValue.toStringAsFixed(2)}',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha de Inicio: ${widget.startDateTime?.toString() ?? 'No especificada'}',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha de Fin: ${widget.endDateTime?.toString() ?? 'No especificada'}',
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
                        'La lista va a funcionar desde ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.lists[index].selectedStartDate ?? DateTime.now())} hasta ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.lists[index].selectedEndDate ?? DateTime.now())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade400, // Color del texto
                        ),
                      ),
                      if (widget.lists[index]
                          .addExtraTime) // Sin llaves para una única instrucción
                        Text(
                          'y con un extra de tiempo desde ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.lists[index].selectedStartExtraDate ?? DateTime.now())} hasta ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.lists[index].selectedEndExtraDate ?? DateTime.now())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade400, // Color del texto
                          ),
                        ),
                      Divider(), // Línea divisoria opcional
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
