import 'package:chat/chat/components/user_tile.dart';
import 'package:chat/chat/pages/chat_page.dart';
import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/components/my_drawer.dart';
import 'package:chat/chat/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    debugPrint("Check....");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.grey.shade700,
      ),
      drawer: MyDrawer(),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
        debugPrint("Check..../");

    return StreamBuilder(
      stream: chatService.getUsersStream(),
      builder: (context, snapshot) {
                debugPrint("Check....//");

        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
                debugPrint("Check....///");

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }
}

Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  return UserTile(
    text: userData["email"],
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverEmail: userData["email"],
          ),
        ),
      );
    },
  );
}
