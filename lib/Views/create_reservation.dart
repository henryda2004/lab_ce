import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_ce/JsonModels/reservation_model.dart';
import 'package:lab_ce/SQLite/sqlite.dart';

class CreateReservation extends StatefulWidget {
  final int labId;


  const CreateReservation({Key? key, required this.labId}) : super(key: key);

  @override
  _CreateReservationState createState() => _CreateReservationState();
}

class _CreateReservationState extends State<CreateReservation> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedDuration;
  final DatabaseHelper dbHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedDuration = 1;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Reserva'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fecha de la Reserva:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Seleccionar Fecha'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Hora de la Reserva:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Text(_selectedTime.format(context)),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Seleccionar Hora'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Duración de la Reserva:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            DropdownButton<int>(
              value: _selectedDuration,
              onChanged: (int? value) {
                setState(() {
                  _selectedDuration = value!;
                });
              },
              items: <int>[1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value hora(s)'),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _createReservation,
                child: Text('Crear Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createReservation() async {
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Call addReservation to save the reservation
    await dbHelper.addReservation(
      date: selectedDateTime,
      time: _selectedTime.format(context), // assuming format is needed
      durationHours: _selectedDuration,
      labId: widget.labId,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reserva Creada'),
          content: Text('La reserva ha sido creada exitosamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
