import 'package:flutter/material.dart';

/// Section widget for grouping configuration fields
class ConfigSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;
  
  const ConfigSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white, // White titles
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB0B0B0), // Muted grey text
              ),
            ),
            ],
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

