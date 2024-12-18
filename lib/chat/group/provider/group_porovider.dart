import 'package:chat/chat/group/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createGroup(String groupName, List<String> members) async {
    try {
      await _firestore.collection('groups').add({
        'groupName': groupName,
        'members': members,
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Stream<List<Group>> getGroups() {
    return _firestore.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Group.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
