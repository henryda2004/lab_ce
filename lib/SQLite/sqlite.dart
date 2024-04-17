import 'dart:math';
import 'package:lab_ce/JsonModels/reservation_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lab_ce/JsonModels/loan_model.dart';
import 'package:lab_ce/JsonModels/lab_model.dart';
import '../JsonModels/users_model.dart';

class DatabaseHelper {
  final databaseName = "notes.db";
  String noteTable =
      "CREATE TABLE notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT)";

  String labsTable =
      "CREATE TABLE labs (labId INTEGER PRIMARY KEY AUTOINCREMENT, labName TEXT UNIQUE NOT NULL, capacity INTEGER NOT NULL, computers INTEGER NOT NULL, otherAssets TEXT NOT NULL, facilities TEXT NOT NULL)";

  String reservationsTable = "CREATE TABLE reservations ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "date TEXT NOT NULL,"
      "time TEXT NOT NULL,"
      "durationHours INTEGER NOT NULL,"
      "labId INTEGER NOT NULL,"
      "FOREIGN KEY (labId) REFERENCES labs (labId)"
      ")";


  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    final Database db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
      await db.execute(labsTable);
      await db.execute(reservationsTable);
    });

    // Preestablecer el usuario admin con contraseña admin si no existe
    await _prepopulateAdminUser(db);
    await _prepopulateLabs(db);
    await _prepopulateReservations(db);

    return db;
  }

  Future<void> _prepopulateAdminUser(Database db) async {
    final List<Map<String, dynamic>> adminUser = await db.rawQuery("SELECT * FROM users WHERE usrName = 'admin1'");
    if (adminUser.isEmpty) {
      await db.insert('users', {'usrName': 'admin1', 'usrPassword': 'admin'});
    }
  }

  Future<void> _prepopulateLabs(Database db) async {
    final List<Map<String, dynamic>> labsData = await db.rawQuery("SELECT * FROM labs WHERE labName = 'F2-07'");
    if (labsData.isEmpty) {
      await db.insert('labs', {
        'labName': 'F2-07',
        'capacity': 30,
        'computers': 15,
        'otherAssets': 'Proyector',
        'facilities': 'Proyector hacia la pizzarra y pared posterior'
      });
    }

    final List<Map<String, dynamic>> labsData2 = await db.rawQuery("SELECT * FROM labs WHERE labName = 'F2-08'");
    if (labsData2.isEmpty) {
      await db.insert('labs', {
        'labName': 'F2-08',
        'capacity': 14,
        'computers': 14,
        'otherAssets': 'Proyector',
        'facilities': 'Equipo de laboratorio'
      });
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

  Future<int> createReservation(ReservationModel reservation) async {
    final Database db = await initDB();
    return db.insert('reservations', reservation.toMap());
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

  Future<List<LabModel>> getLabs() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('labs');
    return result.map((e) => LabModel.fromMap(e)).toList();
  }

  Future<void> _prepopulateReservations(Database db) async {
    // Define los detalles de la reserva manualmente
    final manualReservation = {
      'date': DateTime.now().toIso8601String(),
      'time': '09:00', // Hora de la reserva
      'durationHours': 2, // Duración en horas de la reserva
      'labId': 1, // ID del laboratorio
    };

    // Inserta la reserva en la base de datos
    await db.insert('reservations', manualReservation);

    print('Se ha generado una nueva reserva manualmente.');
  }

  Future<List<ReservationModel>> getReservationsByLabIdAndDate(int labId, DateTime date) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM reservations WHERE labId = ? AND date(date) = date(?)', // Usamos date() para comparar solo la fecha sin la hora
      [labId, date.toIso8601String()], // Convierte la fecha a formato ISO8601 para compararla con la base de datos
    );

    // Agrega impresiones para ver el resultado de la consulta
    print('Resultado de la consulta SQL: $result');

    // Mapea los resultados de la consulta a objetos ReservationModel
    return result.map((e) => ReservationModel.fromMap(e)).toList();
  }

  Future<void> addReservation({
    required DateTime date,
    required String time,
    required int durationHours,
    required int labId,
  }) async {
    final Database db = await initDB();

    // Insertar la reserva en la base de datos
    await db.insert('reservations', {
      'date': date.toIso8601String(),
      'time': time,
      'durationHours': durationHours,
      'labId': labId,
    });

    print('Se ha agregado una nueva reserva a la base de datos.');
  }



}