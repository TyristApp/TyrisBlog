import 'package:flutter/material.dart';
import 'package:tyrisblog/Const/AppColors.dart';

class InputText extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isObscure;
  final double? width;
  final Color fillColor;
  final Color hintColor;
  final Color borderColor;
  final Color focusedBorderColor;

  const InputText({
    Key? key,
    required this.placeholder,
    required this.controller,
    this.width,
    this.keyboardType = TextInputType.text,
    this.isObscure = false,
    this.fillColor = AppColors.white,
    this.hintColor = AppColors.black,
    this.borderColor = AppColors.black,
    this.focusedBorderColor = AppColors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: width ?? constraints.maxWidth,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              hintText: placeholder,
              hintStyle: TextStyle(
                color: hintColor,
                fontFamily: 'Poppins',
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: focusedBorderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
