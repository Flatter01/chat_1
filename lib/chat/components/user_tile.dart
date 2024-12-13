import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding:const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.person,
              color: Colors.black,
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
