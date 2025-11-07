import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onPress;
  const CustomButton({
    required this.color,
    required this.title,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,

        padding: EdgeInsets.symmetric(vertical: 15),
        textStyle: TextStyle(fontSize: 20),
      ),
      onPressed: onPress,
      child: Text(title),
    );
  }
}
