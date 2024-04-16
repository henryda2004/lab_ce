import 'package:flutter/material.dart';
import 'package:lab_ce/Views/reset_password.dart';
import 'package:lab_ce/Views/reservations.dart';
import 'package:lab_ce/JsonModels/users_model.dart';
import 'package:lab_ce/SQLite/sqlite.dart';
class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLoginTrue = false;

  final db = DatabaseHelper();

  login() async {
    var response = await db
        .login(Users(usrName: username.text, usrPassword: password.text));
    if (response == true) {
      //If login is correct, then goto notes
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Notes()));
    } else {
      //If not, true the bool value to show error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Image.asset("assets/LabCE.png"),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty){
                    return "se requiere usuario";
                  }
                  return null;
                },
                controller: username,
                decoration: InputDecoration(hintText: "usuario@itcr.cr",
                prefixIcon: Icon(Icons.person)),
              ),
              SizedBox(height: 50),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty){
                    return "se requiere contraseña";
                  }
                  return null;
                },
                obscureText: true,
                controller: password,
                decoration: InputDecoration(hintText: "contraseña",
                prefixIcon: Icon(Icons.lock)),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7668F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if(formKey.currentState!.validate()) {
                    //Login method
                    login();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  child: Text(
                    "Ingresar",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Olvidó su contraseña?"),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7668F8), // Color hexadecimal
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const reset_password()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  child: Text(
                    "Restaurar",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              isLoginTrue
                  ? const Text(
                "usuario o contraseña incorrectos",
                style: TextStyle(color: Colors.red),
              )
                  : const SizedBox(),
            ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
