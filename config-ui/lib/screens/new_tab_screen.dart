import 'package:flutter/material.dart';

/// Screen for the New Tab
/// 
/// This screen displays an empty page as part of the New Tab functionality.
/// It follows the same structure as other configuration screens in the app.
class NewTabScreen extends StatelessWidget {
  const NewTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'New Tab',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
