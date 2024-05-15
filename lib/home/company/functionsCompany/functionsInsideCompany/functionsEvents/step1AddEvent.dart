import 'package:app_listas/styles/button.dart';
import 'package:flutter/material.dart';
import 'step2AddEvent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
  late TextEditingController _ticketValueController;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  File? _image;

  TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ticketValueController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketValueController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  Future<CroppedFile?> _cropImage(File imageFile) async {
    final imageCropper = ImageCropper(); // Crear una instancia de ImageCropper
    CroppedFile? croppedFile = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio:
          CropAspectRatio(ratioX: 3, ratioY: 6), // Aspect ratio 3:6 (1:2)
      compressQuality: 100,
      maxWidth: 175,
      maxHeight: 350,
    );
    return croppedFile;
  }

  Future<void> _selectDateTime(
      BuildContext context, bool isStartDateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartDateTime) {
            _startDateTime = selectedDateTime;
            if (_endDateTime != null &&
                _endDateTime!
                    .isBefore(_startDateTime!.add(Duration(hours: 1)))) {
              // Asegurar que la fecha de finalización sea al menos una hora después de la fecha de inicio
              _endDateTime = _startDateTime!.add(Duration(hours: 1));
            }
          } else {
            // Limitar la fecha de finalización al mismo día que la de inicio y al menos una hora después
            if (selectedDateTime.isAfter(_startDateTime!) &&
                selectedDateTime
                    .isAfter(_startDateTime!.add(Duration(hours: 1)))) {
              _endDateTime = selectedDateTime;
            } else {
              // Mostrar un mensaje de error si la fecha de finalización es anterior a la fecha de inicio o no es al menos una hora después
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'La fecha de finalización debe ser al menos una hora después de la fecha de inicio.'),
                ),
              );
            }
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
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 350, // Ajusta la altura según tus preferencias
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(10), // Bordes redondeados
                        border: Border.all(
                            color: Color.fromARGB(
                                255, 242, 187, 29)), // Borde gris alrededor
                      ),
                      child: InkWell(
                        onTap: () async {
                          await _getImage();
                        },
                        child: _image == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10), // Bordes redondeados para la imagen
                                child: Image.file(
                                  _image!,
                                  width: 100, // Ancho de la imagen
                                  height: 200, // Alto de la imagen
                                  fit: BoxFit
                                      .cover, // Ajuste de la imagen para cubrir todo el espacio disponible
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        'Foto del evento',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Evento',
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
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del evento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ticketValueController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      8), // Limita la longitud máxima a 8 caracteres
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9,]')), // Permite solo números y coma
                ],
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true), // Muestra el teclado numérico
                decoration: InputDecoration(
                  labelText: 'Valor de la entrada',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 242, 187, 29),
                  ),
                  prefixIcon: Icon(Icons.monetization_on, color: Colors.grey),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el valor de la entrada del evento';
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
              Container(
                child: _startDateTime != null
                    ? InkWell(
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
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color.fromARGB(255, 158, 128, 36),
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Text(
                          'Primero debes poner la fecha de inicio del evento para poner hora de finalizacion',
                          style: TextStyle(
                            color: Color.fromARGB(255, 158, 128, 36),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _goToStep2(context);
                },
                style: buttonPrimary,
                child: Text(
                  'Siguiente paso',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToStep2(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        _startDateTime != null &&
        _endDateTime != null &&
        _image != null) {
      String ticketValueText = _ticketValueController.text;

      // Reemplazar la coma (,) por un punto (.) si está presente en el valor
      ticketValueText = ticketValueText.replaceAll(',', '.');

      double ticketValue = double.parse(ticketValueText);
      print(ticketValue);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step2AddEvent(
            name: _nameController.text,
            ticketValue: ticketValue,
            startDateTime: _startDateTime,
            endDateTime: _endDateTime,
            image: _image,
            companyData: widget.companyData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, complete todos los campos y seleccione una imagen.'),
        ),
      );
    }
  }
}
