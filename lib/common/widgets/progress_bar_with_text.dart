import 'package:flutter/material.dart';

class ProgressBarWithText extends StatelessWidget {
  final String text;
  const ProgressBarWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
