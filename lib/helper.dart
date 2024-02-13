// ignore_for_file: avoid_classes_with_only_static_members

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static String dbName = "sqlite_app.db";
  static int version = 1;
  static String tableName = "todo_table";
  static String idCol = "todo_id";
  static String todoCol = "todo_name";

  static Future<Database> openDB() async {
    final path = join(await getDatabasesPath(), dbName);
    final sql =
        "CREATE TABLE IF NOT EXISTS $tableName ($idCol INTEGER PRIMARY KEY AUTOINCREMENT, $todoCol TEXT)";

    return openDatabase(
      path,
      onCreate: (db, version) => db.execute(sql),
      version: version,
    );
  }

  static Future<int> insertTodo(String todo) async {
    final db = await openDB();

    return db.insert(
      tableName,
      {todoCol: todo},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await openDB();

    return db.query(tableName);
  }

  static Future<int> delTodo(Todo t) async {
    final db = await openDB();

    return db.delete(
      tableName,
      where: "$idCol = ?",
      whereArgs: [t.id],
    );
  }
}

class Todo {
  late String name;
  late int id;

  Todo({required this.name, required this.id});

  Todo.fromMap(Map<String, dynamic> item) {
    id = int.parse(item[DBHelper.idCol].toString());
    name = item[DBHelper.todoCol].toString();
  }
}
