import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:my_notes/reusable%20widgets/create_alertdialog.dart';

class registerView extends StatefulWidget {
  const registerView({Key? key}) : super(key: key);

  @override
  State<registerView> createState() => _registerState();
}

class _registerState extends State<registerView> {
  late String email, passcode;
  late bool emailError, passcodeError;
  String? emailErrorText, asscodeErrorText;

  @override
  void initState() {
    email = "";
    passcode = "";
    emailError = false;
    passcodeError = false;
    super.initState();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 10),
            child: TextField(
              // Textfield email
              enableSuggestions: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                errorText: getErrorText("email"),
                focusedErrorBorder: inputBorderCheck(0),
                hintText: "enter email id",
                labelText: "email id",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
            child: TextField(
              // Textfield password
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (value) {
                setState(() {
                  passcode = value;
                });
              },
              decoration: InputDecoration(
                errorText: getErrorText("passcode"),
                focusedErrorBorder: inputBorderCheck(1),
                hintText: "enter passcode",
                labelText: "passcode",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                // Button
                onPressed: () async {
                  if (email.isEmpty || passcode.isEmpty) {
                    createAlertDialogBox(context,"Fields empty !!",
                        "Please fill up empty fields before signing in !!");
                    return;
                  }
                  if ((emailError || passcodeError) ||
                      (emailError && passcodeError)) {
                    createAlertDialogBox(context,"Fix errors !!",
                        "Please fix up displayed errors !!");
                    return;
                  }
                  var error = false;
                  try {
                    EasyLoading.show(status: "creating");
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: passcode);
                  } on FirebaseAuthException catch (e) {
                    error = true;
                    if (e.code == "email-already-in-use") {
                      createAlertDialogBox(context,"Already exist !!",
                          "This email is already in use !!");
                    }
                    else{
                      createAlertDialogBox(context,
                        "Fatal error occured !!", e.toString());
                    }
                  } catch (e) {
                    error = true;
                    createAlertDialogBox(context,
                        "Fatal error occured !!", e.toString());
                  }
                  if(!error){
                    final isCanceledYet = await createAlertDialogBox(context,"account created",
                     "Your account created successfuly !!");
                     if(isCanceledYet){
                      Navigator.pushNamedAndRemoveUntil(context, "/user_view/", (_) => false);
                     }
                  }
                },
                child: const Text("Register"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  inputBorderCheck(int a) {
    if (a == 1) {
      if (passcodeError) {
        return OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).errorColor,
          width: 2,
        ));
      } else if (!passcodeError) {
        return null;
      }
    }
    if (emailError) {
      return OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).errorColor,
        width: 2,
      ));
    } else if (!emailError) {
      return null;
    }
    return null;
  }

  String? getErrorText(String s) {
    if (s == "email") {
      if (email == "") {
        return null;
      }
      bool emailValidate = EmailValidator.validate(email);
      if (emailValidate) {
        setState(() {
          emailError = false;
        });
        return null;
      } else if (!emailValidate) {
        setState(() {
          emailError = true;
        });
        return "Invalid Format !!";
      }
      return null;
    }
    if (s == "passcode") {
      if (passcode == "") {
        return null;
      }
      if (passcode.length < 8) {
        setState(() {
          passcodeError = true;
        });
        return "Passcode too short !!";
      } else {
        setState(() {
          passcodeError = false;
        });
        return null;
      }
    }
    return null;
  }
}
