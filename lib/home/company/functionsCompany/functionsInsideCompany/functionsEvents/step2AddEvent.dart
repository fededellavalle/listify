import 'package:app_listas/styles/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListItem {
  String name;
  String type;
  TimeOfDay selectedTime;
  bool addExtraTime;

  ListItem({
    required this.name,
    required this.type,
    required this.selectedTime,
    required this.addExtraTime,
  });
}

class Step2AddEvent extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const Step2AddEvent({
    Key? key,
    required this.name,
    required this.ticketValue,
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
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final _formKey = GlobalKey<FormState>();
  String _selectedListType = 'Lista de Asistencia';
  List<String> _listTypes = [
    'Lista de Asistencia',
    'Lista de Anotación',
  ];
  List<ListItem> _lists = [
    ListItem(
      name: 'Invitados',
      type: 'Lista de Asistencia',
      selectedTime: TimeOfDay.now(),
      addExtraTime: false,
    ),
  ];

  bool _addExtraTime = false;

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

    _availableDates = _generateAvailableTimeSlots();
    _selectedDate = _availableDates.isNotEmpty ? _availableDates.first : null;
  }

  List<DateTime> _generateAvailableTimeSlots() {
    List<DateTime> timeSlots = [];
    int bandera = 0;

    // Obtener la hora de inicio y la hora de finalización del evento
    int startHour = _eventStartDate.hour;
    int startMinute = _eventStartDate.minute;
    int endHour = _eventEndDate.hour;
    int endMinute = _eventEndDate.minute;
    int endHour2 = _eventEndDate.hour;
    int endMinute2 = _eventEndDate.minute;

    if (startHour > endHour) {
      endHour += 24;
    }

    timeSlots.add(DateTime(_eventStartDate.year, _eventStartDate.month,
        _eventStartDate.day, startHour, startMinute));

    if (startMinute >= 0 && startMinute <= 15) {
      startMinute = 0;
    } else if (startMinute > 15 && startMinute <= 30) {
      startMinute = 15;
    } else if (startMinute > 30 && startMinute <= 45) {
      startMinute = 30;
    } else if (startMinute > 45 && startMinute <= 59) {
      startMinute = 45;
    }

    if (endMinute >= 0 && endMinute <= 15) {
      endMinute = 0;
    } else if (endMinute > 15 && endMinute <= 30) {
      endMinute = 15;
    } else if (endMinute > 30 && endMinute <= 45) {
      endMinute = 30;
    } else if (endMinute > 45 && endMinute <= 59) {
      endMinute = 45;
    }
    // Calcular el número de intervalos de 15 minutos entre la hora de inicio y la hora de finalización
    int totalMinutes =
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
    int numSlots = (totalMinutes / 15).ceil();

    startMinute += 15;

    // Generar los intervalos de tiempo de 15 minutos
    for (int i = 0; i < numSlots; i++) {
      int minutesToAdd = i * 15;
      int slotHour = startHour + (startMinute + minutesToAdd) ~/ 60;
      int slotMinute = (startMinute + minutesToAdd) % 60;

      if (_eventStartDate.day != _eventEndDate.day) {
        if (slotHour == 00) {
          bandera = 1;
        }
        if (bandera == 1) {
          timeSlots.add(DateTime(_eventEndDate.year, _eventEndDate.month,
              _eventEndDate.day, slotHour, slotMinute));
        } else {
          timeSlots.add(DateTime(_eventStartDate.year, _eventStartDate.month,
              _eventStartDate.day, slotHour, slotMinute));
        }
      } else {
        timeSlots.add(DateTime(_eventStartDate.year, _eventStartDate.month,
            _eventStartDate.day, slotHour, slotMinute));
      }
    }
    timeSlots.add(DateTime(_eventEndDate.year, _eventEndDate.month,
        _eventEndDate.day, endHour2, endMinute2));

    print(timeSlots);

    return timeSlots;
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
              Row(
                children: [
                  Icon(
                    Icons.info_outline, // El icono que deseas usar
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 5), // Espacio entre el icono y el texto
                  Text(
                    _listTypeSummary,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _createList(_selectedListType, _listNameController.text);
                },
                style: buttonPrimary,
                child: Text(
                  'Crear Lista',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Listas Creadas:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
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
      case 'Lista de Asistencia':
        return 'Para anotar nombres, dar asistencia al evento.';
      case 'Lista de Anotación':
        return 'Para tomar notas o registrar información adicional.';
      default:
        return '';
    }
  }

  void _createList(String listType, String listName) {
    setState(() {
      _lists.add(ListItem(
          name: listName,
          type: listType,
          selectedTime: TimeOfDay.now(),
          addExtraTime: false));
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
        String newName = _lists[index].name;
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
      backgroundColor: Colors.grey.shade900,
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('Desde'),
                      ),
                      SizedBox(width: 10), // Espacio entre los elementos
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<DateTime>(
                          value: _selectedStartDate,
                          items: _availableDates.map((DateTime date) {
                            return DropdownMenuItem<DateTime>(
                              value: date,
                              child: Text(
                                DateFormat('HH:mm')
                                    .format(date), // Formato de hora y minutos
                              ),
                            );
                          }).toList(),
                          onChanged: (DateTime? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStartDate = newValue;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Espacio entre los elementos
                      Expanded(
                        flex: 1,
                        child: Text('Hasta'),
                      ),
                      SizedBox(width: 10), // Espacio entre los elementos
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<DateTime>(
                          value: _selectedEndDate,
                          items: _availableDates.map((DateTime date) {
                            return DropdownMenuItem<DateTime>(
                              value: date,
                              child: Text(
                                DateFormat('HH:mm')
                                    .format(date), // Formato de hora y minutos
                              ),
                            );
                          }).toList(),
                          onChanged: (DateTime? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedEndDate = newValue;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: _lists[index].addExtraTime != true
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _lists[index].addExtraTime = true;
                              });
                            },
                            child: Text('Agregar nuevo rango horario'))
                        : Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text('Desde'),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<DateTime>(
                                  value: _selectedStartDate,
                                  items: _availableDates.map((DateTime date) {
                                    return DropdownMenuItem<DateTime>(
                                      value: date,
                                      child: Text(
                                        DateFormat('HH:mm').format(
                                            date), // Formato de hora y minutos
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (DateTime? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedStartDate = newValue;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 20), // Espacio entre los elementos
                              Expanded(
                                flex: 1,
                                child: Text('Hasta'),
                              ),
                              SizedBox(
                                  width: 10), // Espacio entre los elementos
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<DateTime>(
                                  value: _selectedEndDate,
                                  items: _availableDates.map((DateTime date) {
                                    return DropdownMenuItem<DateTime>(
                                      value: date,
                                      child: Text(
                                        DateFormat('HH:mm').format(
                                            date), // Formato de hora y minutos
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (DateTime? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedEndDate = newValue;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
