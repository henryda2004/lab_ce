import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lab_ce/JsonModels/reservation_model.dart';

import '../JsonModels/users_model.dart';

class DatabaseHelper {
  final databaseName = "notes.db";
  String noteTable =
      "CREATE TABLE notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  //Now we must create our user table into our sqlite db

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT)";

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    final bool databaseExists = await databaseFactory.databaseExists(path);


    final Database db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
    });

    // Preestablecer el usuario admin con contraseña admin si no existe
    await _prepopulateAdminUser(db);

    return db;
  }

  Future<void> _prepopulateAdminUser(Database db) async {
    final List<Map<String, dynamic>> adminUser = await db.rawQuery("SELECT * FROM users WHERE usrName = 'admin1'");
    if (adminUser.isEmpty) {
      await db.insert('users', {'usrName': 'admin1', 'usrPassword': 'admin'});
    }
  }

  Future<bool> login(Users user) async {
    final Database db = await initDB();

    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where usrName = '${user.usrName}' AND usrPassword = '${user.usrPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }

  Future<List<NoteModel>> searchNotes(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db
        .rawQuery("select * from notes where noteTitle LIKE ?", ["%$keyword%"]);
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  //CRUD Methods

  //Create Note
  Future<int> createNote(NoteModel note) async {
    final Database db = await initDB();
    return db.insert('notes', note.toMap());
  }

  //Get notes
  Future<List<NoteModel>> getNotes() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('notes');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  //Delete Notes
  Future<int> deleteNote(int id) async {
    final Database db = await initDB();
    return db.delete('notes', where: 'noteId = ?', whereArgs: [id]);
  }

  //Update Notes
  Future<int> updateNote(title, content, noteId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update notes set noteTitle = ?, noteContent = ? where noteId = ?',
        [title, content, noteId]);
  }

  String _generateRandomPassword() {
    const allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final passwordLength = 10; // Longitud de la contraseña
    return List.generate(passwordLength, (_) => allowedChars[random.nextInt(allowedChars.length)]).join();
  }

  // Método para asignar una nueva contraseña aleatoria a un usuario dado
  Future<String> generateAndSetRandomPasswordForUser(String username) async {
    final Database db = await initDB();
    final newPassword = _generateRandomPassword();

    // Actualizar la contraseña del usuario en la base de datos
    await db.rawUpdate(
      'UPDATE users SET usrPassword = ? WHERE usrName = ?',
      [newPassword, username],
    );

    print('Nueva contraseña generada para el usuario $username: $newPassword');

    return newPassword;
  }

  Future<bool> userExists(String username) async {
    final Database db = await initDB();

    // Realizar una consulta para verificar si el usuario existe
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM users WHERE usrName = ?',
      [username],
    );

    // Si el resultado contiene al menos un elemento, significa que el usuario existe
    return result.isNotEmpty;
  }

}