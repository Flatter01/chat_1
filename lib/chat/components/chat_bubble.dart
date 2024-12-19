import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String imageUrl;
  final bool isCurrentUser;

  ChatBubble({
    required this.message,
    required this.imageUrl,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Аватарка только для других пользователей
        if (!isCurrentUser)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),

        // Сообщение с текстом и временем
        Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.green : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12.0),
                  topRight: const Radius.circular(12.0),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(12.0)
                      : const Radius.circular(0),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(12.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
