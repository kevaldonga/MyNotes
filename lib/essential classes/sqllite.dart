import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'Note.dart';

class SQL {
  late Database db;
  static Future<Database> sqlinit(String email) async {
    var date = DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now());
    Database db =
        await openDatabase(join(await getDatabasesPath(), "$email.db"),
            onCreate: (db, version) {
              log("$date ${db.toString()} has been created successfully");
              db
                  .execute(
                      "CREATE TABLE Notes (id TEXT PRIMARY KEY, title TEXT, contents TEXT, pinned INT, titlecolor INT, contentscolor INT, backgroundcolor INT, created TEXT, modified TEXT)")
                  .onError((error, stackTrace) {
                log("$date error creating table notes");
              });
            },
            onUpgrade: (db, version, a) {
              log("$date database has been upgraded to ${db.toString()}");
            },
            readOnly: false,
            version: 1,
            onOpen: (db) {
              log("${db.toString()} is opened");
            });
    return db;
  }

  static void insert(Database db, List<Note?> notes) async {
    for (int i = 0; i < notes.length; i++) {
      await db.insert("Notes", notes[i]!.toMap());
      log("${notes[i].toString()} has been inserted");
    }
  }

  static Future<List<Note>> downloadData(Database db) async {
    List<Map<String, Object?>> maps = await db.query("Notes");
    if (maps.isEmpty) {
      log("downloaded data was empty");
      return [];
    }
    List<Note> notes = List<Note>.generate(maps.length, (i) {
      return Note.fromMap(
          maps[i], FirebaseAuth.instance.currentUser?.uid ?? "");
    });
    for (int i = 0; i < notes.length; i++) {
      log("${notes[i].toString()} has been downloaded");
    }
    return notes;
  }

  static void delete(Database db, List<Note?> notes) async {
    for (int i = 0; i < notes.length; i++) {
      await db.delete("Notes", where: "id = ?", whereArgs: [notes[i]?.id]);
      log("${notes[i].toString()} has been deleted");
    }
  }

  static void update(Database db, Note? note) async {
    await db.update(
      "Notes",
      note!.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
    log("${note.toString()} is updated");
  }
}
