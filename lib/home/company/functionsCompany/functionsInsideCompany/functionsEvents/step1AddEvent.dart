import 'package:app_listas/styles/button.dart';
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Paso 1: Datos principales del evento",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEventImagePicker(),
              SizedBox(height: 20),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Nombre del Evento',
                prefixIcon: Icons.person,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingrese el nombre del evento'
                    : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _ticketValueController,
                labelText: 'Valor de la entrada',
                prefixIcon: Icons.monetization_on,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingrese el valor de la entrada del evento'
                    : null,
              ),
              SizedBox(height: 16),
              _buildDateTimePicker(
                context: context,
                labelText: 'Fecha y Hora de Inicio',
                dateTime: _startDateTime,
                isStartDateTime: true,
              ),
              SizedBox(height: 16),
              _buildEndDateTimePicker(context),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _goToStep2,
                style: buttonPrimary,
                child: Text('Siguiente paso', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 200,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color.fromARGB(255, 242, 187, 29)),
            ),
            child: InkWell(
              onTap: _getImage,
              child: _image == null
                  ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        width: 100,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              'Foto del evento',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        labelStyle: TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 242, 187, 29)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 158, 128, 36)),
        ),
      ),
      style: TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String labelText,
    required DateTime? dateTime,
    required bool isStartDateTime,
  }) {
    return InkWell(
      onTap: () => _selectDateTime(context, isStartDateTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Color.fromARGB(255, 242, 187, 29)),
          prefixIcon: Icon(Icons.event, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromARGB(255, 242, 187, 29)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromARGB(255, 158, 128, 36)),
          ),
        ),
        child: Text(
          dateTime != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
              : 'Seleccione la fecha y hora de inicio',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEndDateTimePicker(BuildContext context) {
    return Container(
      child: _startDateTime != null
          ? _buildDateTimePicker(
              context: context,
              labelText: 'Fecha y Hora de Finalización',
              dateTime: _endDateTime,
              isStartDateTime: false,
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color.fromARGB(255, 158, 128, 36)),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                'Primero debes poner la fecha de inicio del evento para poner hora de finalizacion',
                style: TextStyle(color: Color.fromARGB(255, 158, 128, 36)),
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
                'Por favor, complete todos los campos y seleccione una imagen.')),
      );
    }
  }
}
