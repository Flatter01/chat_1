import 'package:chat/chat/group/provider/group_porovider.dart';
import 'package:chat/chat/services/auth/auth_gate.dart';
import 'package:chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()), 
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AuthGate(),
    );
  }
}
