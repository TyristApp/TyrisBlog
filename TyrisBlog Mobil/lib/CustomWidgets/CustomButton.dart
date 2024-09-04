import 'package:flutter/material.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final double width;

  CustomButton({
    required this.text,
    required this.color,
    required this.onPressed,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          textStyle: TextStyle(
            fontSize: (DeviceInfo.width / 40).clamp(15, 30),
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DeviceInfo.width / 20),
          ),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
