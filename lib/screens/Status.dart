import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plaudern/Controllers/FBController.dart';
import 'package:plaudern/Controllers/utils.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';
import 'package:plaudern/screens/full_screen_statue.dart';
import 'Home.dart';

class Status extends StatefulWidget {

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  Firestore cloud = Firestore.instance;
  List _list = [];
  @override
  Widget build(BuildContext context) {
    return RequestScreen(
      scafold: Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: cloud.collection('Status').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    var db = snapshot.data.documents[index];
                    FirebaseController.instanace
                        .deleteStatue(db["story"], db['dateandtime']);
                    bool IsMe = false;
                    if(db["iD"] == myID) IsMe = true;
                    if(!_list.contains(db["iD"])){
                      _list.add(db["iD"]);
                      return Column(
                        children: <Widget>[
                          SizedBox(height: 8.0),
                          Material(
                            color: Colors.transparent,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(db["story"]),
                                    radius: 25.0,
                                  ),
                                  title: (IsMe)? Text('ME'):Text(db["name"]),
                                  subtitle: Text(readTimestamp(db['dateandtime'])),
                                  onTap: (){
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => FullStatue(
                                        Status: snapshot.data.documents,
                                        index:index,
                                      ),
                                    ));
                                  },
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox(height: 0.0,);
                  },
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async{
              File imageFileFromLibrary = await ImagePicker.pickImage(
                  source: ImageSource.gallery);
              if (imageFileFromLibrary != null) {
                FirebaseController.instanace
                    .AddStatue(myID, myName, myPhoto, imageFileFromLibrary);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add,color: Theme.of(context).accentColor,),
          ),
      ),
    );
  }
}