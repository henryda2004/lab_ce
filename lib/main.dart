import 'package:flutter/material.dart';
import 'package:lab_ce/Views//login.dart';
import 'package:lab_ce/Views//reservations.dart';
import 'package:lab_ce/Views/labs.dart';
import 'package:lab_ce/Views/menu.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab_CE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Labs(),
    );
  }
}


