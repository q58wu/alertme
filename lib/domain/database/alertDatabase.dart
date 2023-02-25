import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:alert_me/domain/model/alert.dart';


class AlarmDatabase {
  static final AlarmDatabase instance = AlarmDatabase._init();

  static Database? _database;

  AlarmDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('alerts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''CREATE TABLE $tableAlert ( 
        ${AlertFields.id} $idType, 
        ${AlertFields.isImportant} $boolType,
        ${AlertFields.title} $textType,
        ${AlertFields.description} $textType,
        ${AlertFields.setTime} $textType,
        ${AlertFields.expireTime} $textType
  )
''');
  }

  Future<Alert> create(Alert alert) async {
    final db = await instance.database;
    final id = await db.insert(tableAlert, alert.toJson());
    return alert.copy(id: id);
  }

  Future<Alert> readAlert(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableAlert,
      columns: AlertFields.values,
      where: '${AlertFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Alert.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Alert>> readAllAlerts() async {
    final db = await instance.database;

    const orderBy = '${AlertFields.expireTime} ASC';

    final result = await db.query(tableAlert, orderBy: orderBy);

    return result.map((json) => Alert.fromJson(json)).toList();
  }

  Future<int> update(Alert alarm) async {
    final db = await instance.database;

    return db.update(
      tableAlert,
      alarm.toJson(),
      where: '${AlertFields.id} = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableAlert,
      where: '${AlertFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
