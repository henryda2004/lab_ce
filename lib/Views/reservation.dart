import 'package:flutter/material.dart';
import 'package:lab_ce/JsonModels/reservation_model.dart'; // Importa el modelo de reserva
import 'package:lab_ce/SQLite/sqlite.dart'; // Importa tu helper de base de datos

class Reservation extends StatefulWidget {
  final int labId;

  const Reservation({Key? key, required this.labId}) : super(key: key);

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  late Future<List<ReservationModel>> reservations;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    reservations = db.getReservationsByLabId(widget.labId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Laboratorio'),
      ),
      body: FutureBuilder<List<ReservationModel>>(
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
                  title: Text('ID de reserva: ${reservation.id}'),
                  subtitle: Text('Fecha: ${reservation.date}, Hora: ${reservation.time}, Duración: ${reservation.durationHours} horas'),
                  // Puedes agregar más información de la reserva aquí si lo deseas
                );
              },
            );
          }
        },
      ),
    );
  }
}
