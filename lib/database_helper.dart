import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// DatabaseHelper manages the SQLite database
/// used by the Student Management application.
class DatabaseHelper {
  // Creates a single shared instance of DatabaseHelper.
  // This prevents creating multiple database helper objects.
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Stores the database instance after it is opened.
  static Database? _database;

  // Private constructor used to create the singleton instance.
  DatabaseHelper._init();

  /// Returns the database instance.
  ///
  /// If the database is already opened, it returns
  /// the existing database instance.
  ///
  /// Otherwise, it initializes and opens the database.
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('student.db');

    return _database!;
  }

  /// Creates or opens the SQLite database.
  Future<Database> _initDB(String fileName) async {
    // Gets the default location for SQLite databases
    // on the device.
    final dbPath = await getDatabasesPath();

    // Creates the complete path of the database file.
    final path = join(dbPath, fileName);

    // Opens the database.
    //
    // If the database does not exist,
    // _createDB() will be called.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the student table when the database
  /// is created for the first time.
  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE student (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');
  }

  // --------------------------------------------------
  // CREATE
  // --------------------------------------------------

  /// Inserts a new student record into the student table.
  ///
  /// Returns the ID of the newly inserted record.
  Future<int> insertStudent(
    String studentId,
    String name,
  ) async {
    final db = await database;

    return await db.insert(
      'student',
      {
        'studentId': studentId,
        'name': name,
      },
    );
  }

  // --------------------------------------------------
  // READ
  // --------------------------------------------------

  /// Retrieves all student records from the student table.
  ///
  /// Returns a list of student records.
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;

    return await db.query('student');
  }

  // --------------------------------------------------
  // UPDATE
  // --------------------------------------------------

  /// Updates an existing student record.
  ///
  /// [id] identifies the student to update.
  ///
  /// Returns the number of rows updated.
  Future<int> updateStudent(
    int id,
    String studentId,
    String name,
  ) async {
    final db = await database;

    return await db.update(
      'student',
      {
        'studentId': studentId,
        'name': name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  /// Deletes an existing student record.
  ///
  /// [id] identifies the student to delete.
  ///
  /// Returns the number of rows deleted.
  Future<int> deleteStudent(int id) async {
    final db = await database;

    return await db.delete(
      'student',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
