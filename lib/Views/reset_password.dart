import 'package:flutter/material.dart';
import 'package:lab_ce/SQLite/sqlite.dart';
import 'package:lab_ce/Views//login.dart';
class reset_password extends StatefulWidget {
  const reset_password({super.key});

  @override
  State<reset_password> createState() => _passwordState();
}

class _passwordState extends State<reset_password> {
  TextEditingController email = TextEditingController();
  final dbHelper = DatabaseHelper(); // Instancia de la clase DatabaseHelper

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 70),
                Image.asset("assets/LabCE.png"),
                TextField(
                  controller: email,
                  decoration: InputDecoration(hintText: "usuario@itcr.cr",
                      prefixIcon: Icon(Icons.person)),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7668F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    // Lógica de inicio de sesión
                    final userExists = await dbHelper.userExists(email.text);
                    if (userExists) {
                      final newPassword = await dbHelper.generateAndSetRandomPasswordForUser(email.text);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Contraseña Restaurada"),
                          content: Text("Se ha generado una nueva contraseña: $newPassword"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Usuario no encontrado"),
                          content: Text("El usuario ingresado no existe en la base de datos."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    child: Text(
                      "Restaurar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Recordó su contraseña?"),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7668F8), // Color hexadecimal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> login()));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    child: Text(
                      "Volver",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
