import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<bool> createAlertDialogBox(
    BuildContext context, String title, String des) {
  EasyLoading.dismiss();
  var alert = AlertDialog(
    title: Text(title),
    content: Text(des),
    actions: [
      TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text("Ok"),
      ),
    ],
  );
  return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return alert;
      }).then((value) => value ?? true);
}
