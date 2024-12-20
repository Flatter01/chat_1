import 'package:chat/chat/group/groups/group_list_page.dart';
import 'package:chat/chat/services/auth/login_or_register.dart';
import 'package:chat/chat/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // return HomePage();
            return GroupListPage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
