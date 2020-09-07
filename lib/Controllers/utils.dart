import 'package:intl/intl.dart';

const APP_ID = '5ec41957c92140bc96f3d889b50df468';

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    if (diff.inHours > 0) {
      (diff.inHours == 1)? time = diff.inHours.toString() + ' hour ago' :
      time = diff.inHours.toString() + ' hours ago';
    } else if (diff.inMinutes > 0) {
      (diff.inMinutes == 1)? time = diff.inMinutes.toString() + ' minute ago' :
      time = diff.inMinutes.toString() + ' minutes ago';
    } else if (diff.inSeconds > 0) {
      time = 'Now';
    } else if (diff.inMilliseconds > 0) {
      time = 'Now';
    } else if (diff.inMicroseconds > 0) {
      time = 'Now';
    } else {
      time = 'Now';
    }
  } else if (diff.inDays == 1) {
      time = '1 day ago';
  } else if (diff.inDays % 7 == 0) {
    (diff.inDays / 7 == 1)? time = (diff.inDays / 7).floor().toString() + ' week ago' :
    time = (diff.inDays / 7).floor().toString() + ' weeks ago';
  } else if (diff.inDays % 30 == 0) {
    (diff.inDays / 30 == 1)? time = (diff.inDays / 30).floor().toString() + ' month ago' :
    time = (diff.inDays / 30).floor().toString() + ' months ago';
  } else if(diff.inDays % 365 == 0){
    (diff.inDays / 365 == 1)? time = (diff.inDays / 365).floor().toString() + ' year ago' :
    time = (diff.inDays / 365).floor().toString() + ' years ago';
  } else if(diff.inDays > 1){
    time = diff.inDays.toString() + ' days ago';
  }
  return time;
}

String makeChatId(myID, selectedUserID) {
  String chatID;
  if (myID.hashCode > selectedUserID.hashCode) {
    chatID = '$selectedUserID-$myID';
  } else {
    chatID = '$myID-$selectedUserID';
  }
  return chatID;
}

String returnTimeStamp(int messageTimeStamp) {
  String resultString = '';
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(messageTimeStamp);
  resultString = format.format(date);
  return resultString;
}