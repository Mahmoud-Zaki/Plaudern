import 'package:flutter/material.dart';

CircleAvatar checkReadMSGUI(chatListSnapshot, notReadMSGSnapshot) {
  return CircleAvatar(
    radius: 9,
    child: Text(
      (chatListSnapshot.hasData && chatListSnapshot.data.documents.length > 0)
          ? ((notReadMSGSnapshot.hasData &&
          notReadMSGSnapshot.data.documents.length > 0)
          ? '${notReadMSGSnapshot.data.documents.length}'
          : '')
          : '',
      style: TextStyle(fontSize: 10),
    ),
    backgroundColor: (notReadMSGSnapshot.hasData &&
        notReadMSGSnapshot.data.documents.length > 0 &&
        notReadMSGSnapshot.hasData &&
        notReadMSGSnapshot.data.documents.length > 0)
        ? Color(0xFF3EBACE)
        : Colors.transparent,
    foregroundColor: Colors.white,
  );
}