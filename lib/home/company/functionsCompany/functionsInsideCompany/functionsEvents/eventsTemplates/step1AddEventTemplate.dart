import 'package:app_listas/styles/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'step2AddEventTemplate.dart';
import 'package:unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';

class Step1AddEventTemplate extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final Map<String, dynamic>? template; // Añadir este parámetro opcional

  const Step1AddEventTemplate({
    Key? key,
    required this.companyData,
    this.template, // Aceptar este parámetro opcional
  }) : super(key: key);

  @override
  _Step1AddEventTemplateState createState() => _Step1AddEventTemplateState();
}

class _Step1AddEventTemplateState extends State<Step1AddEventTemplate> {
  late TextEditingController _nameController;
  late TextEditingController _ticketValueController;
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.template?['eventName'] ?? '',
    );
    _ticketValueController = TextEditingController(
      text: widget.template?['eventTicketValue']?.toString() ?? '',
    );
    _startDateTime = widget.template?['eventStartTime']?.toDate();
    _endDateTime = widget.template?['eventEndTime']?.toDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Paso 1: Detalles del Evento',
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del Evento',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ingrese el nombre del evento',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Valor de la Entrada',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            TextField(
              controller: _ticketValueController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ingrese el valor de la entrada',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              'Fecha y Hora de Inicio',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDateTime ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                        _startDateTime ?? DateTime.now()),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _startDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(
                _startDateTime != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(_startDateTime!)
                    : 'Seleccionar fecha y hora',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Fecha y Hora de Fin',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDateTime ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _endDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(
                _endDateTime != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(_endDateTime!)
                    : 'Seleccionar fecha y hora',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Step2AddEventTemplate(
                      name: _nameController.text,
                      ticketValue:
                          double.tryParse(_ticketValueController.text) ?? 0.0,
                      startDateTime: _startDateTime,
                      endDateTime: _endDateTime,
                      companyData: widget.companyData,
                      template: widget.template,
                    ),
                  ),
                );
              },
              style: buttonPrimary,
              child: Text(
                'Siguiente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
