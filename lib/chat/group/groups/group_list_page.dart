import 'package:chat/chat/group/groups/group_chat_page.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/services/chat/group_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupListPage extends StatelessWidget {
  final GroupService groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Text('Groups'),
          IconButton(onPressed:logout , icon: Icon(Icons.logout),)
        ],
      )),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading groups'));
          }

          final groups = snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group['groupName']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatPage(
                        groupID: group.id,
                        groupName: group['groupName'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createGroup(context); // Вызов функции создания группы
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void createGroup(BuildContext context) async {
    final TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Group'),
        content: TextField(
          controller: groupNameController,
          decoration: InputDecoration(hintText: 'Enter group name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалоговое окно
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final groupName = groupNameController.text.trim();

              if (groupName.isNotEmpty) {
                // Добавляем группу в Firestore
                await FirebaseFirestore.instance.collection('groups').add({
                  'groupName': groupName,
                  'members': [], // Начинаем с пустым списком участников
                });

                Navigator.pop(context); // Закрыть диалоговое окно
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group "$groupName" created!')),
                );
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }
}
