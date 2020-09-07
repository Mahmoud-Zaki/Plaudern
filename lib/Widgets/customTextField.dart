import 'package:flutter/material.dart';

Container customTextField({sendText, sendImage, TextEditingController msgTextController}) {
  return Container(
    padding: EdgeInsets.all(10),
    color: Colors.transparent,
    child: Row(
      children: <Widget>[
        IconButton(icon: Icon(Icons.image,color: Colors.grey,),onPressed: sendImage),
        SizedBox(width: 10.0,),
        Flexible(
          child: TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Type a message ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Color(0xFF3EBACE), width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Color(0xFF3EBACE), width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
            controller: msgTextController,
            minLines: 1,
            maxLines: 5,
          ),
        ),
        IconButton(
          onPressed: sendText,
          icon: CircleAvatar(
            backgroundColor: Color(0xFF3EBACE),
            child: Center(
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    ),
  );
}