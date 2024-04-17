import 'package:flutter/material.dart';

class ReservationModel {
  final int id;
  final DateTime date;
  final TimeOfDay time;
  final int durationHours;
  final int labId;

  ReservationModel({
    required this.id,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.labId,
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
    );
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    final currentTime = DateTime.now();
    final timeComponents = map['time'].split(':');
    final hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    // Combina la fecha actual con la hora proporcionada
    final dateTime = DateTime(currentTime.year, currentTime.month, currentTime.day, hour, minute);

    return ReservationModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay.fromDateTime(dateTime),
      durationHours: map['durationHours'],
      labId: map['labId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'durationHours': durationHours,
      'labId': labId,
    };
  }
}
