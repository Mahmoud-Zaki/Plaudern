import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:plaudern/Controllers/utils.dart';
import 'package:plaudern/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseController {
  static FirebaseController get instanace => FirebaseController();
  final cloud= Firestore.instance;
  // ignore: missing_return
  Future<String> saveUserImage(imgFile, userID) async {
    try {
      String result = '';
      String filePath = 'usersImages/$userID';
      StorageReference storageReference =
      FirebaseStorage().ref().child(filePath);
      StorageUploadTask uploadTask = storageReference.putFile(imgFile);
      await uploadTask.onComplete;
      await storageReference.getDownloadURL().then((fileURL) async{
        result = fileURL.toString();
        await cloud
            .collection("Users")
            .document(userID)
            .updateData({
          "userphoto": result,
        });
      });
      return result;
    } catch (e) {
      print(e.message.toString());
    }
  }

  // ignore: missing_return
  Future<int> getUnreadMSGCount([String peerUserID]) async {
    try {
      int unReadMSGCount = 0;
      String targetID = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();

      peerUserID == null
          ? targetID = (prefs.get('MyId') ?? 'NoId')
          : targetID = peerUserID;
      final QuerySnapshot chatListResult = await cloud
          .collection('Users')
          .document(targetID)
          .collection('Messages')
          .getDocuments();
      final List<DocumentSnapshot> chatListDocuments = chatListResult.documents;
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await cloud
            .collection('ChatRoom')
            .document(data['chatID'])
            .collection(data['chatID'])
            .where('idTo', isEqualTo: targetID)
            .where('isread', isEqualTo: false)
            .getDocuments();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.documents;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }
      if (peerUserID == null) {
        FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        return null;
      } else {
        return unReadMSGCount;
      }
    } catch (e) {}
  }

  Future<void> updateChatRequestField({documentID,lastMessage,chatID,myID,selectedUserID}) async {
    await cloud
        .collection('Users')
        .document(documentID)
        .collection('Messages')
        .document(chatID)
        .setData({
      'chatID': chatID,
      'chatWith': documentID == myID ? selectedUserID : myID,
      'lastChat': lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> sendMessageToChatRoom(chatID,myID,selectedUserID,content,messageType) async {
    await cloud
        .collection('ChatRoom')
        .document(chatID)
        .collection(chatID)
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData({
      'idFrom': myID,
      'idTo': selectedUserID,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': content,
      'type': messageType,
      'isread': false,
    });
  }

  Future<void> moveTochatRoom({context,myID,myName,myPhoto,selectedUserID, selectedUserName, selectedUserPhoto}) async {
    try {
      String chatID = makeChatId(myID, selectedUserID);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Chat(myID,myName,myPhoto,
                  selectedUserID,chatID,selectedUserName,selectedUserPhoto),
        ),
      );
    } catch (e) {}
  }

  Future<void> handleSubmitted({text,chatID,messageType,myID,selectedUserID}) async {
    if(text !=''){
      try {
        cloud
            .collection('ChatRoom')
            .document(chatID)
            .collection(chatID)
            .document(DateTime.now().millisecondsSinceEpoch.toString())
            .setData({
          'idFrom': myID,
          'idTo': selectedUserID,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content': text,
          'type': messageType,
          'isread': false,
        });

        updateChatRequestField(
          chatID: chatID,myID: myID,documentID: selectedUserID,
          lastMessage: text,selectedUserID: selectedUserID,
        );
        updateChatRequestField(
          chatID: chatID,myID: myID,documentID: myID,
          lastMessage: text,selectedUserID: selectedUserID,
        );
      } catch (e) {
      }
    }
  }

  Future<void> saveUserImageToFirebaseStorage({chatID,image,selectedUserID,myID,messageType}) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();

      String filePath = 'chatrooms/${chatID}/$imageTimeStamp';
      StorageReference storageReference =
      FirebaseStorage().ref().child(filePath);
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      storageReference.getDownloadURL().then((downloadUrl) {
        saveImageToChatRoom(
            downloadUrl: downloadUrl,chatID: chatID,
            selectedUserID: selectedUserID,myID: myID,messageType: messageType,);
      }, onError: (err) {
      });
      return '';
    } catch (e) {
    }
  }

  Future<void> saveImageToChatRoom({downloadUrl,chatID,selectedUserID,myID,messageType}) async {
    try {
      cloud
          .collection('ChatRoom')
          .document(chatID)
          .collection(chatID)
          .document(DateTime.now().millisecondsSinceEpoch.toString())
          .setData({
        'idFrom': myID,
        'idTo': selectedUserID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'content': downloadUrl,
        'type': messageType,
        'isread': false,
      });

      updateChatRequestField(
        chatID: chatID,myID: myID,documentID: selectedUserID,
        lastMessage: 'Send Photo ...',selectedUserID: selectedUserID,
      );
      updateChatRequestField(
        chatID: chatID,myID: myID,documentID: myID,
        lastMessage: 'Send Photo ...',selectedUserID: selectedUserID,
      );
    } catch (e) {
    }
  }

  Future<void> AddStatue(myID,myName,myPhoto,myStory) async{
    try {
      String result;
      String filePath = 'Status/$myID';
      StorageReference storageReference =
      FirebaseStorage().ref().child(filePath);
      StorageUploadTask uploadTask = storageReference.putFile(myStory);
      await uploadTask.onComplete;
      storageReference.getDownloadURL().then((fileURL) async{
        result = fileURL.toString();
        final Date_Time=DateTime.now().millisecondsSinceEpoch;
        await cloud
            .collection('Status')
            .document(Date_Time.toString())
            .setData({
          'iD':myID,
          'name':myName,
          'photo':myPhoto,
          'story':result,
          'dateandtime':Date_Time,
        });
      });
    } catch (e) {
      print(e.message.toString());
    }
  }

  Future<void> deleteStatue(photoUrl,document) async{
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(document);
    var diff = now.difference(date);
    print(diff.inHours);
    if(diff.inHours >= 24) {
      try {
        StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(photoUrl);
        print('done get link');
        await cloud.collection('Status').document(document.toString()).delete();
        print('done cloud delete');
        await storageReference.delete();
        print('done storage delete');
      } catch (e) {
        print(e.message.toString());
      }
    }
  }
}