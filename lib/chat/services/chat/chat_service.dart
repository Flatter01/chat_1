import 'package:chat/chat/models/message.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMassage(String receivaerID, message) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message nowMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receivaerID: receivaerID,
      massage: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receivaerID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("massages")
        .add(nowMessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");
    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("massages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> sendMessageToGroup(String groupID, String message) async {
    final currentUserID = AuthService().getCurrentUser()!.uid;
    await firestore
        .collection('groups')
        .doc(groupID)
        .collection('messages')
        .add({
      'senderID': currentUserID,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getGroupMessages(String groupID) {
    return firestore
        .collection('groups')
        .doc(groupID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
