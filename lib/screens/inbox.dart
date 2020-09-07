import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';
import '../Controllers/FBController.dart';
import '../Controllers/utils.dart';
import '../screens/chat_screen.dart';
import '../Widgets/checkReadMSGUI.dart';
import 'Home.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  Firestore cloud = Firestore.instance;

  @override
  void initState() {
    FirebaseController.instanace.getUnreadMSGCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RequestScreen(
      scafold: VisibilityDetector(
        key: Key("1"),
        onVisibilityChanged: ((visibility) {
          if (visibility.visibleFraction == 1.0) {
            FirebaseController.instanace.getUnreadMSGCount();
          }
        }),
        child: StreamBuilder<QuerySnapshot>(
          stream: cloud.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
                color: Colors.white.withOpacity(0.7),
              );
            }
            return ListView(
                children: snapshot.data.documents.map((data) {
              bool IsMe = false;
              if (data['ID'] == myID) {
                IsMe = true;
              }
              return StreamBuilder<QuerySnapshot>(
                stream: cloud
                    .collection('Users')
                    .document(myID)
                    .collection('Messages')
                    .where('chatWith', isEqualTo: data['ID'])
                    .snapshots(),
                builder: (context, chatListSnapshot) {
                  if (chatListSnapshot.data == null) {
                    return Container();
                  } else if (chatListSnapshot.data.documents.length == 0) {
                    return Container();
                  }
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Material(
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                FirebaseController.instanace.moveTochatRoom(
                                    context: context,
                                    myID: myID,
                                    myName: myName,
                                    myPhoto: myPhoto,
                                    selectedUserID: data["ID"],
                                    selectedUserName: data["username"],
                                    selectedUserPhoto: data["userphoto"]);
                              },
                              leading: (data["userphoto"] == "")
                                  ? CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey,
                                      child: data["isActive"] != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: data["isActive"]
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.transparent,
                                                    width: 4,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                              child: Center(
                                                  child: Icon(
                                                Icons.person,
                                                size: 25.0,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              )),
                                            )
                                          : Container(),
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              data["userphoto"]),
                                      radius: 25.0,
                                      child: data["isActive"] != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: data["isActive"]
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                            )
                                          : Container(),
                                    ),
                              title:
                                  (IsMe) ? Text('ME') : Text(data["username"]),
                              subtitle: Text(
                                chatListSnapshot.data.documents[0]['lastChat'],
                                maxLines: 1,
                              ),
                              trailing: StreamBuilder<QuerySnapshot>(
                                stream: cloud
                                    .collection("ChatRoom")
                                    .document(chatListSnapshot.data.documents[0]
                                        ['chatID'])
                                    .collection(chatListSnapshot
                                        .data.documents[0]['chatID'])
                                    .where('idTo', isEqualTo: myID)
                                    .where('isread', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, notReadMSGSnapshot) {
                                  return Column(
                                    children: <Widget>[
                                      Text(
                                        (chatListSnapshot.hasData &&
                                                chatListSnapshot
                                                        .data.documents.length >
                                                    0)
                                            ? readTimestamp(chatListSnapshot
                                                .data.documents[0]['timestamp'])
                                            : '',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      SizedBox(height: 3.0),
                                      checkReadMSGUI(
                                          chatListSnapshot, notReadMSGSnapshot),
                                    ],
                                  );
                                },
                              ),
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
            }).toList());
          },
        ),
      ),
    );
  }
}
