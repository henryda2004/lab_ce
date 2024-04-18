import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_ce/JsonModels/reservation_model.dart';
import 'package:lab_ce/JsonModels/users_model.dart';
import 'package:lab_ce/SQLite/sqlite.dart';
import 'package:lab_ce/Views/create_reservation.dart';
import 'package:table_calendar/table_calendar.dart';

class Reservation extends StatefulWidget {
  final int labId;
  final Users user;

  const Reservation({Key? key, required this.labId, required this.user}) : super(key: key);

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  late Future<List<ReservationModel>> reservations;
  final db = DatabaseHelper();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    reservations = db.getReservationsByLabIdAndDate(widget.labId, _selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Laboratorio'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateReservation(labId: widget.labId, user: widget.user)),
              );

              // Si result es true, significa que se ha creado una nueva reserva, entonces actualizamos la lista
              if (result == true) {
                setState(() {
                  reservations = db.getReservationsByLabIdAndDate(widget.labId, _selectedDay);
                });
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 21)), // Tres semanas hacia adelante
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week,
            onPageChanged: (focusedDay) {
              setState(() {
                _selectedDay = focusedDay;
                reservations = db.getReservationsByLabIdAndDate(widget.labId, _selectedDay);
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                reservations = db.getReservationsByLabIdAndDate(widget.labId, _selectedDay);
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<ReservationModel>>(
              future: reservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay reservaciones'));
                } else {
                  final reservations = snapshot.data!;
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return ListTile(
                        title: Text(reservation.description), // Descripción como título
                        subtitle: Text('${reservation.time.hour}:${reservation.time.minute} - ${reservation.durationHours} hora(s)'), // Hora y duración como subtítulo
                        // Puedes agregar más información de la reserva aquí si lo deseas
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
