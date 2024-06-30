import 'package:app_listas/styles/button.dart';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'step3AddEvent.dart';
import 'list_item.dart';
import 'dart:io';

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

    _availableDates = _generateAvailableTimeSlots();
  }

  List<DateTime> _generateAvailableTimeSlots() {
    List<DateTime> timeSlots = [];
    int bandera = 0;

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

    int totalMinutes =
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
    int numSlots = (totalMinutes / 15).ceil();

    startMinute += 15;

    for (int i = 0; i < numSlots; i++) {
      int minutesToAdd = i * 15;
      int slotHour = startHour + (startMinute + minutesToAdd) ~/ 60;
      int slotMinute = (startMinute + minutesToAdd) % 60;

      if (_eventStartDate.day != _eventEndDate.day) {
        if (slotHour == 0) {
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
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Paso 2: Configuración de Listas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * scaleFactor,
            fontFamily: 'SFPro',
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * scaleFactor),
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
                    color: white,
                    fontFamily: 'SFPro',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBluePrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBlueSecondary,
                    ),
                  ),
                ),
                style: TextStyle(color: Colors.white, fontFamily: 'SFPro'),
              ),
              SizedBox(height: 16 * scaleFactor),
              DropdownButtonFormField<String>(
                value: _selectedListType,
                items: _listTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SFPro',
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
                    color: white,
                    fontFamily: 'SFPro',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBluePrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                    borderSide: BorderSide(
                      color: skyBlueSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8 * scaleFactor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20 * scaleFactor,
                      ),
                      SizedBox(width: 5 * scaleFactor),
                      Expanded(
                        child: Text(
                          _listTypeSummary,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14 * scaleFactor,
                            fontFamily: 'SFPro',
                          ),
                          overflow: TextOverflow
                              .visible, // Permitir que el texto se envuelva
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8 * scaleFactor),
              CupertinoButton(
                onPressed: () {
                  _createList(
                      _selectedListType, _listNameController.text, scaleFactor);
                },
                color: skyBluePrimary,
                child: Text(
                  'Crear Lista',
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8 * scaleFactor),
              CupertinoButton(
                onPressed: () {
                  _goToStep3(context);
                },
                color: skyBluePrimary,
                child: Text(
                  'Siguiente paso',
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    fontFamily: 'SFPro',
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8 * scaleFactor),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey,
                    size: 20 * scaleFactor,
                  ),
                  SizedBox(width: 5 * scaleFactor),
                  Expanded(
                    child: Text(
                      'El evento al crearse va a estar deshabilitado, al momento de habilitarlo se van a poder empezar a escribir en las listas.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scaleFactor),
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
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'SFPro'),
                    ),
                    subtitle: Text(
                      _lists[index].type,
                      style: TextStyle(color: Colors.grey, fontFamily: 'SFPro'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.yellow,
                            size: 20 * scaleFactor,
                          ),
                          onPressed: () {
                            _editList(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.blue,
                            size: 20 * scaleFactor,
                          ),
                          onPressed: () {
                            _configureList(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20 * scaleFactor,
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

  void _createList(String listType, String listName, double scaleFactor) {
    if (_lists.length >= _maxLists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          double scaleFactor = MediaQuery.of(context).size.width / 375.0;
          return AlertDialog(
            title: Text(
              'Error al Crear Lista',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 18 * scaleFactor,
              ),
            ),
            content: Text(
              'Se ha alcanzado el máximo de listas permitidas.',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 16 * scaleFactor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
    } else {
      if (listName.isNotEmpty) {
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
            content: Text(
              'Se ha creado la lista: $listName',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Aceptar',
              onPressed: () {},
              textColor: Colors.white,
              disabledTextColor: Colors.grey,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tienes que ponerle nombre a la lista',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Aceptar',
              onPressed: () {},
              textColor: Colors.white,
              disabledTextColor: Colors.grey,
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
        double scaleFactor = MediaQuery.of(context).size.width / 375.0;
        String newName = _lists[index].name;
        String newType = _lists[index].type;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Lista',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 18 * scaleFactor,
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                TextFormField(
                  initialValue: newName,
                  onChanged: (value) {
                    newName = value;
                  },
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                DropdownButtonFormField<String>(
                  value: newType,
                  items: _listTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      newType = newValue;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Tipo de Lista',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SFPro',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                      borderSide: BorderSide(
                        color: skyBluePrimary,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                      borderSide: BorderSide(
                        color: skyBlueSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20 * scaleFactor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * scaleFactor),
                    TextButton(
                      onPressed: () {
                        if (newName.trim().isEmpty) {
                          // Mostrar mensaje de error si el campo está vacío
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'El nombre no puede estar vacío.',
                                style: TextStyle(fontFamily: 'SFPro'),
                              ),
                            ),
                          );
                        } else if (_lists.any((list) =>
                            list.name == newName && list != _lists[index])) {
                          // Mostrar mensaje de error si ya existe una lista con el mismo nombre
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ya existe una lista con ese nombre.',
                                style: TextStyle(fontFamily: 'SFPro'),
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            _lists[index].name =
                                newName; // Actualizar el campo 'name' del objeto
                            _lists[index].type =
                                newType; // Actualizar el campo 'type' del objeto
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      backgroundColor: Colors.grey.shade900,
      context: context,
      builder: (BuildContext context) {
        double scaleFactor = MediaQuery.of(context).size.width / 375.0;
        return Scaffold(
          backgroundColor: Colors.transparent,
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
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SFPro',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            Text(
                              'Asigne los horarios donde va a funcionar la lista',
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            SizedBox(height: 8 * scaleFactor),
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
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10 * scaleFactor),
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
                                                  fontFamily: 'SFPro',
                                                  fontSize: 14 * scaleFactor,
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
                                                if (_lists[index]
                                                            .selectedEndDate !=
                                                        null &&
                                                    _lists[index]
                                                        .selectedEndDate!
                                                        .isBefore(newValue)) {
                                                  _lists[index]
                                                          .selectedEndDate =
                                                      _availableDates.last;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'La hora de fin no puede ser anterior a la hora de inicio.'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              });
                                            }
                                          },
                                          dropdownColor: Colors.grey.shade800,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10 * scaleFactor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20 * scaleFactor),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Hasta',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10 * scaleFactor),
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
                                                  fontFamily: 'SFPro',
                                                  fontSize: 14 * scaleFactor,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (DateTime? newValue) {
                                            if (newValue != null) {
                                              if (_lists[index]
                                                          .selectedStartDate !=
                                                      null &&
                                                  newValue.isBefore(_lists[
                                                          index]
                                                      .selectedStartDate!)) {
                                                // Mostrar un mensaje de error usando un SnackBar, Dialog, etc.
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'La hora de fin no puede ser anterior a la hora de inicio.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                // No actualizar el valor de selectedEndDate
                                              } else {
                                                setState(() {
                                                  _lists[index]
                                                          .selectedEndDate =
                                                      newValue;
                                                });
                                              }
                                            }
                                          },
                                          dropdownColor: Colors.grey.shade800,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10 * scaleFactor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5 * scaleFactor),
                                  Row(
                                    children: [
                                      Text(
                                        'con el valor de la entrada:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SFPro',
                                          fontSize: 14 * scaleFactor,
                                        ),
                                      ),
                                      SizedBox(width: 10 * scaleFactor),
                                      Expanded(
                                        child: TextField(
                                          controller: _ticketPriceController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10 * scaleFactor),
                                            ),
                                            hintText: 'Ingrese el valor aquí',
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'SFPro',
                                              fontSize: 14 * scaleFactor,
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
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
                            SizedBox(height: 16 * scaleFactor),
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
                                                      color: Colors.white,
                                                      fontFamily: 'SFPro',
                                                      fontSize:
                                                          14 * scaleFactor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 10 * scaleFactor),
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
                                                            color: Colors.white,
                                                            fontFamily: 'SFPro',
                                                            fontSize: 14 *
                                                                scaleFactor,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        _lists[index]
                                                                .addExtraTime
                                                            ? (DateTime?
                                                                newValue) {
                                                                if (newValue !=
                                                                    null) {
                                                                  setState(() {
                                                                    _lists[index]
                                                                            .selectedStartExtraDate =
                                                                        newValue;
                                                                    if (_lists[index]
                                                                            .selectedEndExtraDate
                                                                            ?.isBefore(newValue) ==
                                                                        true) {
                                                                      _lists[index]
                                                                              .selectedEndExtraDate =
                                                                          _availableDates
                                                                              .last;
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('La hora de fin no puede ser anterior a la hora de inicio.'),
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),
                                                                      );
                                                                    }
                                                                  });
                                                                }
                                                              }
                                                            : null,
                                                    dropdownColor:
                                                        Colors.grey.shade800,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10 *
                                                                    scaleFactor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 20 * scaleFactor),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Hasta',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'SFPro',
                                                      fontSize:
                                                          14 * scaleFactor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 10 * scaleFactor),
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
                                                            color: Colors.white,
                                                            fontFamily: 'SFPro',
                                                            fontSize: 14 *
                                                                scaleFactor,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        _lists[index]
                                                                .addExtraTime
                                                            ? (DateTime?
                                                                newValue) {
                                                                if (newValue !=
                                                                    null) {
                                                                  setState(() {
                                                                    _lists[index]
                                                                            .selectedStartExtraDate =
                                                                        newValue;
                                                                    // Verifica si la hora de fin extra es anterior a la hora de inicio extra
                                                                    if (_lists[index]
                                                                            .selectedEndExtraDate
                                                                            ?.isBefore(newValue) ==
                                                                        true) {
                                                                      _lists[index]
                                                                              .selectedEndExtraDate =
                                                                          _availableDates
                                                                              .last;
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('La hora de fin no puede ser anterior a la hora de inicio.'),
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),
                                                                      );
                                                                    }
                                                                  });
                                                                }
                                                              }
                                                            : null,
                                                    dropdownColor:
                                                        Colors.grey.shade800,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10 *
                                                                    scaleFactor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5 * scaleFactor),
                                          IgnorePointer(
                                            ignoring:
                                                !_lists[index].addExtraTime,
                                            child: Row(
                                              children: [
                                                Text(
                                                  'con el valor de la entrada:',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'SFPro',
                                                    fontSize: 14 * scaleFactor,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 10 * scaleFactor),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _ticketExtraPriceController,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10 *
                                                                    scaleFactor),
                                                      ),
                                                      hintText:
                                                          'Ingrese el valor aquí',
                                                      hintStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'SFPro',
                                                        fontSize:
                                                            14 * scaleFactor,
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'SFPro',
                                                      fontSize:
                                                          14 * scaleFactor,
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
                                                                .ticketExtraPrice =
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
                                                size: 100 * scaleFactor,
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
                                        EdgeInsets.all(10 * scaleFactor),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              _lists[index].addExtraTime != true
                                                  ? Colors.green.shade300
                                                  : Colors.red.shade300),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey.shade900),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10 * scaleFactor),
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
                                          size: 20 * scaleFactor,
                                        ),
                                        SizedBox(width: 5 * scaleFactor),
                                        Text(
                                          _lists[index].addExtraTime != true
                                              ? 'Agregar nuevo rango horario'
                                              : 'Cancelar rango horario extra',
                                          style: TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 14 * scaleFactor,
                                          ),
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
                                    activeColor: Colors.blue,
                                    checkColor: Colors.white,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Permitir Sublistas dentro de la Lista',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'SFPro',
                                              fontSize: 14 * scaleFactor,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 20 * scaleFactor,
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
                                child: Text(
                                  'Confirmar Configuración',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 16 * scaleFactor,
                                  ),
                                ),
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
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        double scaleFactor = MediaQuery.of(context).size.width / 375.0;
        return CupertinoActionSheet(
          title: Text(
            'Confirmación',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          message: Text(
            '¿Estás seguro de que deseas eliminar esta lista?',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 16 * scaleFactor,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _lists.removeAt(index);
                });
                Navigator.pop(context);
              },
              isDestructiveAction: true,
              child: Text(
                'Eliminar',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 16 * scaleFactor,
                  color: Colors.red,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cerrar',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 16 * scaleFactor,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToStep3(BuildContext context) {
    if (_lists.isNotEmpty) {
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
      double scaleFactor = MediaQuery.of(context).size.width / 375.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, ingrese alguna lista.',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14 * scaleFactor,
            ),
          ),
        ),
      );
    }
  }
}
