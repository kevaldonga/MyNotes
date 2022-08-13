import 'dart:developer';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'Note.dart';

class SQL {
  static Future<Database> sqlinit() async {
    var date = DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now());
    var auth = FirebaseAuth.instance;
    Database db = await openDatabase(
        join(await getDatabasesPath(), "${auth.currentUser?.email}.db"),
        onCreate: (db, version) {
          log("$date ${db.toString()} has been created successfully");
          db
              .execute(
                  "CREATE TABLE Notes (id TEXT PRIMARY KEY, title TEXT, contents TEXT, pinned INT, titlecolor INT, contentscolor INT, backgroundcolor INT, created TEXT, modified TEXT)")
              .onError((error, stackTrace) {
            log("erro creating table notes");
          });
        },
        onUpgrade: (db, version, a) {
          log("$date database has been upgraded to ${db.toString()}");
        },
        readOnly: false,
        version: 1,
        onOpen: (db) {
          log("$date ${db.toString()} is opened");
        });
    return db;
  }

  static void insert(Database db, List<Note?> notes) async {
    int a = 1;
    for (int i = 0; i < notes.length; i++) {
      a = await db.insert("Notes", notes[i]!.toMap());
      log("result of inserting ${notes[i].toString()} is " + a.toString());
    }
  }

  static Future<List<Note>> downloadData(Database db) async {
    List<Map<String, Object?>> maps = await db.query("Notes");
    List<Note> notes = List<Note>.generate(maps.length, (i) {
      Note mnote = Note(
          uid: FirebaseAuth.instance.currentUser?.uid ?? "",
          title: maps[i]["title"],
          contents: maps[i]["contents"],
          createdAt: DateTime.parse(maps[i]["createdat"].toString()));
      mnote.setModifiedAt = DateTime.parse(maps[i]["modifiedat"].toString());
      mnote.setPinned =
          int.parse(maps[i]["pinned"].toString()) == 1 ? true : false;
      mnote.titlecolor = Color(int.parse(maps[i]["titlecolor"].toString()));
      mnote.contentcolor =
          Color(int.parse(maps[i]["contentscolor"].toString()));
      mnote.backgroundcolor =
          Color(int.parse(maps[i]["backgroundcolor"].toString()));
      return mnote;
    });
    return notes;
  }

  static void delete(Database db, List<Note?> notes) async {
    int a = 0;
    for (int i = 0; i < notes.length; i++) {
      a = await db.delete("Notes", where: "id = ?", whereArgs: [notes[i]?.id]);
      log("result of deletion of ${notes[i].toString()} is = $a");
    }
  }

  static void update(Database db, Note? note) async {
    int a = 0;
    a = await db
        .update("Notes", note!.toMap(), where: "id = ?", whereArgs: [note.id]);
    log("result of updatation of ${note.toString()} is = $a");
  }
}
