import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  CustomButton({required this.text, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue, // <- Ganti dari primary ke backgroundColor
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
