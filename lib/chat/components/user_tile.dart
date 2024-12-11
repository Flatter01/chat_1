import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.person),
          Text(text)
        ],
      ),
    );
  }
}
