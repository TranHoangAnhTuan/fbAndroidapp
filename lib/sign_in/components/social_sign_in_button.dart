import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final String imageUrl;
  final double width;

  const SocialSignInButton({
    super.key,
    required this.imageUrl,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle social sign in
      },
      child: Image.network(
        imageUrl,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}