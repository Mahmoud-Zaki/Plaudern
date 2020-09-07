import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plaudern/Controllers/FBController.dart';
import 'package:plaudern/screens/Home.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';
import 'package:plaudern/screens/VideoCall/VideoCall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Widgets/Bubble.dart';
import '../Controllers/utils.dart';
import '../Widgets/customTextField.dart';

class Chat extends StatefulWidget {
  Chat(this.myID, this.myName,this.myPhoto,
      this.selectedUserID, this.chatID,
      this.selectedUserName, this.selectedUserPhoto);

  final String myID;
  final String myName;
  final String myPhoto;
  final String selectedUserID;
  final String chatID;
  final String selectedUserName;
  final String selectedUserPhoto;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String messageType = 'text';

  ClientRole _role = ClientRole.Broadcaster;

  Firestore cloud = Firestore.instance;
  final TextEditingController _msgTextController = new TextEditingController();

  Future<void> _getUnreadMSGCount() async {
    try {
      int unReadMSGCount = 0;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myId = (prefs.get('MyId') ?? null);

      final QuerySnapshot chatListResult = await cloud
          .collection('Users')
          .document(myId)
          .collection('Messages')
          .getDocuments();

      final List<DocumentSnapshot> chatListDocuments = chatListResult.documents;
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await cloud
            .collection('ChatRoom')
            .document(data['chatID'])
            .collection(data['chatID'])
            .where('idTo', isEqualTo: myId)
            .where('isread', isEqualTo: false)
            .getDocuments();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.documents;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }
      FlutterAppBadger.updateBadgeCount(unReadMSGCount);
    } catch (e) {}
  }

  Future<void> onJoin() async {
    if (widget.chatID.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      try{
        cloud.collection("Calling").document(widget.selectedUserID).updateData({
          "fromname": widget.myName,
          "fromphoto": widget.myPhoto,
          "chatID": widget.chatID,
          "isCalling": true,
        });
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              channelName: widget.chatID,
              role: _role,
              id: widget.selectedUserID,
            ),
          ),
        );
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
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestScreen(
      scafold: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0XFF4E5B81),
              elevation: 0.9,
              title: widget.selectedUserName == null || widget.selectedUserName == ""
                  ? ""
                  : Text(widget.selectedUserName,
              ),
              leading: Container(
                margin: EdgeInsets.all(5.0),
                child: (widget.selectedUserPhoto == "")?CircleAvatar(
                  child: Center(child: Icon(Icons.person,color: Theme.of(context).accentColor,)),
                  backgroundColor: Colors.grey,
                ):CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(widget.selectedUserPhoto),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.videocam,
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: onJoin,
                ),
              ],
            ),
            body: VisibilityDetector(
              key: Key("1"),
              onVisibilityChanged: ((visibility) {
                print(visibility.visibleFraction);
                if (visibility.visibleFraction == 1.0) {
                  _getUnreadMSGCount();
                }
              }),
              child: StreamBuilder<QuerySnapshot>(
                stream: cloud
                    .collection('ChatRoom')
                    .document(widget.chatID)
                    .collection(widget.chatID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return LinearProgressIndicator();
                  else {
                    _getUnreadMSGCount();
                    for (var data in snapshot.data.documents) {
                      if (data['idTo'] == widget.myID) {
                        cloud.runTransaction((Transaction myTransaction) async {
                          await myTransaction
                              .update(data.reference, {'isread': true});
                        });
                      }
                    }
                  }
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                            reverse: true,
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(4.0, 10, 4, 10),
                            children: snapshot.data.documents.reversed.map((data) {
                              return data['idFrom'] == widget.selectedUserID
                                  ? Bubble(
                                time: returnTimeStamp(data['timestamp']),
                                delivered: data['isread'],
                                message: data['content'],
                                type: data['type'],
                                isMe: true,
                              )
                                  : Bubble(
                                time: returnTimeStamp(data['timestamp']),
                                delivered: data['isread'],
                                message: data['content'],
                                type: data['type'],
                                isMe: false,
                              );
                            }).toList()),
                      ),
                      customTextField(
                        sendText: () {
                          setState(()=> messageType = 'text');
                          FirebaseController.instanace.handleSubmitted(
                            chatID: widget.chatID,
                            myID: widget.myID,
                            messageType: messageType,
                            selectedUserID: widget.selectedUserID,
                            text: _msgTextController.text,
                          );
                          _msgTextController.clear();
                        },
                        sendImage: ()async{
                          File imageFileFromLibrary = await ImagePicker.pickImage(source:ImageSource.gallery);
                          if(imageFileFromLibrary != null){
                            setState(()=> messageType = "image");
                            FirebaseController.instanace.saveUserImageToFirebaseStorage(
                              chatID: widget.chatID,
                              image: imageFileFromLibrary,
                              messageType: messageType,
                              myID: widget.myID,
                              selectedUserID: widget.selectedUserID,
                            );
                          } else{
                            _showDialog('Something Wrong');
                          }
                        },
                        msgTextController: _msgTextController,
                      ),
                    ],
                  );
                },
              ),
            ),
      ),
    );
  }

  _showDialog(String msg) {
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
            content: Text(msg,
              style: TextStyle(color: Colors.black),),
          );
        });
  }
}