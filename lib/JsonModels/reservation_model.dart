import 'package:flutter/material.dart';

class ReservationModel {
  final int id;
  final DateTime date;
  final TimeOfDay time;
  final int durationHours;
  final int labId;
  final String description;
  final String usuario; // Nuevo campo

  ReservationModel({
    required this.id,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.labId,
    required this.description,
    required this.usuario, // Nuevo campo
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final currentTime = DateTime.now();
    final timeComponents = json['time'].split(':');
    final hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    // Combina la fecha actual con la hora proporcionada
    final dateTime = DateTime(currentTime.year, currentTime.month, currentTime.day, hour, minute);

    return ReservationModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay.fromDateTime(dateTime),
      durationHours: json['durationHours'],
      labId: json['labId'],
      description: json['description'],
      usuario: json['usuario'], // Nuevo campo
    );
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    final timeComponents = map['time'].split(':');
    final hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    // Utiliza la fecha almacenada en la base de datos sin combinarla con la fecha actual
    final dateTime = DateTime.parse(map['date']).add(Duration(hours: hour, minutes: minute));

    return ReservationModel(
      id: map['id'],
      date: dateTime,
      time: TimeOfDay(hour: hour, minute: minute),
      durationHours: map['durationHours'],
      labId: map['labId'],
      description: map['description'],
      usuario: map['usuario'], // Nuevo campo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'durationHours': durationHours,
      'labId': labId,
      'description': description,
      'usuario': usuario, // Nuevo campo
    };
  }
}
