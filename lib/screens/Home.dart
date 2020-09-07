import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plaudern/screens/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'explore.dart';
import 'Status.dart';
import 'inbox.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String myID, myName, myEmail, myPhoto;

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;

  Firestore cloud = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      FirebaseUser user = await auth.currentUser();
      if (user != null) {
        myID = user.uid;
        var db = await cloud.collection("Users").document(myID).get();
        myName = db.data["username"];
        myPhoto = db.data["userphoto"] ?? "";
        myEmail = user.email;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('IsLoggedIn', true);
      }
    } catch (e) {
      print(e.message.toString());
    }
  }

  setIsActive() async {
    await cloud.collection("Users").document(myID).updateData({
      "isActive": true,
    });
  }

  setUnActive() async {
    await cloud.collection("Users").document(myID).updateData({
      "isActive": false,
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    getCurrentUser();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setUnActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF4E5B81),
        title: Text(
          'Plaudern',
          style: GoogleFonts.pacifico(
            color: Theme.of(context).accentColor,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.7,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).accentColor,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: <Widget>[
            Tab(text: "Chats"),
            Tab(text: "Status"),
            Tab(text: "Explore"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Inbox(),
          Status(),
          Explore(),
        ],
      ),
    );
  }
}
