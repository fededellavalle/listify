import 'package:flutter/material.dart';
import 'list_item.dart';

class Step3AddEvent extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final List<ListItem> lists;

  const Step3AddEvent({
    Key? key,
    required this.name,
    required this.ticketValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.lists,
  }) : super(key: key);

  @override
  State<Step3AddEvent> createState() => _Step3AddEventState();
}

class _Step3AddEventState extends State<Step3AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Evento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre del Evento: ${widget.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                  'Valor de la Entrada: \$${widget.ticketValue.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Text(
                  'Fecha de Inicio: ${widget.startDateTime?.toString() ?? 'No especificada'}'),
              SizedBox(height: 10),
              Text(
                  'Fecha de Fin: ${widget.endDateTime?.toString() ?? 'No especificada'}'),
              SizedBox(height: 20),
              Text(
                'Listas Disponibles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.lists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Nombre: ${widget.lists[index].name}'),
                    subtitle: Text('Descripción: ${widget.lists[index].type}'),
                    // Agrega más información de la lista si es necesario
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
