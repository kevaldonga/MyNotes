import 'dart:developer' show log;
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_notes/Activities/noteseditView.dart';
import 'package:sqflite/sqflite.dart';
import '../essential classes/sqllite.dart';
import '../reusable%20widgets/create_alertdialog.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../essential classes/Note.dart';

class Userview extends StatefulWidget {
  const Userview({Key? key}) : super(key: key);

  @override
  State<Userview> createState() => _UserviewState();
}

enum Popupitem {
  refresh,
  verify,
  logOut,
  changeEmail,
  changePasscode,
}

enum Sortitems {
  alphabet,
  time,
  pinned,
}

class _UserviewState extends State<Userview> with WidgetsBindingObserver {
  final icons = [
    Icons.check_box_outlined,
    Icons.sort,
  ];
  List<Note> notes = [];
  List<Note> searchNotes = [];
  List<Note> selectedNotes = [];
  Note? _currentNote;
  late bool isAllselected = false, selection = false;
  late bool isemailVerified;
  late final FirebaseAuth auth;
  String newEmail = "";
  String password = "";
  String searchtext = "";
  late Database db;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    auth = FirebaseAuth.instance;
    init();
    isemailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    // if (!isemailVerified) {
    //   SQL.insert(db, notes);
    // } else {
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      bottomNavigationBar: bottomAction(ctx),
      floatingActionButton: fab(ctx),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 40),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              backgroundColor: const Color(0x00000000),
              snap: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: titleitems(ctx),
              floating: true,
              automaticallyImplyLeading: false,
              centerTitle: true,
              titleSpacing: 0,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            notesBuildView(ctx),
          ],
        ),
      ),
      extendBody: true,
    );
  }

  void bringpinnedForward() {
    if (isAllPinned(notes)) {
      return;
    }
    setState(() {
      notes.sort((a, b) {
        if (b.isPinned) {
          return 1;
        }
        if (a.isPinned) {
          return -1;
        }
        return 0;
      });
    });
  }

  Widget titleitems(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor.withGreen(80),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Theme.of(context).focusColor.withGreen(100).withOpacity(0.15),
          width: 1,
        ),
      ),
      width: double.infinity,
      height: 55,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(26),
        autofocus: false,
        splashColor: Theme.of(context).focusColor.withGreen(110),
        highlightColor: Theme.of(context).focusColor.withGreen(140),
        focusColor: Theme.of(context).focusColor,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Icon(Icons.search, color: Colors.black.withOpacity(0.6)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                focusNode: _searchFocusNode,
                autofocus: false,
                autocorrect: false,
                cursorHeight: 20,
                onChanged: (val) {
                  setState(() {
                    searchtext = val;
                  });
                  setSearchedItems(context);
                },
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                    fontFamily: "Quicksand",
                  ),
                  labelStyle: TextStyle(
                    fontFamily: "Quicksand",
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  hintText: "Search...",
                ),
              ),
            ),
            PopupMenuButton(
              icon: CircleAvatar(
                child: getUserImage(),
              ),
              itemBuilder: (context) {
                return [
                  // refresh
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.refresh,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Refresh",
                          style: TextStyle(fontFamily: "Quicksand"),
                        ),
                      ],
                    ),
                    enabled: true,
                    value: Popupitem.refresh,
                  ),
                  // verified
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.verified,
                            color:
                                isemailVerified ? Colors.green : Colors.black87,
                          ),
                        ),
                        Text(isemailVerified ? "Verified" : "Not verified",
                            style: const TextStyle(fontFamily: "Quicksand")),
                      ],
                    ),
                    enabled: true,
                    value: Popupitem.verify,
                  ),
                  // change email
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.alternate_email,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Change email",
                          style: TextStyle(fontFamily: "Quicksand"),
                        ),
                      ],
                    ),
                    enabled: true,
                    value: Popupitem.changeEmail,
                  ),
                  // chnage password
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.password,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Change passcode",
                          style: TextStyle(fontFamily: "Quicksand"),
                        ),
                      ],
                    ),
                    enabled: true,
                    value: Popupitem.changePasscode,
                  ),
                  // log out
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.logout,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Log out",
                          style: TextStyle(fontFamily: "Quicksand"),
                        ),
                      ],
                    ),
                    enabled: true,
                    value: Popupitem.logOut,
                  ),
                ];
              },
              onSelected: (value) async {
                _searchFocusNode.unfocus();
                switch (value) {
                  case Popupitem.verify:
                    {
                      if (auth.currentUser!.emailVerified) {
                        createAlertDialogBox(context, "Already verified",
                            "You are already verified !!");
                        return;
                      }
                      String email = auth.currentUser?.email ?? "null";
                      final isConfirmed = await createAlertDialogBox(
                          context,
                          "Confirm",
                          "Email verification will be sent your email id - " +
                              email);
                      if (isConfirmed) {
                        EasyLoading.show(status: "sending");
                        var error = false;
                        try {
                          await auth.currentUser?.sendEmailVerification();
                        } on FirebaseAuthException catch (e) {
                          error = true;
                          createAlertDialogBox(
                              context, "fatal error occurred", e.code);
                        }
                        if (!error) {
                          createAlertDialogBox(
                              context,
                              "Sent",
                              "Email verification to your email id " +
                                  email +
                                  " has been send !!");
                        }
                      }
                      break;
                    }

                  case Popupitem.changeEmail:
                    {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("change email"),
                              elevation: 10,
                              content: TextField(
                                autofocus: true,
                                enableSuggestions: true,
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    newEmail = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: "New email",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    if (newEmail.isEmpty) {
                                      createAlertDialogBox(context, "empty",
                                          "given email is empty !!");
                                      return;
                                    }
                                    if (!EmailValidator.validate(newEmail)) {
                                      createAlertDialogBox(context, "invalid",
                                          "Given email is in invalid format !!");
                                      return;
                                    }
                                    EasyLoading.show(status: "changing");
                                    await auth.currentUser
                                        ?.updateEmail(newEmail)
                                        .whenComplete(() {
                                      createAlertDialogBox(
                                          context,
                                          "updated",
                                          "Your email id has been updated to - " +
                                              newEmail);
                                    });
                                  },
                                  child: const Center(child: Text("change")),
                                ),
                              ],
                            );
                          });
                      break;
                    }

                  case Popupitem.changePasscode:
                    {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("change password"),
                              content: TextField(
                                autocorrect: false,
                                obscureText: true,
                                autofocus: true,
                                enableSuggestions: false,
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: "New password",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              elevation: 10,
                              actions: [
                                TextButton(
                                  onPressed: (() async {
                                    if (password.isEmpty) {
                                      createAlertDialogBox(context, "too short",
                                          "given password is shorter than 8 characters");
                                      return;
                                    }
                                    if (!isemailVerified) {
                                      createAlertDialogBox(
                                          context,
                                          "Not verified",
                                          "You are not verified !!");
                                    }
                                    await auth.currentUser
                                        ?.updatePassword(password)
                                        .whenComplete(() {
                                      createAlertDialogBox(context, "updated",
                                          "your password has been updated !!");
                                    });
                                  }),
                                  child: const Center(child: Text("change")),
                                ),
                              ],
                            );
                          });
                      break;
                    }

                  case Popupitem.refresh:
                    {
                      await auth.currentUser?.reload();
                      isemailVerified =
                          auth.currentUser?.emailVerified ?? false;
                      break;
                    }

                  case Popupitem.logOut:
                    {
                      String email = auth.currentUser?.email ?? "null";
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Are you sure ?"),
                              content: const Text(
                                  "Are you sure you want to Log out ?"),
                              actions: [
                                TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    var error = false;
                                    EasyLoading.show(status: "Signing out");
                                    try {
                                      await auth.signOut();
                                      await GoogleSignIn().signOut();
                                    } on FirebaseException catch (e) {
                                      error = true;
                                      createAlertDialogBox(context,
                                          "fatal error occurred", e.code);
                                    }
                                    if (!error) {
                                      await createAlertDialogBox(
                                          context,
                                          "signed out !!",
                                          "You are signed out as " + email);
                                      log("database ${db.toString()} has been closed");
                                      await db.close();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              "/Homepage/", (_) => false);
                                    }
                                  },
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("cancel")),
                              ],
                            );
                          });
                      break;
                    }
                  default:
                    break;
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 10,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget bottomAction(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).cardColor,
      shape: const CircularNotchedRectangle(),
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 20, bottom: 5),
        padding: const EdgeInsets.only(left: 5, right: 20, bottom: 5),
        child: Row(
          children: List.generate(
            selection ? 4 : 2,
            (index) {
              return Container(
                margin: const EdgeInsets.only(left: 4, top: 5),
                child: index == 1 && !selection
                    ? PopupMenuButton(
                        color: Theme.of(context).dialogBackgroundColor,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        icon: Icon(
                          icons[index],
                        ),
                        itemBuilder: ((context) {
                          return [
                            const PopupMenuItem(
                              enabled: false,
                              child: Padding(
                                padding: EdgeInsets.only(left: 7),
                                child: Text(
                                  "Sort by",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            // sort by
                            PopupMenuItem(
                              value: Sortitems.alphabet,
                              child: Row(
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, left: 5),
                                    child: Icon(
                                      Icons.abc_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text("Alphabet")
                                ],
                              ),
                            ),
                            // by alphabet
                            PopupMenuItem(
                              value: Sortitems.pinned,
                              child: Row(
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, left: 5),
                                    child: Icon(
                                      Icons.push_pin_rounded,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text("Pinned"),
                                ],
                              ),
                            ),
                            // by pinned
                            PopupMenuItem(
                              value: Sortitems.time,
                              child: Row(
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, left: 5),
                                    child: Icon(
                                      Icons.access_time_filled,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text("time"),
                                ],
                              ),
                            ),
                            // by time
                          ];
                        }),
                        onSelected: (value) {
                          switch (value) {
                            case Sortitems.alphabet:
                              sortByAlphabets(context);
                              break;
                            case Sortitems.pinned:
                              bringpinnedForward();
                              break;
                            case Sortitems.time:
                              sortByTime(context);
                              break;
                            default:
                              break;
                          }
                        },
                      )
                    : IconButton(
                        icon: getBottomIcon(index),
                        color: Colors.black87,
                        iconSize: 33,
                        onPressed: () {
                          switch (index) {
                            case 0:
                              if (notes.isEmpty) {
                                return;
                              }
                              if (isAllselected) {
                                unselectAll(context);
                                setState(() {
                                  selection = false;
                                  isAllselected = false;
                                });
                              } else {
                                setState(() {
                                  isAllselected = true;
                                  selection = true;
                                });
                                selectAll(context);
                              }
                              break;
                          }
                          if (selection) {
                            switch (index) {
                              case 1:
                                deleteSelectedNotes(context);
                                break;
                              case 2:
                                if (isAllPinned(selectedNotes)) {
                                  unPinSelected(context);
                                  return;
                                }
                                pinselectedNotes(context);
                                break;
                              case 3:
                                unselectAll(context);
                                break;

                              default:
                                break;
                            }
                          }
                        }, // onpressed
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget fab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, left: 3, right: 3),
      child: FloatingActionButton(
        elevation: 10,
        onPressed: () async {
          _currentNote = await Navigator.push(
            context,
            MaterialPageRoute<Note>(builder: (context) {
              return Noteseditview();
            }),
          );
          if ((_currentNote?.getTitle == "" &&
                  _currentNote?.getContents == "") ||
              _currentNote == null) {
            log("note object is null");
            return;
          }
          setState(() {
            notes.add(_currentNote!);
            bringpinnedForward();
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget notesBuildView(BuildContext context) {
    if (notes.isEmpty) {
      return blankBuildView(context, "You dont have any notes");
    }
    if (searchtext.isNotEmpty && searchNotes.isEmpty) {
      return blankBuildView(
          context, "We couldn't find specified term in any of notes");
    }
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        ((context, index) {
          return _noteContainer(context, index);
        }),
        childCount: searchtext.isEmpty ? notes.length : searchNotes.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );
  }

  Widget blankBuildView(BuildContext context, String title) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Quicksand",
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void setSearchedItems(BuildContext context) {
    searchNotes = [];
    if (searchtext.isEmpty) {
      return;
    }
    String? text = searchtext.toLowerCase();
    String title;
    String contents;
    for (var note in notes) {
      title = note.getTitle ?? "".toLowerCase();
      contents = note.getContents ?? "".toLowerCase();
      if (title.contains(text) || contents.contains(text)) {
        searchNotes.add(note);
      }
    }
  }

  Widget getBottomIcon(int index) {
    if (selection) {
      switch (index) {
        case 0:
          if (isAllselected) {
            return Icon(
              icons[index],
              color: Colors.green,
            );
          } else {
            return Icon(icons[index]);
          }
        case 1:
          return const Icon(Icons.delete, color: Colors.redAccent);
        case 2:
          return isAllPinned(selectedNotes)
              ? const Icon(
                  Icons.push_pin_rounded,
                  color: Colors.green,
                )
              : const Icon(Icons.push_pin_outlined);
        case 3:
          return const Icon(
            Icons.close,
            color: Colors.redAccent,
          );
      }
    }
    return Icon(icons[index]);
  }

  Widget _noteContainer(BuildContext context, int indexInNotes) {
    return Hero(
      tag: notes[indexInNotes],
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notes[indexInNotes].getbackgroundcolor,
            ),
            margin: const EdgeInsets.all(7),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Theme.of(context).highlightColor,
                splashColor: Theme.of(context).splashColor,
                focusColor: Theme.of(context).focusColor,
                autofocus: false,
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (notes[indexInNotes].isSelected) {
                    unselectNote(context, indexInNotes);
                    return;
                  } else {
                    if (!selection) {
                      _currentNote = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Noteseditview.getNote(
                                note: notes[indexInNotes]);
                          },
                        ),
                      );
                      if ((_currentNote?.getTitle == "" &&
                              _currentNote?.getContents == "") ||
                          _currentNote == null) {
                        setState(() {
                          notes.removeAt(indexInNotes);
                        });
                        return;
                      }
                      setState(() {
                        notes[indexInNotes] = _currentNote!;
                        bringpinnedForward();
                      });
                      return;
                    }
                    selectNote(context, indexInNotes);
                  }
                },
                onLongPress: () {
                  if (notes[indexInNotes].isSelected) {
                    unselectNote(context, indexInNotes);
                  } else {
                    selectNote(context, indexInNotes);
                  }
                },
                child: Container(
                  child: Stack(
                    children: [
                      Visibility(
                        child: Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 40,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(138, 63, 160, 66),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        visible: notes[indexInNotes].isSelected,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title
                            Row(
                              children: [
                                Flexible(
                                  flex: 7,
                                  fit: FlexFit.tight,
                                  child: SubstringHighlight(
                                    text: (searchtext.isEmpty
                                            ? notes[indexInNotes].getTitle
                                            : searchNotes[indexInNotes]
                                                .getTitle) ??
                                        "",
                                    maxLines: 1,
                                    caseSensitive: false,
                                    textStyleHighlight: TextStyle(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(1)),
                                    term: searchtext,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: TextStyle(
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: notes[indexInNotes].gettitlecolor,
                                    ),
                                  ),
                                ),
                                notes[indexInNotes].isPinned
                                    ? Flexible(
                                        flex: 2,
                                        child: Icon(
                                          Icons.push_pin,
                                          size: 23,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 23,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: SubstringHighlight(
                                maxLines: 8,
                                overflow: TextOverflow.ellipsis,
                                text: (searchtext.isEmpty
                                        ? notes[indexInNotes].getContents
                                        : searchNotes[indexInNotes]
                                            .getContents) ??
                                    "",
                                term: searchtext,
                                textStyle: TextStyle(
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: notes[indexInNotes].getcontentcolor,
                                ),
                                textStyleHighlight: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectNote(BuildContext context, int index) {
    setState(() {
      selection = true;
      notes[index].setSelected = true;
      selectedNotes.add(notes[index]);
      if (selectedNotes.length == notes.length) {
        isAllselected = true;
      }
    });
  }

  void unselectNote(BuildContext context, int index) {
    setState(() {
      selectedNotes[selectedNotes.indexOf(notes[index])].setSelected = false;
      selectedNotes.remove(notes[index]);
      isAllselected = false;
      if (selectedNotes.isEmpty) {
        selection = false;
      }
    });
  }

  bool isAllPinned(List<Note> mnotes) {
    for (int i = 0; i < mnotes.length; i++) {
      if (!mnotes[i].isPinned) {
        return false;
      }
    }
    return true;
  }

  void unselectAll(BuildContext context) {
    setState(() {
      for (var i = 0; i < selectedNotes.length; i++) {
        notes[notes.indexOf(selectedNotes[i])].setSelected = false;
      }
      selectedNotes = [];
      selection = false;
      isAllselected = false;
    });
  }

  void selectAll(BuildContext context) {
    setState(() {
      selectedNotes = notes;
      for (int i = 0; i < notes.length; i++) {
        notes[i].setSelected = true;
      }
    });
  }

  void deleteSelectedNotes(BuildContext context) {
    SQL.delete(db, selectedNotes);
    if (isAllselected) {
      setState(() {
        notes = [];
        selectedNotes = [];
        selection = false;
        return;
      });
    }
    setState(() {
      selection = false;
      for (int i = 0; i < selectedNotes.length; i++) {
        notes[notes.indexOf(selectedNotes[i])].setSelected = false;
        notes.remove(selectedNotes[i]);
      }
      selectedNotes = [];
    });
  }

  Widget getUserImage() {
    String? url =
        GoogleSignIn(scopes: ["email", "profile"]).currentUser?.photoUrl;
    if (url == null) {
      return const Icon(Icons.face);
    }
    return Image.asset(url);
  }

  void pinselectedNotes(BuildContext context) {
    setState(() {
      for (int i = 0; i < selectedNotes.length; i++) {
        notes[notes.indexOf(selectedNotes[i])].setPinned = true;
        selectedNotes[i].setPinned = true;
      }
    });
  }

  void unPinSelected(BuildContext context) {
    setState(() {
      for (int i = 0; i < selectedNotes.length; i++) {
        notes[notes.indexOf(selectedNotes[i])].setPinned = false;
        selectedNotes[i].setPinned = false;
      }
    });
  }

  void sortByAlphabets(BuildContext context) {
    setState(() {
      notes.sort((a, b) {
        String x = a.getTitle ?? "";
        String y = b.getTitle ?? "";
        return x.compareTo(y);
      });
    });
  }

  void sortByTime(BuildContext context) {
    setState(() {
      notes.sort((a, b) => a.getCreatedAt.isAfter(b.getCreatedAt)
          ? -1
          : a.getCreatedAt.isBefore(b.getCreatedAt)
              ? 1
              : 0);
    });
  }

  void download() async {
    notes = await SQL.downloadData(db);
  }

  void init() async {
    db = await SQL
        .sqlinit(auth.currentUser?.email ?? "")
        .then((value) async {
      notes = await SQL.downloadData(value);
      return value;
    });
    setState(() {});
  }
}
