import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/sign_up.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class WelcomScreen extends StatefulWidget {
  static const String id = '/welcome_screen';
  const WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                SizedBox(height: 100, child: Image.asset('images/logo.jpg')),
                Text(
                  'let\'s Chat',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 30),
              ],
            ),
            CustomButton(
              color: Colors.yellow[800]!,
              title: 'Login In',
              onPress: () => Navigator.pushNamed(context, Login.id),
            ),

            SizedBox(height: 12),

            CustomButton(
              color: Colors.blue[800]!,
              title: 'Sign Up',
              onPress: () => Navigator.pushNamed(context, SignUp.id),
            ),
          ],
        ),
      ),
    );
  }
}
