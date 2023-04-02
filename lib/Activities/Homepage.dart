import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './loginView.dart';
import './user_view.dart';

class Homepage extends StatefulWidget {
  const Homepage({ Key? key }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}
class _HomepageState extends State<Homepage>{
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isLoggedIn();
  }
  
  isLoggedIn() {
    if(FirebaseAuth.instance.currentUser != null){
      return const Userview();
    }
    return const loginView();
  }
}