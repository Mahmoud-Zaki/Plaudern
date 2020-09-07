import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plaudern/Controllers/FBController.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';
import 'Home.dart';

class Explore extends StatefulWidget {

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Firestore cloud = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return RequestScreen(
      scafold: StreamBuilder(
          stream: cloud.collection('Users').snapshots(),
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
                  bool IsMe = false;
                  if(db["ID"] == myID) IsMe = true;
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Material(
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: (){
                                FirebaseController.instanace.moveTochatRoom(
                                    context: context,
                                    myID: myID,
                                    myName: myName,
                                    myPhoto: myPhoto,
                                    selectedUserID: db["ID"],
                                    selectedUserName: db["username"],
                                    selectedUserPhoto: db["userphoto"]
                                );
                              },
                              leading: (db["userphoto"] == "")?CircleAvatar(
                                radius: 25.0,
                                backgroundColor: Colors.grey,
                                child: db["isActive"] != null?Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: db["isActive"]?
                                        Theme.of(context).primaryColor: Colors.transparent,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(100.0)
                                  ),
                                  child: Center(child: Icon(Icons.person,size: 30.0,color: Theme.of(context).accentColor,)),
                                ):Container(),
                              ):CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(db["userphoto"]),
                                radius: 25.0,
                                child: db["isActive"] != null?Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: db["isActive"]?
                                        Theme.of(context).primaryColor: Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(100.0)
                                  ),
                                ):Container(),
                              ),
                              title: (IsMe)? Text('ME'):Text(db["username"]),
                              trailing: Icon(Icons.message,
                                  color: db["isActive"]?
                                  Theme.of(context).primaryColor: Colors.grey),
                              isThreeLine: false,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
      ),
    );
  }
}