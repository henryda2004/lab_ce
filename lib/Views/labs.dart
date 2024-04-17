import 'package:flutter/material.dart';
import 'package:lab_ce/JsonModels/lab_model.dart'; // Importa el modelo de laboratorio
import 'package:lab_ce/SQLite/sqlite.dart';
import 'package:lab_ce/Views/reservation.dart'; // Importa el helper de la base de datos

class Labs extends StatefulWidget {
  const Labs({Key? key}) : super(key: key);

  @override
  State<Labs> createState() => _LabsState();
}

class _LabsState extends State<Labs> {
  late DatabaseHelper handler;
  late Future<List<LabModel>> labs;
  final db = DatabaseHelper();

  @override
  void initState() {
    handler = DatabaseHelper();
    labs = handler.getLabs();

    handler.initDB().whenComplete(() {
      labs = getAllLabs();
    });
    super.initState();
  }

  Future<List<LabModel>> getAllLabs() {
    return handler.getLabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laboratorios"),
      ),
      body: FutureBuilder<List<LabModel>>(
        future: labs,
        builder: (BuildContext context, AsyncSnapshot<List<LabModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay datos"));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            final items = snapshot.data ?? <LabModel>[];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(items[index].labName),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Reservation(labId: items[index].labId ?? 0),
                          ),
                        );
                      },
                      child: const Text('Reservar'),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(items[index].labName),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Capacidad: ${items[index].capacity}"),
                                Text("Computadores: ${items[index].computers}"),
                                Text("Otros Activos: ${items[index].otherAssets}"),
                                Text("Facilidades: ${items[index].facilities}"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cerrar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
