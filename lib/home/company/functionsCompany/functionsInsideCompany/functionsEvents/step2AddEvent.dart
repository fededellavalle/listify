import 'package:app_listas/styles/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'step3AddEvent.dart';
import 'list_item.dart';
import 'dart:io';

// ignore: must_be_immutable
class Step2AddEvent extends StatefulWidget {
  final String name;
  final double ticketValue;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  File? image;
  final Map<String, dynamic> companyData;
  final Map<String, dynamic>? template;

  Step2AddEvent({
    Key? key,
    required this.name,
    required this.ticketValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.image,
    required this.companyData,
    required this.template,
  }) : super(key: key);

  @override
  _Step2AddEventState createState() => _Step2AddEventState();
}

class _Step2AddEventState extends State<Step2AddEvent> {
  DateTime _eventStartDate = DateTime.now();
  DateTime _eventEndDate = DateTime.now();
  List<DateTime> _availableDates = [];
  final _formKey = GlobalKey<FormState>();
  String _selectedListType = 'Lista de Asistencia';
  List<String> _listTypes = [
    'Lista de Asistencia',
    'Lista de Anotación',
  ];
  late List<ListItem> _lists;

  late TextEditingController _listNameController;
  late TextEditingController _ticketPriceController;
  late TextEditingController _ticketExtraPriceController;
  String _listTypeSummary = 'Para anotar nombres, dar asistencia al evento.';

  @override
  void initState() {
    super.initState();
    _listNameController = TextEditingController();
    _ticketPriceController = TextEditingController();
    _ticketExtraPriceController = TextEditingController();
    _initializeDates();

    if (widget.template == null) {
      _lists = [
        ListItem(
          name: 'Invitados',
          type: 'Lista de Asistencia',
          addExtraTime: false,
          selectedStartDate: _availableDates.first,
          selectedEndDate: _availableDates.last,
          ticketPrice: widget.ticketValue,
          selectedStartExtraDate: null,
          selectedEndExtraDate: null,
          ticketExtraPrice: null,
          allowSublists: false,
        ),
      ];
    } else {
      _lists = [
        for (var list in widget.template!['lists'])
          ListItem(
            name: list['listName'],
            type: list['listType'],
            addExtraTime: list['addExtraTime'],
            selectedStartDate: _availableDates.first,
            selectedEndDate: _availableDates.last,
            ticketPrice: (list['ticketPrice'] as num).toDouble(),
            selectedStartExtraDate: list['selectedStartExtraDate'] != null
                ? _availableDates.first
                : null,
            selectedEndExtraDate: list['selectedEndExtraDate'] != null
                ? _availableDates.last
                : null,
            ticketExtraPrice: list['ticketExtraPrice'] != null
                ? (list['ticketExtraPrice'] as num).toDouble()
                : null,
            allowSublists: list['allowSublists'] ?? false,
          ),
      ];
    }

    print(_lists);
  }

