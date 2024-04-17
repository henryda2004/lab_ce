import 'package:flutter/material.dart';
import 'package:lab_ce/SQLite/sqlite.dart';
import 'package:lab_ce/Views/login.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Menú', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4B468F)))),
        backgroundColor: Color(0xFF8A80FD),
        elevation: 0, // No shadow
        automaticallyImplyLeading: false, // No back button
      ),
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenido',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF6158B7)),
          ),
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8A80FD),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Acción al presionar el botón de reservación
                    },
                    icon: Icon(Icons.calendar_today, size: 48, color: Color(0xFF4B468F)),
                    label: Text(
                      'Reservación',
                      style: TextStyle(fontSize: 20, color: Color(0xFF4B468F)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8A80FD),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Acción al presionar el botón de préstamo
                    },
                    icon: Icon(Icons.computer, size: 48, color: Color(0xFF4B468F)),
                    label: Text(
                      'Préstamo',
                      style: TextStyle(fontSize: 20, color: Color(0xFF4B468F)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
