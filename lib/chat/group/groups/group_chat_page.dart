import 'package:chat/chat/components/chat_bubble.dart';
import 'package:chat/chat/components/my_textfield.dart';
import 'package:chat/chat/group/provider/group_details_screen.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/services/chat/group_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatPage extends StatefulWidget {
  final String groupID;
  final String groupName;

  GroupChatPage({super.key, required this.groupID, required this.groupName});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final GroupService groupService = GroupService();
  final AuthService authService = AuthService();

  bool isMember = false;
  bool isAdmin = false;
  bool isLoading = true;
  String currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    checkMembershipAndAdmin();
  }

  Future<void> checkMembershipAndAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        isLoading = false;
        isMember = false;
        isAdmin = false;
      });
      return;
    }

    currentUserEmail = currentUser.email ?? '';
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupID)
          .get();

      if (groupDoc.exists) {
        List<dynamic> members = groupDoc['members'] ?? [];
        List<dynamic> admins = groupDoc['admins'] ?? [];

        setState(() {
          isMember = members.contains(currentUserEmail);
          isAdmin = admins.contains(currentUserEmail);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: \$e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addAdmin() async {
    final email = adminEmailController.text.trim();
    if (email.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupID)
          .update({
        'admins': FieldValue.arrayUnion([email]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\$email назначен администратором')));
      adminEmailController.clear();
      checkMembershipAndAdmin();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupID)
          .collection('messages')
          .doc(messageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение удалено!')),
      );
    } catch (e) {
      print("Error deleting message: \$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении сообщения')),
      );
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty && isMember) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        final senderEmail = currentUser!.email ?? 'Unknown User';
        await groupService.sendMessageToGroup(
            widget.groupID, messageController.text, senderEmail);
        messageController.clear();
      } catch (e) {
        print('Error: \$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.groupName)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(widget.groupName)),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsScreen(
                      groupName: widget.groupName,
                      groupId: widget.groupID,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isAdmin) buildAdminControls(),
          Expanded(child: buildMessageList()),
          buildUserInput(),
        ],
      ),
    );
  }

  Widget buildAdminControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MyTextField(
                  hintText: "Введите email",
                  obscureText: false,
                  controller: adminEmailController,
                ),
              ),
              ElevatedButton(
                onPressed: addAdmin,
                child: Text("Подтвердить"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: groupService.getGroupMessages(widget.groupID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final senderEmail = data["senderName"] ?? 'Unknown User';
    final isCurrentUser = senderEmail == currentUserEmail;
    Timestamp? timestamp = data["timestamp"];
    String formattedTime =
        timestamp != null ? DateFormat("HH:mm").format(timestamp.toDate()) : "";

    return GestureDetector(
      onLongPress: () {
        if (isAdmin) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Удалить сообщение?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Отмена"),
                ),
                TextButton(
                  onPressed: () {
                    deleteMessage(doc.id);
                    Navigator.pop(context);
                  },
                  child: Text("Удалить", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(senderEmail,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ChatBubble(
                message: data["message"] ?? '', isCurrentUser: isCurrentUser),
            Text(formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: "Введите сообщение...",
              obscureText: false,
              controller: messageController,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
