import 'package:flutter/material.dart';
import 'step2AddEvent.dart';

class Step1AddEvent extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const Step1AddEvent({
    Key? key,
    required this.companyData,
  }) : super(key: key);

  @override
  State<Step1AddEvent> createState() => _Step1AddEventState();
}

class _Step1AddEventState extends State<Step1AddEvent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
      BuildContext context, bool isStartDateTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          if (isStartDateTime) {
            _startDateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          } else {
            _endDateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
        });
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
          "Paso 1: Datos principales del evento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color blanco para los iconos
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del evento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                  prefixIcon: Icon(Icons.description, color: Colors.grey),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la descripción del evento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDateTime(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha y Hora de Inicio',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 242, 187, 29),
                    ),
                    prefixIcon: Icon(Icons.event, color: Colors.grey),
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
                  child: Text(
                    _startDateTime != null
                        ? '${_startDateTime!.day}/${_startDateTime!.month}/${_startDateTime!.year} ${_startDateTime!.hour}:${_startDateTime!.minute.toString().padLeft(2, '0')}'
                        : 'Seleccione la fecha y hora de inicio',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDateTime(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha y Hora de Finalización',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 242, 187, 29),
                    ),
                    prefixIcon: Icon(Icons.event, color: Colors.grey),
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
                  child: Text(
                    _endDateTime != null
                        ? '${_endDateTime!.day}/${_endDateTime!.month}/${_endDateTime!.year} ${_endDateTime!.hour}:${_endDateTime!.minute.toString().padLeft(2, '0')}'
                        : 'Seleccione la fecha y hora de finalización',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _goToStep2(context);
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToStep2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Step2AddEvent(
          name: _nameController.text,
          description: _descriptionController.text,
          startDateTime: _startDateTime,
          endDateTime: _endDateTime,
        ),
      ),
    );
  }
}
