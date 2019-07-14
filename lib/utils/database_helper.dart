import 'dart:async';
import 'dart:io';

import 'package:flutter_notekeeper/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DatabaseHelper._createHelperInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null)
      _databaseHelper = DatabaseHelper._createHelperInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "notes.db";
    var noteDB = openDatabase(path, version: 1, onCreate: _createDB);
    return noteDB;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,"
        " $colTitle TEXT, "
        "$colDate TEXT,"
        "$colDescription TEXT,"
        "$colPriority INTEGER)");
  }

  ///////////////////////////////GET NOTES//////////////////////////////////////
  Future<List<Map<String, dynamic>>> getAllMapNotes() async {
    Database db = await this.database;

    var result = await db.query(noteTable, orderBy: "$colPriority ASC");

    return result;
  }

  Future<List<Note>> getAllNotes() async {
    var noteMapList = await getAllMapNotes();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMap(noteMapList[i]));
    }

    return noteList;
  }

  ////////////////////////////////INSERT NOTE///////////////////////////////////
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());

    return result;
  }

  ////////////////////////////////UPDATE NOTE///////////////////////////////////
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);

    return result;
  }

  ////////////////////////////////DELETE NOTE///////////////////////////////////
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.delete(noteTable, where: '$colId = $id');

    return result;
  }

  ////////////////////////////////GET NOTE COUNT////////////////////////////////
  Future<int> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) FROM $noteTable");

    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
