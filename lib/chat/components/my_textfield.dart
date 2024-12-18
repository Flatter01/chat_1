import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final bool isSearch;
  final VoidCallback? onSearchTap;
  final TextEditingController controller;
  const MyTextField({
    super.key,
    required this.hintText,
    this.onSearchTap,
    this.isSearch = false,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          suffixIcon: Visibility(
              visible: isSearch,
              child: IconButton(
                  onPressed: onSearchTap,
                  icon: Icon(
                    CupertinoIcons.search,
                    color: Colors.black,
                  ))),
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
          hintStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
