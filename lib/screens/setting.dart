import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plaudern/Controllers/FBController.dart';
import 'package:plaudern/Controllers/user_auth.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';
import 'Home.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget{

  @override
  SettingScreenState createState() =>SettingScreenState();
}

class SettingScreenState extends State<SettingScreen>{

  final _formKey = GlobalKey<FormState>();
  String _userName;

  @override
  Widget build(BuildContext context) {
    return RequestScreen(
      scafold: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: (myPhoto == "")
                      ? CircleAvatar(
                    child: Center(
                        child: Icon(
                          Icons.person,
                          size: 70.0,
                          color: Theme.of(context).accentColor,
                        )),
                    radius: 64.0,
                    backgroundColor: Colors.grey,
                  )
                      : CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(myPhoto),
                    radius: 64.0,
                  ),
                  onTap: PhotoDialoge,
                ),
                SizedBox(height: 60,),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    myName,
                    style: GoogleFonts.lato(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: NameDialog,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text(
                    myEmail,
                    style: GoogleFonts.lato(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.lato(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    UserAuth().SignOut(myID);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PhotoDialoge(){
    return showDialog(
      context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            content: Text('Do you want to update the profile picture?',
              style: TextStyle(color: Colors.black),),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text('No',style: TextStyle(color: Colors.black),),
              ),
              FlatButton(
                onPressed: () async{
                  File imageFileFromLibrary = await ImagePicker.pickImage(source:ImageSource.gallery);
                  if(imageFileFromLibrary != null){
                    Navigator.of(context).pop();
                    final _photo = await FirebaseController.instanace
                        .saveUserImage(imageFileFromLibrary, myID);
                      setState(() {
                        myPhoto = _photo.toString();
                      });
                  }
                },
                child: Text('Yes',style: TextStyle(color: Colors.black),),
              )
            ],
          );
      });
  }

  NameDialog(){
    return showDialog(
      context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
                autofocus: false,
                validator: (name){
                  Pattern pattern =
                      r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(name))
                    return 'Invalid username';
                  else
                    return null;
                },
                onSaved: (name)=> _userName = name,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Name ...',
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text('Cancel',style: TextStyle(color: Colors.black),),
              ),
              FlatButton(
                onPressed: () async{
                  if(_formKey.currentState.validate()){
                    _formKey.currentState.save();
                    try{
                      await Firestore.instance
                          .collection("Users")
                          .document(myID)
                          .updateData({
                        "username": _userName,
                      });
                      setState(() {
                        myName=_userName;
                      });
                    }catch(e){
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              content: Text(e.message.toString(),
                                style: TextStyle(color: Colors.black),),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel',style: TextStyle(color: Colors.black),),
                                )
                              ],
                            );
                          });
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save',style: TextStyle(color: Colors.black),),
              ),
            ],
          );
        }
    );
  }
}