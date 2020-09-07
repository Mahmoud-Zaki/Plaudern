import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuth {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore cloud = Firestore.instance;

  Future<dynamic> register(username, email, password) async {
    var done;
    try {
      final sign = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((db) {
        cloud.collection("Users").document(db.user.uid).setData({
          "username": username,
          "userphoto": "",
          "email": email,
          "ID": db.user.uid,
          "isActive": false,
        });
        cloud.collection("Calling").document(db.user.uid).setData({
          "myID": db.user.uid,
          "fromname": '',
          "fromphoto": '',
          "chatID": '',
          "isCalling": false,
        });
      });
      if (sign != null)
        done = sign;
      print('future value signup : $done');
    } catch (e) {
      print('error signup : ${e.message.toString()} --- $done');
      return 'error';
    }
    return done;
  }

  Future<dynamic> login(email, password) async {
    var done;
    try {
      final log = await firebaseAuth.
      signInWithEmailAndPassword(email: email, password: password);
      if (log != null)
        done = log;
      print('future value login : $done');
    } catch (e) {
      print('error login : ${e.message.toString()} --- $done');
    }
    return done;
  }

  Future<void> SignOut(myID) async {
    await firebaseAuth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('IsLoggedIn', false);
    await cloud.collection("Users").document(myID).updateData({
      "isActive": false,
    });
  }
}