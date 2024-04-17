import 'package:flutter/material.dart';

class ListItem {
  String name;
  String type;
  TimeOfDay selectedTime;

  ListItem({
    required this.name,
    required this.type,
    required this.selectedTime,
  });
}

class Step2AddEvent extends StatefulWidget {
  final String name;
  final String description;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const Step2AddEvent({
    Key? key,
    required this.name,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
  }) : super(key: key);

  @override
  _Step2AddEventState createState() => _Step2AddEventState();
}

class _Step2AddEventState extends State<Step2AddEvent> {
  DateTime _eventStartDate = DateTime.now();
  DateTime _eventEndDate = DateTime.now();
  List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();
  String _selectedListType = 'Lista de Asistencia no Paga';
  List<String> _listTypes = [
    'Lista de Asistencia no Paga',
    'Lista de Asistencia Paga',
    'Lista de Anotación',
  ];
  List<ListItem> _lists = [
    ListItem(
      name: 'Invitados',
      type: 'Lista de Asistencia no Paga',
      selectedTime: TimeOfDay.now(),
    ),
  ]; // Lista por default

  late TextEditingController _listNameController;
  String _listTypeSummary = ''; // Resumen del tipo de lista seleccionado

  @override
  void initState() {
    super.initState();
    _listNameController = TextEditingController();
    _initializeDates();
  }

  @override
  void dispose() {
    _listNameController
        .dispose(); // Liberar recursos del controlador al finalizar
    super.dispose();
  }

  void _initializeDates() {
    _eventStartDate = widget.startDateTime ?? DateTime.now();
    _eventEndDate = widget.endDateTime ?? DateTime.now();

    // Separar fecha y hora del inicio del evento
    int startYear = _eventStartDate.year;
    int startMonth = _eventStartDate.month;
    int startDay = _eventStartDate.day;
    int startHour = _eventStartDate.hour;
    int startMinute = _eventStartDate.minute;
    int startSecond = _eventStartDate.second;

    // Separar fecha y hora del final del evento
    int endYear = _eventEndDate.year;
    int endMonth = _eventEndDate.month;
    int endDay = _eventEndDate.day;
    int endHour = _eventEndDate.hour;
    int endMinute = _eventEndDate.minute;
    int endSecond = _eventEndDate.second;

    print(
        'Inicio del evento: $startYear-$startMonth-$startDay $startHour:$startMinute:$startSecond');
    print(
        'Fin del evento: $endYear-$endMonth-$endDay $endHour:$endMinute:$endSecond');

    _availableDates = _generateAvailableDates();
    _selectedDate = _availableDates.isNotEmpty ? _availableDates.first : null;
  }

  List<DateTime> _generateAvailableDates() {
    List<DateTime> dates = [];

    // Separar fecha y hora del inicio del evento
    int startYear = _eventStartDate.year;
    int startMonth = _eventStartDate.month;
    int startDay = _eventStartDate.day;

    // Separar fecha y hora del final del evento
    int endYear = _eventEndDate.year;
    int endMonth = _eventEndDate.month;
    int endDay = _eventEndDate.day;

    // Generar fechas dentro del rango
    for (int year = startYear; year <= endYear; year++) {
      for (int month = (year == startYear ? startMonth : 1);
          month <= (year == endYear ? endMonth : 12);
          month++) {
        int daysInMonth = DateTime(year, month + 1, 0).day;
        int start = (year == startYear && month == startMonth) ? startDay : 1;
        int end = (year == endYear && month == endMonth) ? endDay : daysInMonth;

        // Añadir la fecha de inicio si es el mismo día que la fecha de finalización
        if (year == endYear && month == endMonth && start == end) {
          dates.add(DateTime(year, month, start));
        }

        for (int day = start; day <= end; day++) {
          DateTime date = DateTime(year, month, day);
          if (date.isAfter(_eventStartDate) &&
                  date.isBefore(_eventEndDate.add(Duration(days: 1))) ||
              (year == startYear && month == startMonth && day == startDay)) {
            dates.add(date);
          }
        }
      }
    }

    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Paso 2: Configuracion de Listas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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
                controller: _listNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Lista',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
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
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedListType,
                items: _listTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedListType = newValue;
                      _listTypeSummary = _getListTypeSummary(newValue);
                    });
                  }
                },
                dropdownColor: Colors.grey.shade800,
                decoration: InputDecoration(
                  labelText: 'Tipo de Lista',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
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
              ),
              SizedBox(height: 8),
              Text(
                _listTypeSummary,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _createList(_selectedListType, _listNameController.text);
                },
                child: Text('Guardar'),
              ),
              SizedBox(height: 16),
              Text(
                'Listas Creadas:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _lists[index].name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(_lists[index].type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.yellow,
                          ),
                          onPressed: () {
                            _editList(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _configureList(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteList(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getListTypeSummary(String type) {
    switch (type) {
      case 'Lista de Asistencia no Paga':
        return 'Para anotar nombres, dar asistencia al evento.';
      case 'Lista de Asistencia Paga':
        return 'Para anotar nombres y gestionar pagos de asistencia.';
      case 'Lista de Anotación':
        return 'Para tomar notas o registrar información adicional.';
      default:
        return '';
    }
  }

  void _createList(String listType, String listName) {
    setState(() {
      _lists.add(ListItem(
          name: listName, type: listType, selectedTime: TimeOfDay.now()));
      _listNameController.clear();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lista Creada'),
          content: Text('Se ha creado la lista: $listName'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _editList(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName =
            _lists[index].name; // Acceder al campo 'name' del objeto
        return AlertDialog(
          title: Text('Editar Lista'),
          content: TextFormField(
            initialValue: newName,
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _lists[index].name =
                      newName; // Actualizar el campo 'name' del objeto
                });
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _configureList(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Configurar Lista',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Configuración de la lista ${_lists[index].name}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hora seleccionada: ${_lists[index].selectedTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<DateTime>(
                    value: _selectedDate,
                    items:
                        _availableDates.toSet().toList().map((DateTime date) {
                      return DropdownMenuItem<DateTime>(
                        value: date,
                        child: Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (DateTime? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDate = newValue;
                        });
                      }
                    },
                    dropdownColor: Colors.grey.shade800,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Fecha',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 242, 187, 29),
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
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _lists[index].selectedTime,
                      );
                      if (selectedTime != null) {
                        setState(() {
                          _lists[index].selectedTime = selectedTime;
                        });
                      }
                    },
                    child: Text('Seleccionar Hora'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteList(int index) {
    setState(() {
      _lists.removeAt(index);
    });
  }
}
