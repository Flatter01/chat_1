import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  const MyTextField({super.key, required this.hintText,required this.obscureText,required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          fillColor: Colors.grey.shade400,
          filled: true,
          hintText: hintText,
          hintStyle:const TextStyle(color: Colors.black)
        ),
      ),
    );
  }
}
