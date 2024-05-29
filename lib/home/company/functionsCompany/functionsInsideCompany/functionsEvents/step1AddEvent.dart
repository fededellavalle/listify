import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'step2AddEvent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Step1AddEvent extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final Map<String, dynamic>? template;

  const Step1AddEvent({
    Key? key,
    required this.companyData,
    this.template,
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.template != null && widget.template!['eventImage'] != null) {
      _loadImageFromUrl(widget.template!['eventImage']);
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.template?['eventName'] ?? '',
    );
    _ticketValueController = TextEditingController(
      text: widget.template?['eventTicketValue']?.toString() ?? '',
    );
  }

  Future<void> _loadImageFromUrl(String imageUrl) async {
    // Aquí puedes cargar la imagen desde la URL y asignarla a _image
    // Por simplicidad, este código no se implementa aquí
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
      final croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 6),
      compressQuality: 100,
      maxWidth: 175,
      maxHeight: 350,
    );
  }

  Future<void> _selectDateTime(
      BuildContext context, bool isStartDateTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _updateDateTime(context, isStartDateTime, selectedDateTime);
      }
    }
  }

  void _updateDateTime(
      BuildContext context, bool isStartDateTime, DateTime selectedDateTime) {
    setState(() {
      if (isStartDateTime) {
        if (_isValidStartDateTime(selectedDateTime)) {
          _startDateTime = selectedDateTime;
          _endDateTime = _validateEndDateTime(_endDateTime, _startDateTime);
          _showSnackBar(context, 'Fecha y hora de inicio seleccionadas.');
        } else {
          _showSnackBar(context,
              'La fecha de inicio debe ser al menos 6 horas después de la hora actual.');
        }
      } else {
        if (_isValidEndDateTime(selectedDateTime, _startDateTime)) {
          _endDateTime = selectedDateTime;
        } else {
          _showSnackBar(context,
              'La fecha de finalización debe ser al menos una hora después de la fecha de inicio y no más de un día después.');
        }
      }
    });
  }

  bool _isValidStartDateTime(DateTime startDateTime) {
    return startDateTime.isAfter(DateTime.now().add(Duration(hours: 6)));
  }

  DateTime? _validateEndDateTime(
      DateTime? endDateTime, DateTime? startDateTime) {
    if (endDateTime != null) {
      if (endDateTime.difference(startDateTime!).inHours < 1 ||
          endDateTime.difference(startDateTime).inDays > 1) {
        return null;
      }
    }
    return endDateTime;
  }

  bool _isValidEndDateTime(DateTime endDateTime, DateTime? startDateTime) {
    return startDateTime != null &&
        endDateTime.isAfter(startDateTime) &&
        endDateTime.difference(startDateTime).inHours >= 1 &&
        endDateTime.difference(startDateTime).inDays < 1;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'SFPro'),
        ),
      ),
    );
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
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16 * scaleFactor,
          right: 16 * scaleFactor,
          bottom: 16 * scaleFactor,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Creemos un Evento',
                  style: TextStyle(
                    fontSize: 25 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Paso 1: Datos principales del evento',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15 * scaleFactor,
                    color: Colors.grey.shade400,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEventImagePicker(scaleFactor),
                  SizedBox(height: 20 * scaleFactor),
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Nombre del Evento',
                    prefixIcon: Icons.person,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Por favor, ingrese el nombre del evento'
                        : null,
                    scaleFactor: scaleFactor,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  _buildTextFormField(
                    controller: _ticketValueController,
                    labelText: 'Valor de la entrada',
                    prefixIcon: Icons.monetization_on,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Por favor, ingrese el valor de la entrada del evento'
                        : null,
                    scaleFactor: scaleFactor,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  _buildDateTimePicker(
                    context: context,
                    labelText: 'Fecha y Hora de Inicio',
                    dateTime: _startDateTime,
                    isStartDateTime: true,
                    scaleFactor: scaleFactor,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  _buildEndDateTimePicker(context, scaleFactor),
                  SizedBox(height: 16 * scaleFactor),
                  CupertinoButton(
                    onPressed: _goToStep2,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImagePicker(double scaleFactor) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 200 * scaleFactor,
            height: 350 * scaleFactor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scaleFactor),
              border: Border.all(color: skyBluePrimary),
            ),
            child: InkWell(
              onTap: _getImage,
              child: _image == null
                  ? Icon(Icons.camera_alt,
                      size: 50 * scaleFactor, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                      child: Image.file(
                        _image!,
                        width: 100 * scaleFactor,
                        height: 200 * scaleFactor,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 10 * scaleFactor,
            left: 10 * scaleFactor,
            child: Text(
              'Foto del evento',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    double scaleFactor = 1.0,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: white,
          fontFamily: 'SFPro',
          fontSize: 14 * scaleFactor,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          borderSide: BorderSide(color: skyBluePrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          borderSide: BorderSide(color: skyBlueSecondary),
        ),
      ),
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'SFPro',
        fontSize: 14 * scaleFactor,
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String labelText,
    required DateTime? dateTime,
    required bool isStartDateTime,
    double scaleFactor = 1.0,
  }) {
    return InkWell(
      onTap: () => _selectDateTime(context, isStartDateTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: white,
            fontFamily: 'SFPro',
            fontSize: 14 * scaleFactor,
          ),
          prefixIcon: Icon(Icons.event, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10 * scaleFactor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10 * scaleFactor),
            borderSide: BorderSide(color: skyBluePrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10 * scaleFactor),
            borderSide: BorderSide(color: skyBlueSecondary),
          ),
        ),
        child: Text(
          dateTime != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
              : 'Seleccione la fecha y hora de inicio',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 14 * scaleFactor,
          ),
        ),
      ),
    );
  }

  Widget _buildEndDateTimePicker(BuildContext context, double scaleFactor) {
    return Container(
      child: _startDateTime != null
          ? _buildDateTimePicker(
              context: context,
              labelText: 'Fecha y Hora de Finalización',
              dateTime: _endDateTime,
              isStartDateTime: false,
              scaleFactor: scaleFactor,
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * scaleFactor),
                border: Border.all(color: skyBlueSecondary),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 12 * scaleFactor, horizontal: 16 * scaleFactor),
              child: Text(
                'Primero debes poner la fecha de inicio del evento para poner hora de finalización',
                style: TextStyle(
                  color: grey,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
              ),
            ),
    );
  }

  void _goToStep2() {
    if (_formKey.currentState!.validate() &&
        _startDateTime != null &&
        _endDateTime != null &&
        _image != null) {
      final ticketValueText = _ticketValueController.text.replaceAll(',', '.');
      final ticketValue = double.parse(ticketValueText);

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
            template: widget.template,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, complete todos los campos y seleccione una imagen.',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }
}
