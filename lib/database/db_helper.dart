import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;
  static const String dbName = "app_database.db";

  /// ✅ **Ensure Singleton**
  static Future<Database> get database async {
    if (_database == null) {
      _database = await _initDB();
    }
    return _database!;
  }

  /// ✅ **Initialize Database with Foreign Keys**
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute("PRAGMA foreign_keys = ON;"); // ✅ Ensure foreign keys work
      },
      singleInstance: true,
    );
  }

  /// ✅ **Create Tables with Foreign Key Constraints**
  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        fullname TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_name TEXT NOT NULL,
        room_desc TEXT,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        checkin TEXT NOT NULL,
        checkout TEXT NOT NULL,
        fullname TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        adult INTEGER NOT NULL,
        child INTEGER NOT NULL,
        pet INTEGER NOT NULL,
        ratepernight REAL NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL,
        tax REAL NOT NULL,
        grandtotal REAL NOT NULL,
        prepayment REAL NOT NULL,
        balance REAL NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
      );
    ''');
  }

  /// ✅ **Ensure database is properly closed when the app exits**
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // ========== CRUD Operations for Users ==========
  static Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.transaction((txn) async => await txn.insert('Users', user));
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  static Future<int> updateUser(Map<String, dynamic> user, int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.update('Users', user, where: 'id = ?', whereArgs: [id]));
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.rawDelete("DELETE FROM Users WHERE id = ?", [id]));
  }

  // ========== CRUD Operations for Rooms ==========
  static Future<int> insertRoom(Map<String, dynamic> room) async {
    final db = await database;
    return await db.transaction((txn) async => await txn.insert('Rooms', room));
  }

  static Future<List<Map<String, dynamic>>> getRooms() async {
    final db = await database;
    return await db.query('Rooms');
  }

  static Future<int> updateRoom(Map<String, dynamic> room, int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.update('Rooms', room, where: 'id = ?', whereArgs: [id]));
  }

  static Future<int> deleteRoom(int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.rawDelete("DELETE FROM Rooms WHERE id = ?", [id]));
  }

  // ========== CRUD Operations for Reservations ==========
  static Future<int> insertReservation(Map<String, dynamic> reservation) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.insert('Reservations', reservation));
  }

  static Future<List<Map<String, dynamic>>> getReservations() async {
    final db = await database;
    return await db.query('Reservations');
  }

  static Future<int> updateReservation(Map<String, dynamic> reservation, int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.update('Reservations', reservation, where: 'id = ?', whereArgs: [id]));
  }

  static Future<int> deleteReservation(int id) async {
    final db = await database;
    return await db.transaction((txn) async =>
    await txn.rawDelete("DELETE FROM Reservations WHERE id = ?", [id]));
  }

  /// ✅ **Reset Database with Timeout to Prevent Infinite Locks**
  static Future<void> resetDatabase() async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.execute("PRAGMA foreign_keys = OFF;");

        await txn.rawDelete("DELETE FROM Reservations;");
        await txn.rawDelete("DELETE FROM Rooms;");
        await txn.rawDelete("DELETE FROM Users;");

        await txn.execute("PRAGMA foreign_keys = ON;");
      }).timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception("Database reset operation took too long.");
      });
    } catch (e) {
      print("Database Reset Error: $e");
    }
  }
}
