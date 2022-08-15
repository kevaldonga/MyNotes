import 'dart:math';
import 'package:flutter/material.dart';

class Note {
  final String uid;
  late String id;
  String? _title;
  String? _contents;
  bool _selected = false;
  bool pinned = false;
  Map<String, Color> _colors = {
    "background": const Color.fromARGB(255, 255, 255, 255),
    "title": const Color.fromARGB(255, 0, 0, 0),
    "content": const Color.fromARGB(255, 0, 0, 0)
  };
  late DateTime _createdAt;
  DateTime? modifiedAt;

  bool get isPinned => pinned;

  set setPinned(bool pinned) => this.pinned = pinned;

  String? get getTitle => _title;

  bool get isSelected => _selected;

  Map<String, Color> get colors => _colors;

  set setcolors(Map<String, Color> colors) => _colors = colors;

  set titlecolor(Color color) => _colors["title"] = color;

  set contentcolor(Color color) => _colors["content"] = color;

  set backgroundcolor(Color color) => _colors["background"] = color;

  Color? get gettitlecolor => _colors["title"];

  Color? get getcontentcolor => _colors["content"];

  Color? get getbackgroundcolor => _colors["background"];

  set setSelected(bool selected) => _selected = selected;

  set setTitle(String title) => _title = title;

  String? get getContents => _contents;

  set setContents(String contents) => _contents = contents;

  DateTime get getCreatedAt => _createdAt;

  DateTime? get getModifiedAt => modifiedAt;

  set setModifiedAt(DateTime modifiedAt) => this.modifiedAt = modifiedAt;
  Note({
    required this.uid,
    required title,
    required contents,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? id,
  })  : _title = title,
        _contents = contents,
        _createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        id = id ?? Random().nextDouble().toString();

  Note.fromMap(Map<String, Object?> map, this.uid) {
    id = map["id"].toString();
    _title = map["title"].toString();
    _contents = map["contents"].toString();
    pinned = map["pinned"].toString() == "1";
    titlecolor = Color(int.parse(map["titlecolor"].toString()));
    contentcolor = Color(int.parse(map["contentscolor"].toString()));
    backgroundcolor = Color(int.parse(map["backgroundcolor"].toString()));
    _createdAt = DateTime.parse(map["created"].toString());
    modifiedAt = DateTime.parse(map["modified"].toString());
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": _title ?? "",
      "contents": _contents ?? "",
      "pinned": pinned ? "1" : "0",
      "titlecolor": gettitlecolor?.value,
      "contentscolor": getcontentcolor?.value,
      "backgroundcolor": getbackgroundcolor?.value,
      "created": _createdAt.toString(),
      "modified": modifiedAt == null
          ? DateTime.now().toString()
          : modifiedAt!.toString(),
    };
  }

  @override
  String toString() {
    return "id = $id || title = $_title || contents = $_contents || pinned = $pinned || titlecolor = ${gettitlecolor?.value} || contentcolor = ${getcontentcolor?.value} || backgroundcolor = ${getbackgroundcolor?.value}\n";
  }
}
