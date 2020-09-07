import 'package:flutter/material.dart';
import 'package:plaudern/screens/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';

void main() => runApp(Chat());

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool _userLoggedIn = false;

  Future<void> _isLoggedIn() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userLoggedIn = prefs.getBool('IsLoggedIn')??false;
    });
  }

  @override
  void initState() {
    _isLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF3EBACE),
        accentColor: Color(0xFFD8ECF1),
        scaffoldBackgroundColor: Color(0XFF27314F),
      ),
      debugShowCheckedModeBanner: false,
      home: _userLoggedIn ? Home() : LoginScreen(),
    );
  }
}