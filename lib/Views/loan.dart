import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_ce/JsonModels/loan_model.dart'; // Importa el modelo LoanModel
import 'package:lab_ce/SQLite/sqlite.dart';

class Loan extends StatefulWidget {
  const Loan({Key? key}) : super(key: key);

  @override
  _LoanState createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  late Future<Map<int, LoanModel>> loansMap;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loansMap = db.getLoansWithApprovedFalse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
      ),
      body: FutureBuilder<Map<int, LoanModel>>(
        future: loansMap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay préstamos'));
          } else {
            final loansMap = snapshot.data!;
            return ListView.builder(
              itemCount: loansMap.length,
              itemBuilder: (context, index) {
                final loanId = loansMap.keys.elementAt(index);
                final loan = loansMap[loanId]!;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(loan.asset), // Activo como título
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(loan.asset), // Activo como título
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Nombre: ${loan.name} ${loan.lastName1} ${loan.lastName2}"),
                                Text("Email: ${loan.email}"),
                                Text("Fecha y hora: ${DateFormat('dd/MM/yyyy HH:mm').format(loan.dateTime)}"), // Formato de hora bonito
                              ],
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  _updateApprovalStatus(loanId, 1); // Cambia el estado de aprobación a 1 (aprobado)
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.check), // Icono de check
                              ),
                              IconButton(
                                onPressed: () {
                                  _updateApprovalStatus(loanId, 2); // Cambia el estado de aprobación a 2 (denegado)
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.close), // Icono de equis (x)
                              ),
                            ],                          );
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

  void _updateApprovalStatus(int loanId, int approvalStatus) async {
    await db.updateApprovalStatus(loanId, approvalStatus);
    setState(() {
      loansMap = db.getLoansWithApprovedFalse();
    });
  }
}
