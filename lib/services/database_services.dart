import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:faru/models/task.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();
  Database? db;

  final String taskTableName = "Task";
  final String taskIdColumnName = "Id";
  final String taskContentColumnName = "Content";
  final String taskStatsColumnName = "Stats";

  DatabaseServices._constructor();

  Future<Database> get database async {
    if (db != null) return db!;
    db = await getDatabase();
    return db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $taskTableName (
            $taskIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
            $taskContentColumnName TEXT NOT NULL,
            $taskStatsColumnName INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(taskTableName, {
      taskContentColumnName: content,
      taskStatsColumnName: 0, // Default status as incomplete
    });
  }

  Future<void> updateTaskStatus(int id, int newStatus) async {
    final db = await database;
    await db.update(
      taskTableName,
      {taskStatsColumnName: newStatus},
      where: '$taskIdColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTaskContent(int id, String newContent) async {
    final db = await database;
    await db.update(
      taskTableName,
      {taskContentColumnName: newContent},
      where: '$taskIdColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      taskTableName,
      where: '$taskIdColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> taskMaps = await db.query(taskTableName);

    if (taskMaps.isEmpty) {
      print('No tasks found');
    }

    return taskMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
  }
}



