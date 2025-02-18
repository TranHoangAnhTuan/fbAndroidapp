import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        image: DecorationImage(
          image: NetworkImage('https://cdn.builder.io/api/v1/image/assets/fdcd3b480ad74ef88680204f18559404/8e640722bf789801ff07597959f57b19f51297856abfb99a7ae28dbee0a1a566?apiKey=fdcd3b480ad74ef88680204f18559404&'),
          fit: BoxFit.cover,
        ),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFF010101),
            fontSize: 15,
            fontWeight: FontWeight.w300,
            fontFamily: 'Inter',
            letterSpacing: 0.22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 21, vertical: 14),
        ),
      ),
    );
  }
}