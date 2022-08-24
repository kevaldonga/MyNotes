import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_notes/constants/Routes.dart';
import 'package:sqflite/sqflite.dart';
import '../essential classes/Note.dart';
import 'package:intl/intl.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import '../essential classes/sqllite.dart';

class Noteseditview extends StatefulWidget {
  Note? note;
  Noteseditview({Key? key}) : super(key: key);
  Noteseditview.getNote({Key? key, this.note}) : super(key: key);

  @override
  State<Noteseditview> createState() => _NoteseditviewState(note);
}

enum Info {
  delete,
  style,
  pinned,
}

class _NoteseditviewState extends State<Noteseditview>
    with WidgetsBindingObserver {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final SolidController _solidController;
  final List<String> bottomsheettext = ["background", "title", "contents"];
  Note? _note;
  final Map<String, Color> pickedcolor = {
    "background": Colors.white,
    "title": Colors.black,
    "content": Colors.black
  };
  final List<Color> colors = [
    // ignore: prefer_const_constructors
    Color.fromARGB(254, 255, 255, 255),
    const Color.fromARGB(255, 0, 0, 0),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 76, 175, 80),
    const Color.fromARGB(255, 255, 152, 0),
    const Color.fromARGB(255, 33, 150, 243),
    const Color.fromARGB(255, 103, 58, 183),
    const Color.fromARGB(255, 244, 67, 54),
    const Color.fromARGB(255, 139, 195, 74),
    const Color.fromARGB(255, 255, 235, 59),
    const Color.fromARGB(255, 233, 30, 99),
  ];
  late bool isPinned;
  late Color _titlecolor, _contentcolor, _backgroundcolor;
  int selectedIndex = 0;
  bool isupdated = true;
  late Database db;

  _NoteseditviewState(this._note);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
    setState(() {
      isPinned = _note?.isPinned ?? false;
    });
    if (_note != null) {
      _backgroundcolor = _note?.getbackgroundcolor ?? Colors.white;
      _titlecolor = _note?.gettitlecolor ?? Colors.black;
      _contentcolor = _note?.getcontentcolor ?? Colors.black;
    } else {
      _backgroundcolor = const Color.fromARGB(255, 255, 255, 255);
      _titlecolor = const Color.fromARGB(255, 0, 0, 0);
      _contentcolor = const Color.fromARGB(255, 0, 0, 0);
    }
    _solidController = SolidController();
    _title = TextEditingController();
    _content = TextEditingController();
    _title.text = _note?.getTitle ?? "";
    _content.text = _note?.getContents ?? "";
    _title.addListener(() {
      setState(() {
        if (_title.text == _note?.getTitle) {
          isupdated = true;
        } else {
          isupdated = false;
        }
      });
    });
    _content.addListener(() {
      setState(() {
        if (_content.text == _note?.getContents) {
          isupdated = true;
        } else {
          isupdated = false;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        saveNote();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final Size size = MediaQuery.of(ctx).size;
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(ctx).unfocus();
        if (_solidController.isOpened) _solidController.hide();
        return false;
      },
      child: Scaffold(
        bottomSheet: Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(6),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: bottomsheet(context),
        ),
        backgroundColor: _backgroundcolor,
        body: Padding(
          padding:
              const EdgeInsets.only(top: 45, left: 10, right: 10, bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 0, top: 5, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // back button
                      IconButton(
                        onPressed: _backpressed,
                        color: _backgroundcolor == Colors.white
                            ? Colors.black87
                            : Colors.white,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      // save
                      Container(
                          margin: EdgeInsets.only(
                            left: size.width * 0.582,
                            right: 0,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (isupdated) {
                                log("note is already been saved");
                                return;
                              }
                              saveNote();
                            },
                            icon: Icon(Icons.check,
                                color: isupdated ? Colors.green : Colors.black),
                          )),
                      noteops(size),
                    ],
                  ),
                ),
                Hero(
                  tag: _note ?? Tags.Default,
                  child: Container(
                    height: size.height * 0.77,
                    padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _title,
                          maxLines: 1,
                          maxLength: 20,
                          autocorrect: true,
                          style: TextStyle(
                            color: _titlecolor,
                            fontSize: 30,
                          ),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.black54,
                            ),
                            hintText: "Title",
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextField(
                            controller: _content,
                            autocorrect: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                              height: 1.9,
                              color: _contentcolor,
                              fontSize: 19,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.black54,
                              ),
                              hintText: "Start typing",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuButton<Info> noteops(Size size) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: _backgroundcolor == Colors.white ? Colors.black87 : Colors.white,
      ),
      itemBuilder: (context) {
        return [
          // pin
          PopupMenuItem(
            child: SizedBox(
              width: size.width * 0.3,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: (isPinned)
                        ? const Icon(
                            Icons.push_pin_rounded,
                            color: Colors.green,
                          )
                        : const Icon(Icons.push_pin_outlined),
                  ),
                  Text((isPinned) ? "unpin" : "pin"),
                ],
              ),
            ),
            value: Info.pinned,
          ),
          // delete
          PopupMenuItem(
            child: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                ),
                Text("delete"),
              ],
            ),
            value: Info.delete,
          ),
          // details
          PopupMenuItem(
            child: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.edit_note_rounded),
                ),
                Text("style"),
              ],
            ),
            value: Info.style,
          ),
        ];
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).dialogBackgroundColor,
      elevation: 10,
      onSelected: (val) async {
        FocusScope.of(context).unfocus();
        switch (val) {
          case Info.delete:
            _note = Note(
                title: "",
                contents: "",
                uid: "null",
                modifiedAt: DateTime.now());
            if (await confirmation(
                context, "Are you sure you want to delete this note ?")) {
              Navigator.of(context).pop(_note);
            }
            break;
          case Info.pinned:
            setState(() {
              isPinned = !isPinned;
              if (isPinned == _note?.isPinned) {
                isupdated = true;
              } else {
                isupdated = false;
              }
            });
            break;
          case Info.style:
            _solidController.show();
            break;
        }
      },
    );
  }

  SolidBottomSheet bottomsheet(BuildContext context) {
    return SolidBottomSheet(
      autoSwiped: true,
      canUserSwipe: true,
      elevation: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.3,
      controller: _solidController,
      headerBar: bottomsheetheader(context),
      body: StatefulBuilder(builder: (context, sheetState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "last modified at " +
                    DateFormat("dd-MM-yyyy hh:mm a").format(
                      _note?.getModifiedAt ?? DateTime.now(),
                    ),
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: "Ubuntu",
                  fontWeight: FontWeight.w400,
                ),
              ),
              sheettabs(sheetState, context),
              colorlists(sheetState, context),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  _solidController.hide();
                },
                // apply
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_backgroundcolor == _note?.getbackgroundcolor &&
                          _titlecolor == _note?.gettitlecolor &&
                          _contentcolor == _note?.getcontentcolor) {
                        isupdated = true;
                        return;
                      }
                      _note?.backgroundcolor = _backgroundcolor;
                      _note?.titlecolor = _titlecolor;
                      _note?.contentcolor = _contentcolor;
                      isupdated = false;
                    });
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 140) / 6,
                    width: (MediaQuery.of(context).size.width - 140) / 3,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Ubuntu",
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Column bottomsheetheader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.black,
        ),
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          height: MediaQuery.of(context).size.height * 0.06,
          width: double.maxFinite,
          child: Text(
            "created at " +
                DateFormat("dd-MM-yyyy hh:mm a").format(
                  _note?.getCreatedAt ?? DateTime.now(),
                ),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: "Ubuntu",
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Row sheettabs(StateSetter sheetState, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        bottomsheettext.length,
        (index) {
          return GestureDetector(
            onLongPress: () {
              sheetState(() {
                selectedIndex = index;
              });
            },
            onTap: () {
              sheetState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: (MediaQuery.of(context).size.width - 140) / 6,
              width: (MediaQuery.of(context).size.width - 140) / 2.5,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? Colors.green
                    : Colors.lightGreen.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  bottomsheettext[index],
                  style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 15,
                      color:
                          selectedIndex == index ? Colors.white : Colors.green),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SingleChildScrollView colorlists(
      StateSetter sheetState, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(colors.length, (index) {
          return GestureDetector(
            onTap: () async {
              sheetState(() {
                switch (selectedIndex) {
                  case 0:
                    _backgroundcolor = colors[index];
                    break;
                  case 1:
                    _titlecolor = colors[index];
                    break;
                  case 2:
                    _contentcolor = colors[index];
                    break;
                }
              });
              if (index == 0) {
                Color? color = await colorpicker(context);
                color = color?.withOpacity(1);
                sheetState(() {
                  colors[0] = color ?? colors[getselectedcolor()];
                  switch (selectedIndex) {
                    case 0:
                      pickedcolor["background"] = colors[0];
                      _backgroundcolor = color ?? Colors.white;
                      break;
                    case 1:
                      pickedcolor["title"] = colors[0];
                      _titlecolor = color ?? Colors.black;
                      break;
                    case 2:
                      pickedcolor["content"] = colors[0];
                      _contentcolor = color ?? Colors.black;
                      break;
                  }
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              width: MediaQuery.of(context).size.width * 0.12,
              height: MediaQuery.of(context).size.width * 0.12,
              decoration: BoxDecoration(
                color: index != 0 ? colors[index] : getpickedcolor(),
                shape: BoxShape.circle,
                border: getselectedcolor() == index
                    ? Border.all(color: Colors.greenAccent, width: 3)
                    : null,
              ),
              child: Center(
                child: index == 0
                    ? const Icon(
                        Icons.colorize_rounded,
                        color: Colors.greenAccent,
                      )
                    : Visibility(
                        visible: getselectedcolor() == index,
                        child: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<bool> confirmation(BuildContext context, String contents) async {
    bool response = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Are you sure"),
            content: Text(contents),
            actions: [
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                onPressed: () {
                  deleteNote();
                  Navigator.of(ctx).pop(true);
                },
                child: const Text("delete"),
              ),
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text("go back"),
              ),
            ],
          );
        }).then((value) => value ?? false);
    return response;
  }

  void _backpressed() async {
    if (!isupdated) {
      saveNote();
    }
    if (_note?.getTitle == "" && _note?.getContents == "") {
      if (await confirmation(
          context, "You will lose this note as it has no contents !!")) {
        deleteNote();
        Navigator.of(context).pop(_note);
      }
    } else {
      Navigator.of(context).pop(_note);
    }
  }

  void saveNote() {
    if (_note != null) {
      log(_note?.getCreatedAt.toString() ?? "nice");
      updateNote();
      return;
    }
    setState(() {
      _note = Note(
        uid: FirebaseAuth.instance.currentUser?.uid ?? "12345",
        title: _title.text,
        contents: _content.text,
        modifiedAt: DateTime.now(),
      );
      isupdated = true;
      _note?.setPinned = isPinned;
      _note?.titlecolor = _titlecolor;
      _note?.contentcolor = _contentcolor;
      _note?.backgroundcolor = _backgroundcolor;
    });
    if (_note?.getTitle == "" && _note?.getContents == "") {
      return;
    }
    SQL.insert(db, [_note]);
  }

  void updateNote() {
    setState(() {
      _note?.setTitle = _title.text;
      _note?.setContents = _content.text;
      _note?.setModifiedAt = DateTime.now();
      _note?.setPinned = isPinned;
      isupdated = true;
    });
    SQL.update(db, _note);
  }

  int getselectedcolor() {
    switch (selectedIndex) {
      case 0:
        return colors.indexOf(_backgroundcolor);
      case 1:
        return colors.indexOf(_titlecolor);
      case 2:
        return colors.indexOf(_contentcolor);
    }
    return 0;
  }

  Future<Color?> colorpicker(BuildContext context) {
    Color _currentcolor = getpickedcolor();
    return showDialog<Color>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                  child: Text(
                "pick a color",
                style: TextStyle(fontFamily: "Ubuntu"),
              )),
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
                pickerColor: getpickedcolor(),
                onColorChanged: (value) {
                  _currentcolor = value;
                },
              ),
            ),
            actions: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                width: double.maxFinite,
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(_currentcolor),
                  child: const Text(
                    "pick",
                    style: TextStyle(fontFamily: "Ubuntu", fontSize: 20),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void deleteNote() {
    if (_note == null) {
      return;
    }
    SQL.delete(db, [_note]);
  }

  void init() async {
    db = await SQL.sqlinit(FirebaseAuth.instance.currentUser?.email ?? "");
  }

  getpickedcolor() {
    switch (selectedIndex) {
      case 0:
        return pickedcolor["background"];
      case 1:
        return pickedcolor["title"];
      case 2:
        return pickedcolor["content"];
    }
  }
}
