import 'package:flutter/material.dart';

/// Option A screen displaying a centered placeholder text.
/// 
/// This screen serves as a placeholder page that displays
/// "Here is the start page" in the center of the screen.
class OptionAScreen extends StatelessWidget {
  const OptionAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Here is the start page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
