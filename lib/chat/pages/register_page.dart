import 'package:chat/chat/services/auth/auth_service.dart';
import 'package:chat/chat/components/my_button.dart';
import 'package:chat/chat/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirnPwController = TextEditingController();

  final VoidCallback onTap;

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) {
    final auth = AuthService();
    if (passwordController.text == confirnPwController.text) {
      try {
        auth.signUpWithEmailPassword(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else{
       if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) =>const AlertDialog(
            title: Text("Passwords don't match!"),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message,
              size: 60,
            ),
            const SizedBox(height: 50),
            const Text(
              "Let's create an account for you",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(height: 20),
            MyTextField(
              hintText: "password",
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(height: 25),
            MyTextField(
              hintText: "Confirm password",
              obscureText: true,
              controller: confirnPwController,
            ),
            const SizedBox(height: 20),
            MyButton(
              text: "Register",
              onTap: ()=>register(context),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not a member? ",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
