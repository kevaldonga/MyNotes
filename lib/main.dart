import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:my_notes/Activities/home_page.dart';
import 'package:my_notes/Activities/notesedit_view.dart';
import 'package:my_notes/essential%20classes/note.dart';

import 'Activities/login_view.dart';
import 'Activities/register_view.dart';
import './Activities/user_view.dart';
import 'constants/routes.dart';
import './other/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  EasyLoading.instance.userInteractions = false;
  runApp(const MyApp());
}

GoRouter _router = GoRouter(initialLocation: Routes.homePage, routes: <GoRoute>[
  GoRoute(
      name: "Loginview",
      path: Routes.loginView,
      builder: (BuildContext context, GoRouterState state) =>
          const LoginView()),
  GoRoute(
      name: "Homepage",
      path: Routes.homePage,
      builder: (BuildContext context, GoRouterState state) => const Homepage()),
  GoRoute(
      name: "Regiterview",
      path: Routes.registerView,
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterView()),
  GoRoute(
      name: "NoteseditView",
      path: Routes.notesEditView,
      builder: (BuildContext context, GoRouterState state) {
        return Noteseditview(note: state.extra as Note?);
      }),
  GoRoute(
      name: "Userview",
      path: Routes.userActivity,
      builder: (BuildContext context, GoRouterState state) => const Userview())
]);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: _router,
        title: "My Notes",
        theme: ThemeData(
          brightness: Brightness.light,
          cardColor: const Color.fromARGB(255, 236, 251, 237),
          scaffoldBackgroundColor: const Color.fromARGB(255, 247, 255, 247),
          focusColor: const Color.fromARGB(13, 42, 169, 46),
          highlightColor: const Color.fromARGB(39, 24, 171, 29),
          splashColor: const Color.fromARGB(32, 0, 154, 5),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            splashColor: ThemeData.light().splashColor,
            focusColor: ThemeData.light().focusColor,
            backgroundColor: Colors.green,
          ),
          textTheme: const TextTheme(
            // textfield text
            titleMedium: TextStyle(
              fontFamily: "Quicksand",
              fontWeight: FontWeight.w500,
            ),
            //textfield text
            labelLarge: TextStyle(
              fontFamily: "Ubuntu",
              fontWeight: FontWeight.w400,
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: const Color.fromARGB(255, 236, 252, 237),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontFamily: "Ubuntu",
              fontWeight: FontWeight.w400,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
            contentTextStyle: const TextStyle(
              color: Colors.black,
              fontFamily: "Ubuntu",
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 30,
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.green.shade400,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: "Ubuntu",
            ),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(secondary: Colors.lightGreen.shade600)
              .copyWith(error: const Color.fromARGB(255, 0, 90, 3)),
        ),
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init());
  }
}
