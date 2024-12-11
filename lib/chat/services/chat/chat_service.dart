import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Map<String,dynamic>>> getUsersStream(){
      return firestore.collection("User").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        final user = doc.data();
        return user;
      }).toList();
    });
  }
}