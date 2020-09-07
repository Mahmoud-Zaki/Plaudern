import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plaudern/screens/Home.dart';
import 'package:plaudern/screens/VideoCall/VideoCall.dart';

class CallRequest extends StatelessWidget {

  String name,image,chatID;
  ClientRole _role = ClientRole.Broadcaster;

  CallRequest({this.name, this.image,this.chatID});

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.05,
                ),
                Text(
                  'Calling...',
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 17),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.02,
                ),
                Text(
                  name,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.1,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(200.0),
                  child: (image == '') ? Icon(
                    Icons.person,
                    size: 70.0,
                    color: Theme.of(context).accentColor,
                  ):Image.network(
                    image,
                    height: 200.0,
                    width: 200.0,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: MaterialButton(
                        height: 65,
                        onPressed: () async{
                          await _handleCameraAndMic();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallPage(
                                channelName: chatID,
                                role: _role,
                              ),
                            ),
                          );
                        },
                        elevation: 20.0,
                        shape: CircleBorder(side: BorderSide(color: Colors.green)),
                        child: Icon(
                          Icons.call,
                          color: Colors.green,
                        ),
                        color: Colors.green[100],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: MaterialButton(
                        height: 65,
                        onPressed: () {
                          Firestore.instance.collection("Calling").document(myID).updateData({
                            "isCalling": false,
                          });
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                                (route) => false,
                          );
                        },
                        elevation: 20.0,
                        shape: CircleBorder(side: BorderSide(color: Colors.red)),
                        child: Icon(
                          Icons.call_end,
                          color: Colors.red,
                        ),
                        color: Colors.red[100],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}