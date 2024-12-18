import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Метод для создания группы
  Future<void> createGroup(String groupName, List<String> members) async {
    final groupId = FirebaseFirestore.instance.collection('groups').doc().id;

    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'groupName': groupName,
      'members': members,
    });
  }

  // Метод для отправки сообщения в группу
  Future<void> sendMessageToGroup(String groupID, String message, String senderName) async {
    try {
      await firestore.collection('groups').doc(groupID).collection('messages').add({
        'message': message,
        'senderID': FirebaseAuth.instance.currentUser!.uid,
        'senderName': senderName, // Имя отправителя
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка при отправке сообщения: $e');
    }
  }

  // Метод для получения сообщений группы
  Stream<QuerySnapshot> getGroupMessages(String groupID) {
    return firestore
        .collection('groups')
        .doc(groupID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
