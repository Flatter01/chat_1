import 'package:chat/chat/components/chat_bubble.dart';
import 'package:chat/chat/components/my_textfield.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receivaerID;
  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receivaerID,
  });

  final TextEditingController messageController = TextEditingController();

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  void sendMassage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMassage(receivaerID, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: buildMessageList(),
          ),
          buildUserInput(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: chatService.getMessage(receivaerID, senderID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading ...");
          }
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data["senderID"] == authService.getCurrentUser()!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["massage"], isCurrentUser: isCurrentUser)
        ],
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: "Type a massage",
              obscureText: false,
              controller: messageController,
            ),
          ),
          Container(
            decoration:const BoxDecoration(color: Colors.green,shape: BoxShape.circle),
            margin:const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMassage,
              icon: const Icon(Icons.arrow_upward,color: Colors.white,),
            ),
          )
        ],
      ),
    );
  }
}