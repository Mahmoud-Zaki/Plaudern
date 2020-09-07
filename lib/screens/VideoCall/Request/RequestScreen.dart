import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plaudern/screens/Home.dart';
import 'package:plaudern/screens/VideoCall/Request/Request.dart';

class RequestScreen extends StatefulWidget{
  Widget scafold;
  RequestScreen({this.scafold});
  @override
  RequestScreenState createState()=>RequestScreenState();
}

class RequestScreenState extends State<RequestScreen>{
  bool isCalling = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('Calling').document(myID.toString()).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            var call = snapshot.data;
              if(call.data != null){
                if(call['isCalling'] != isCalling)
                  isCalling = call['isCalling'];
                print(isCalling);
                return (isCalling == false)? widget.scafold : CallRequest(
                  name: call['fromname'],image: call['fromphoto'],chatID: call['chatID'],);
              } else
                return widget.scafold;
          } else
            return widget.scafold;
        },
      ),
    );
  }
}