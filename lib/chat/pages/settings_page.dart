import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        foregroundColor: Colors.grey.shade700,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
    );
  }
}
