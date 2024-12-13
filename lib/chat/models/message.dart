import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receivaerID;
  final String massage;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receivaerID,
    required this.massage,
    required this.timestamp,
  });

  Map<String,dynamic> toMap(){
    return {
      "senderID" : senderID,
      "senderEmail" : senderEmail,
      "receivaerID" : receivaerID,
      "massage" : massage,
      "timestamp" : timestamp
    };
  }
}
