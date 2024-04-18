import 'dart:math';
import 'package:lab_ce/JsonModels/loan_model.dart';
import 'package:lab_ce/JsonModels/reservation_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
      "description TEXT NOT NULL," // Nuevo campo
      "usuario TEXT NOT NULL," // Nuevo campo
      "FOREIGN KEY (labId) REFERENCES labs (labId)"
      ")";

  String loansTable = "CREATE TABLE loans ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "asset TEXT NOT NULL,"
      "name TEXT NOT NULL,"
      "lastName1 TEXT NOT NULL,"
      "lastName2 TEXT NOT NULL,"
      "email TEXT NOT NULL,"
      "dateTime TEXT NOT NULL,"
      "approved INTEGER NOT NULL"
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
      await db.execute(loansTable);
    });

    // Preestablecer el usuario admin con contraseña admin si no existe
    await _prepopulateAdminUser(db);
    await _prepopulateLabs(db);
    await _prepopulateLoans(db);

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

  Future<void> _prepopulateLoans(Database db) async {
    // Genera tres préstamos de ejemplo
    final loans = [
      LoanModel(
        asset: 'Laptop',
        name: 'John',
        lastName1: 'Doe',
        lastName2: '',
        email: 'john.doe@example.com',
        dateTime: DateTime.now(),
        approved: 0,
      ),
      LoanModel(
        asset: 'Proyector',
        name: 'Jane',
        lastName1: 'Smith',
        lastName2: '',
        email: 'jane.smith@example.com',
        dateTime: DateTime.now().add(Duration(days: 1)),
        approved: 0,
      ),
      LoanModel(
        asset: 'Microscopio',
        name: 'Alice',
        lastName1: 'Johnson',
        lastName2: '',
        email: 'alice.johnson@example.com',
        dateTime: DateTime.now().add(Duration(days: 2)),
        approved: 1,
      ),
    ];

    // Inserta los préstamos en la base de datos
    for (final loan in loans) {
      await db.insert('loans', loan.toMap());
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

  //CRUD Methods


  Future<int> createReservation(ReservationModel reservation) async {
    final Database db = await initDB();
    return db.insert('reservations', reservation.toMap());
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
    required String description,
    required String usuario,
  }) async {
    final Database db = await initDB();

    // Insertar la reserva en la base de datos
    await db.insert('reservations', {
      'date': date.toIso8601String(),
      'time': time,
      'durationHours': durationHours,
      'labId': labId,
      'description': description, // Nuevo campo
      'usuario': usuario, // Nuevo campo
    });

    print('Se ha agregado una nueva reserva a la base de datos.');
  }

  Future<List<LoanModel>> getLoans() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('loans');
    return result.map((e) => LoanModel.fromMap(e)).toList();
  }

  Future<Map<int, LoanModel>> getLoansWithApprovedFalse() async {
    final Database db = await initDB();

    // Realizar la consulta para obtener los préstamos no aprobados
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM loans WHERE approved = ?',
      [0], // 0 representa false para un valor booleano en SQLite
    );

    // Mapear los resultados de la consulta a objetos LoanModel
    // Usar un mapa para almacenar los préstamos con sus IDs correspondientes
    final Map<int, LoanModel> loans = {};
    for (final loanData in result) {
      final loan = LoanModel.fromMap(loanData);
      loans[loanData['id'] as int] = loan;
    }

    return loans;
  }

  Future<void> updateApprovalStatus(int loanId, int approvalStatus) async {
    final db = await initDB();
    await db.rawUpdate('UPDATE loans SET approved = ? WHERE id = ?', [approvalStatus, loanId]);
  }

  Future<Users> getUserByUsername(String username) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'usrName = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

}