import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget that displays text with clickable hyperlinks
class ClickableLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ClickableLinkText({
    super.key,
    required this.text,
    this.style,
  });

  /// Extract URLs from text and create TextSpan with clickable links
  List<TextSpan> _parseText(String text) {
    final List<TextSpan> spans = [];
    final RegExp urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );

    int lastMatchEnd = 0;
    final Iterable<RegExpMatch> matches = urlRegex.allMatches(text);

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
        ));
      }

      // Add clickable URL
      final String url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          color: const Color(0xFF2196F3), // Blue color for links
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last URL
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
      ));
    }

    // If no URLs found, return the whole text as a single span
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: _parseText(text),
      ),
    );
  }
}

