import 'package:chat/chat/components/chat_bubble.dart';
import 'package:chat/chat/components/my_textfield.dart';
import 'package:chat/chat/group/provider/group_details_screen.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/services/chat/group_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ScrollController scrollController = ScrollController();
  bool isButtonVisible = false;

  bool isMember = false;
  bool isAdmin = false;
  bool isLoading = true;
  String currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    checkMembershipAndAdmin();
    scroll();
  }

  void scroll() {
    scrollController.addListener(() {
      // Проверяем, если скроллинг идет вверх
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Показываем кнопку, если мы не находимся в самом низу
        if (scrollController.position.pixels <
            scrollController.position.maxScrollExtent) {
          if (!isButtonVisible) {
            setState(() {
              isButtonVisible = true;
            });
          }
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Скрываем кнопку, когда прокручиваем вниз и достигли самого низа
        if (scrollController.position.atEdge &&
            scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
          setState(() {
            isButtonVisible = false;
          });
        }
      }
    });
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

        // Если пользователь не является участником, добавляем его
        if (!members.contains(currentUserEmail)) {
          joinGroup(); // Добавление пользователя в группу
        }

        setState(() {
          isMember = members.contains(currentUserEmail);
          isAdmin = admins.contains(currentUserEmail);
          isLoading = false;
        });
      } else {
        setState(() {
          isMember = false;
          isAdmin = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> joinGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupID)
          .get();

      if (groupDoc.exists) {
        List<dynamic> members = groupDoc['members'] ?? [];

        if (!members.contains(currentUser.email)) {
          // Добавляем пользователя в список участников
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupID)
              .update({
            'members': FieldValue.arrayUnion([currentUser.email]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Вы стали участником группы!')),
          );

          // Обновляем состояние
          setState(() {
            isMember = true;
          });
        }
      }
    } catch (e) {
      print("Ошибка при добавлении участника: $e");
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
          SnackBar(content: Text('$email назначен администратором')));
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
      print("Error deleting message: $e");
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
        print('Error: $e');
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
          controller: scrollController,
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
              message: data["message"] ?? '',
              isCurrentUser: isCurrentUser,
              imageUrl: 'https://via.placeholder.com/150',
            ),
            Text(formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildUserInput() {
    return isMember
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hintText: "Введите сообщение...",
                    controller: messageController,
                    obscureText: false,
                  ),
                ),
                Column(
                  children: [
                    if (isButtonVisible)
                      FloatingActionButton(
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController
                                .position.maxScrollExtent, // Прокрутка вниз
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Icon(Icons.keyboard_arrow_down),
                      ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          )
        : const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Вы не являетесь участником этой группы.",
              style: TextStyle(color: Colors.red),
            ),
          );
  }
}
