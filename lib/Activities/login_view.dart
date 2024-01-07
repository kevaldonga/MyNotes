import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/reusable%20widgets/create_alertdialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  late String email, passcode;
  late bool emailError, passcodeError;
  String? emailErrorText, asscodeErrorText;
  late final FirebaseAuth auth;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
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
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 50, right: 50, top: 40, bottom: 10),
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
              padding: const EdgeInsets.only(
                  left: 50, right: 50, top: 10, bottom: 10),
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
                padding: const EdgeInsets.only(top: 40, bottom: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (email.isEmpty || passcode.isEmpty) {
                      createAlertDialogBox(context, "Fields empty !!",
                          "Please fill up empty fields before signing in !!");
                      return;
                    }
                    if (emailError || passcodeError) {
                      createAlertDialogBox(context, "Fix errors !!",
                          "Please fix up displayed errors !!");
                      return;
                    }
                    var error = false;
                    try {
                      EasyLoading.show(status: "signing in");
                      await auth.signInWithEmailAndPassword(
                          email: email, password: passcode);
                    } on FirebaseException catch (e) {
                      error = true;
                      if (!mounted) return;
                      if (e.code == "user-not-found") {
                        createAlertDialogBox(
                            context, "invalid", "Entered email is invalid !!");
                      } else if (e.code == "wrong-password") {
                        createAlertDialogBox(context, "invalid passcode",
                            "The password you typed is invalid");
                      } else {
                        createAlertDialogBox(
                            context, "Fatal error occured !!", e.toString());
                      }
                    } catch (e) {
                      error = true;
                      if (!mounted) return;
                      createAlertDialogBox(
                          context, "Fatal error occured !!", e.toString());
                    }
                    if (!error) {
                      if (!mounted) return;
                      final isCanceledYet = await createAlertDialogBox(context,
                          "signed in !!", "you have been signed as $email");
                      if (isCanceledYet) {
                        if (!mounted) return;
                        context.go(Routes.userActivity);
                      }
                    }
                  },
                  child: const Text("Login"),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  context.push(Routes.registerView);
                },
                child: const Text("create a account"),
              ),
            ),
            const SizedBox(height: 20),
            signinoptions(() async {
              await _googleSignIn();
            }, "log in with google", Icons.aspect_ratio),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  inputBorderCheck(int a) {
    if (a == 1) {
      if (passcodeError) {
        return OutlineInputBorder(
            borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ));
      } else if (!passcodeError) {
        return null;
      }
    }
    if (emailError) {
      return OutlineInputBorder(
          borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
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

  Future<void> _googleSignIn() async {
    EasyLoading.show(status: "signing in..");

    User? user;
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      try {
        var result =
            await FirebaseAuth.instance.signInWithCredential(credential);
        user = result.user;
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        createAlertDialogBox(context, "Unhandled error", e.code);
      }
      if (user != null) {
        if (!mounted) return;
        createAlertDialogBox(context, "signed in successfully",
            "you have signed in with ${user.email} successfully !!");
        context.go(Routes.userActivity);
      }
    }
    EasyLoading.dismiss();
  }

  Widget signinoptions(VoidCallback callback, String info, IconData iconData) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black38,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Theme.of(context).highlightColor,
            focusColor: Theme.of(context).focusColor,
            splashColor: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              await _googleSignIn();
            },
            child: Container(
                margin: const EdgeInsets.all(10),
                child: Text(
                  info,
                  style: Theme.of(context).textTheme.labelLarge,
                )),
          ),
        ),
      ),
    );
  }
}