  @override
  void dispose() {
    _listNameController.dispose();
    _ticketPriceController.dispose();
    _ticketExtraPriceController.dispose();
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
          if (!timeSlots.contains(DateTime(_eventEndDate.year,
              _eventEndDate.month, _eventEndDate.day, slotHour, slotMinute))) {
            timeSlots.add(DateTime(_eventEndDate.year, _eventEndDate.month,
                _eventEndDate.day, slotHour, slotMinute));
            print('No contiene');
          } else {
            print('si Contiene');
          }
        } else {
          if (!timeSlots.contains(DateTime(
              _eventStartDate.year,
              _eventStartDate.month,
              _eventStartDate.day,
              slotHour,
              slotMinute))) {
            timeSlots.add(DateTime(_eventStartDate.year, _eventStartDate.month,
                _eventStartDate.day, slotHour, slotMinute));
            print('No contiene');
          } else {
            print('si Contiene');
          }
        }
      } else {
        if (!timeSlots.contains(DateTime(
            _eventStartDate.year,
            _eventStartDate.month,
            _eventStartDate.day,
            slotHour,
            slotMinute))) {
          timeSlots.add(DateTime(_eventStartDate.year, _eventStartDate.month,
              _eventStartDate.day, slotHour, slotMinute));
          print('No contiene');
        } else {
          print('si Contiene');
        }
      }
    }
    if (!timeSlots.contains(DateTime(_eventEndDate.year, _eventEndDate.month,
        _eventEndDate.day, endHour2, endMinute2))) {
      timeSlots.add(DateTime(_eventEndDate.year, _eventEndDate.month,
          _eventEndDate.day, endHour2, endMinute2));
      print('No contiene');
    } else {
      print('si Contiene');
    }

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
                style: TextStyle(color: Colors.white),
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
                    color: Colors.blue,
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
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _goToStep3(context);
                },
                style: buttonPrimary,
                child: Text(
                  'Siguiente paso',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info, // El icono que deseas usar
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 5), // Espacio entre el icono y el texto
                  Expanded(
                    child: Text(
                      'El evento al crearse va a estar deshabilitado, al momento de habilitarlo se van a poder empezar a escribir en las listas.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              const Row(
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
              const SizedBox(height: 3),
              const Text(
                'Puedes crear hasta 8 listas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
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

  int _maxLists = 8;

  void _createList(String listType, String listName) {
    if (_lists.length >= _maxLists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error al Crear Lista'),
            content: Text('Se ha alcanzado el máximo de listas permitidas.'),
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
    } else {
      if (listName.isNotEmpty) {
        // Verifica que el campo no esté vacío
        setState(() {
          _lists.add(ListItem(
            name: listName,
            type: listType,
            addExtraTime: false,
            selectedStartDate: _availableDates.first,
            selectedEndDate: _availableDates.last,
            ticketPrice: widget.ticketValue,
            selectedStartExtraDate: null,
            selectedEndExtraDate: null,
            ticketExtraPrice: widget.ticketValue,
            allowSublists: false,
          ));
          _listNameController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se ha creado la lista: $listName'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Aceptar',
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tienes que ponerle nombre a la lista'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Aceptar',
              onPressed: () {},
            ),
          ),
        );
      }
    }
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
    _ticketPriceController.text = _lists[index].ticketPrice.toString();
    _ticketExtraPriceController.text = "";
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FocusNode _focusNode = FocusNode();

    showModalBottomSheet(
      backgroundColor: Colors.grey
          .shade900, // Fondo transparente para mostrar el Scaffold correctamente
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors
              .transparent, // Fondo transparente para mostrar el BottomSheet correctamente
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!_focusNode.hasFocus) {
                    Navigator.pop(context);
                  }
                },
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 100),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuración de la lista ${_lists[index].name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Asigne los horarios donde va a funcionar la lista',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Desde',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child:
                                            DropdownButtonFormField<DateTime>(
                                          value:
                                              _lists[index].selectedStartDate,
                                          items: _availableDates
                                              .map((DateTime date) {
                                            return DropdownMenuItem<DateTime>(
                                              value: date,
                                              child: Text(
                                                DateFormat('HH:mm')
                                                    .format(date),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (DateTime? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _lists[index]
                                                        .selectedStartDate =
                                                    newValue;
                                              });
                                            }
                                          },
                                          dropdownColor: Colors.grey.shade800,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Hasta',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child:
                                            DropdownButtonFormField<DateTime>(
                                          value: _lists[index].selectedEndDate,
                                          items: _availableDates
                                              .map((DateTime date) {
                                            return DropdownMenuItem<DateTime>(
                                              value: date,
                                              child: Text(
                                                DateFormat('HH:mm')
                                                    .format(date),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (DateTime? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _lists[index].selectedEndDate =
                                                    newValue;
                                              });
                                            }
                                          },
                                          dropdownColor: Colors.grey.shade800,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        'con el valor de la entrada:',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _ticketPriceController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Ingrese el valor aquí',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(
                                                  r'^\d{0,8}([.,]\d{0,2})?$'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            double? parsedValue =
                                                double.tryParse(value);
                                            if (parsedValue != null) {
                                              _lists[index].ticketPrice =
                                                  parsedValue;
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Divider(
                                            color: Colors.white,
                                            thickness: 1.0,
                                          ),
                                          IgnorePointer(
                                            ignoring:
                                                !_lists[index].addExtraTime,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Desde',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  flex: 2,
                                                  child:
                                                      DropdownButtonFormField<
                                                          DateTime>(
                                                    value: _lists[index]
                                                        .selectedStartExtraDate,
                                                    items: _availableDates
                                                        .map((DateTime date) {
                                                      return DropdownMenuItem<
                                                          DateTime>(
                                                        value: date,
                                                        child: Text(
                                                          DateFormat('HH:mm')
                                                              .format(date),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: _lists[index]
                                                            .addExtraTime
                                                        ? (DateTime? newValue) {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                _lists[index]
                                                                        .selectedStartExtraDate =
                                                                    newValue;
                                                              });
                                                            }
                                                          }
                                                        : null,
                                                    dropdownColor:
                                                        Colors.grey.shade800,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Hasta',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  flex: 2,
                                                  child:
                                                      DropdownButtonFormField<
                                                          DateTime>(
                                                    value: _lists[index]
                                                        .selectedEndExtraDate,
                                                    items: _availableDates
                                                        .map((DateTime date) {
                                                      return DropdownMenuItem<
                                                          DateTime>(
                                                        value: date,
                                                        child: Text(
                                                          DateFormat('HH:mm')
                                                              .format(date),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: _lists[index]
                                                            .addExtraTime
                                                        ? (DateTime? newValue) {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                _lists[index]
                                                                        .selectedEndExtraDate =
                                                                    newValue;
                                                              });
                                                            }
                                                          }
                                                        : null,
                                                    dropdownColor:
                                                        Colors.grey.shade800,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          IgnorePointer(
                                            ignoring:
                                                !_lists[index].addExtraTime,
                                            child: Row(
                                              children: [
                                                Text(
                                                  'con el valor de la entrada:',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _ticketExtraPriceController,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText:
                                                          'Ingrese el valor aquí',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                            r'^\d{0,8}([.,]\d{0,2})?$'),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      double? parsedValue =
                                                          double.tryParse(
                                                              value);
                                                      if (parsedValue != null) {
                                                        _lists[index]
                                                                .ticketPrice =
                                                            parsedValue;
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!_lists[index].addExtraTime)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.grey.shade900
                                                .withOpacity(0.5),
                                            child: Center(
                                              child: Icon(
                                                Icons.close,
                                                size: 100,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_lists[index].addExtraTime !=
                                            true) {
                                          // Lógica cuando el botón se presiona para agregar un rango horario extra
                                          _lists[index].addExtraTime = true;
                                          _lists[index].selectedStartExtraDate =
                                              _lists[index].selectedEndDate;
                                          _lists[index].selectedEndExtraDate =
                                              _availableDates.last;
                                          _lists[index].ticketExtraPrice =
                                              widget.ticketValue;
                                          _ticketExtraPriceController.text =
                                              _lists[index]
                                                  .ticketExtraPrice
                                                  .toString();
                                        } else {
                                          // Lógica cuando el botón se presiona para cancelar el rango horario extra
                                          _lists[index].addExtraTime = false;
                                          _lists[index].selectedStartExtraDate =
                                              null;
                                          _lists[index].selectedEndExtraDate =
                                              null;
                                          _lists[index].ticketExtraPrice = null;
                                          _ticketExtraPriceController.text = "";
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        EdgeInsets.all(
                                            10), // Ajusta el padding del botón según sea necesario
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              _lists[index].addExtraTime != true
                                                  ? Colors.green.shade300
                                                  : Colors.red.shade300),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors.grey
                                              .shade900), // Cambia el color de fondo del botón
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _lists[index].addExtraTime != true
                                              ? Icons.add
                                              : Icons.delete,
                                        ), // Icono de suma
                                        SizedBox(
                                            width:
                                                5), // Espacio entre el icono y el texto
                                        Text(
                                          _lists[index].addExtraTime != true
                                              ? 'Agregar nuevo rango horario'
                                              : 'Cancelar rango horario extra',
                                        ),
                                      ],
                                    ),
                                  ),
                                  CheckboxListTile(
                                    value: _lists[index].allowSublists,
                                    onChanged: (bool? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _lists[index].allowSublists =
                                              newValue;
                                        });
                                      }
                                    },
                                    activeColor: Colors
                                        .blue, // Color cuando el Checkbox está seleccionado
                                    checkColor: Colors
                                        .white, // Color del check dentro del Checkbox
                                    controlAffinity: ListTileControlAffinity
                                        .leading, // Coloca el Checkbox a la izquierda del texto
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Permitir Sublistas dentro de la Lista',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  16, // Tamaño de fuente del texto del Checkbox
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                  }
                                },
                                style: buttonPrimary,
                                child: Text('Confirmar Configuracion'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _deleteList(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas eliminar esta lista?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el AlertDialog
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _lists.removeAt(index); // Elimina la lista
                });
                Navigator.pop(context); // Cierra el AlertDialog
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _goToStep3(BuildContext context) {
    if (_lists.length != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step3AddEvent(
            name: widget.name,
            ticketValue: widget.ticketValue,
            startDateTime: widget.startDateTime,
            endDateTime: widget.endDateTime,
            lists: _lists,
            image: widget.image,
            companyData: widget.companyData,
            template: widget.template,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, ingrese alguna lista.',
          ),
        ),
      );
    }
  }
}
