/// Atlassian Document Format (ADF) helper
/// Converts plain text and markdown to ADF JSON format required by Jira API v3
/// 
/// ADF is a JSON-based format for rich text fields in Jira.
/// Reference: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/

/// Converts plain text to ADF format
Map<String, dynamic> textToAdf(String text) {
  if (text.isEmpty) {
    return _emptyAdf();
  }

  // Split text into paragraphs
  final lines = text.split('\n');
  final content = <Map<String, dynamic>>[];

  for (final line in lines) {
    if (line.trim().isEmpty) {
      // Empty line - add empty paragraph
      content.add(_paragraphNode([]));
    } else {
      // Regular text line
      content.add(_paragraphNode([_textNode(line)]));
    }
  }

  return {
    'version': 1,
    'type': 'doc',
    'content': content.isNotEmpty ? content : [_paragraphNode([])],
  };
}

/// Converts markdown-style text to ADF format
/// Supports:
/// - **bold**
/// - *italic*
/// - [link](url)
/// - # headers
/// - * bullet lists
/// - 1. numbered lists
/// - `code`
Map<String, dynamic> markdownToAdf(String markdown) {
  if (markdown.isEmpty) {
    return _emptyAdf();
  }

  final lines = markdown.split('\n');
  final content = <Map<String, dynamic>>[];
  
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (line.trim().isEmpty) {
      continue; // Skip empty lines
    }
    
    // Headers: # Header
    if (line.startsWith('#')) {
      final level = line.indexOf(' ');
      if (level > 0 && level <= 6) {
        final text = line.substring(level + 1).trim();
        content.add(_headingNode(level, text));
        continue;
      }
    }
    
    // Bullet list: * item or - item
    if (line.startsWith('* ') || line.startsWith('- ')) {
      final items = <String>[];
      items.add(line.substring(2).trim());
      
      // Collect consecutive list items
      while (i + 1 < lines.length && 
             (lines[i + 1].startsWith('* ') || lines[i + 1].startsWith('- '))) {
        i++;
        items.add(lines[i].substring(2).trim());
      }
      
      content.add(_bulletListNode(items));
      continue;
    }
    
    // Numbered list: 1. item
    if (RegExp(r'^\d+\.\s').hasMatch(line)) {
      final items = <String>[];
      items.add(line.replaceFirst(RegExp(r'^\d+\.\s'), '').trim());
      
      // Collect consecutive list items
      while (i + 1 < lines.length && RegExp(r'^\d+\.\s').hasMatch(lines[i + 1])) {
        i++;
        items.add(lines[i].replaceFirst(RegExp(r'^\d+\.\s'), '').trim());
      }
      
      content.add(_orderedListNode(items));
      continue;
    }
    
    // Regular paragraph with inline formatting
    content.add(_paragraphNode(_parseInlineFormatting(line)));
  }

  return {
    'version': 1,
    'type': 'doc',
    'content': content.isNotEmpty ? content : [_paragraphNode([])],
  };
}

/// Creates an empty ADF document
Map<String, dynamic> _emptyAdf() {
  return {
    'version': 1,
    'type': 'doc',
    'content': [_paragraphNode([])],
  };
}

/// Creates a text node
Map<String, dynamic> _textNode(String text, {List<Map<String, dynamic>>? marks}) {
  final node = <String, dynamic>{
    'type': 'text',
    'text': text,
  };
  
  if (marks != null && marks.isNotEmpty) {
    node['marks'] = marks;
  }
  
  return node;
}

/// Creates a paragraph node
Map<String, dynamic> _paragraphNode(List<Map<String, dynamic>> content) {
  return {
    'type': 'paragraph',
    'content': content.isNotEmpty ? content : [_textNode('')],
  };
}

/// Creates a heading node
Map<String, dynamic> _headingNode(int level, String text) {
  return {
    'type': 'heading',
    'attrs': {'level': level.clamp(1, 6)},
    'content': [_textNode(text)],
  };
}

/// Creates a bullet list node
Map<String, dynamic> _bulletListNode(List<String> items) {
  return {
    'type': 'bulletList',
    'content': items.map((item) => {
      'type': 'listItem',
      'content': [_paragraphNode([_textNode(item)])],
    }).toList(),
  };
}

/// Creates an ordered (numbered) list node
Map<String, dynamic> _orderedListNode(List<String> items) {
  return {
    'type': 'orderedList',
    'content': items.map((item) => {
      'type': 'listItem',
      'content': [_paragraphNode([_textNode(item)])],
    }).toList(),
  };
}

/// Parses inline formatting (bold, italic, code, links)
List<Map<String, dynamic>> _parseInlineFormatting(String text) {
  final nodes = <Map<String, dynamic>>[];
  var remaining = text;
  
  // Simple regex patterns
  final boldPattern = RegExp(r'\*\*(.+?)\*\*');
  final italicPattern = RegExp(r'\*(.+?)\*');
  final codePattern = RegExp(r'`(.+?)`');
  final linkPattern = RegExp(r'\[(.+?)\]\((.+?)\)');
  
  while (remaining.isNotEmpty) {
    // Find the earliest match
    Match? nextMatch;
    String? matchType;
    var minIndex = remaining.length;
    
    final boldMatch = boldPattern.firstMatch(remaining);
    if (boldMatch != null && boldMatch.start < minIndex) {
      nextMatch = boldMatch;
      matchType = 'bold';
      minIndex = boldMatch.start;
    }
    
    final italicMatch = italicPattern.firstMatch(remaining);
    if (italicMatch != null && italicMatch.start < minIndex) {
      nextMatch = italicMatch;
      matchType = 'italic';
      minIndex = italicMatch.start;
    }
    
    final codeMatch = codePattern.firstMatch(remaining);
    if (codeMatch != null && codeMatch.start < minIndex) {
      nextMatch = codeMatch;
      matchType = 'code';
      minIndex = codeMatch.start;
    }
    
    final linkMatch = linkPattern.firstMatch(remaining);
    if (linkMatch != null && linkMatch.start < minIndex) {
      nextMatch = linkMatch;
      matchType = 'link';
      minIndex = linkMatch.start;
    }
    
    if (nextMatch == null) {
      // No more formatting - add remaining text
      if (remaining.isNotEmpty) {
        nodes.add(_textNode(remaining));
      }
      break;
    }
    
    // Add text before match
    if (nextMatch.start > 0) {
      nodes.add(_textNode(remaining.substring(0, nextMatch.start)));
    }
    
    // Add formatted text
    switch (matchType) {
      case 'bold':
        nodes.add(_textNode(
          nextMatch.group(1)!,
          marks: [{'type': 'strong'}],
        ));
        break;
      case 'italic':
        nodes.add(_textNode(
          nextMatch.group(1)!,
          marks: [{'type': 'em'}],
        ));
        break;
      case 'code':
        nodes.add(_textNode(
          nextMatch.group(1)!,
          marks: [{'type': 'code'}],
        ));
        break;
      case 'link':
        nodes.add({
          'type': 'text',
          'text': nextMatch.group(1)!,
          'marks': [
            {
              'type': 'link',
              'attrs': {'href': nextMatch.group(2)!},
            }
          ],
        });
        break;
    }
    
    // Continue with remaining text
    remaining = remaining.substring(nextMatch.end);
  }
  
  return nodes.isNotEmpty ? nodes : [_textNode(text)];
}

/// Converts ADF back to plain text (for display/debugging)
String adfToText(Map<String, dynamic> adf) {
  final content = adf['content'] as List? ?? [];
  final buffer = StringBuffer();
  
  for (final node in content) {
    final nodeMap = node as Map<String, dynamic>;
    _adfNodeToText(nodeMap, buffer);
    buffer.write('\n');
  }
  
  return buffer.toString().trim();
}

void _adfNodeToText(Map<String, dynamic> node, StringBuffer buffer) {
  final type = node['type'] as String;
  
  switch (type) {
    case 'paragraph':
      final content = node['content'] as List? ?? [];
      for (final child in content) {
        _adfNodeToText(child as Map<String, dynamic>, buffer);
      }
      break;
      
    case 'text':
      buffer.write(node['text'] as String? ?? '');
      break;
      
    case 'heading':
      final level = (node['attrs'] as Map?)?['level'] as int? ?? 1;
      buffer.write('${'#' * level} ');
      final content = node['content'] as List? ?? [];
      for (final child in content) {
        _adfNodeToText(child as Map<String, dynamic>, buffer);
      }
      break;
      
    case 'bulletList':
    case 'orderedList':
      final content = node['content'] as List? ?? [];
      for (var i = 0; i < content.length; i++) {
        final item = content[i] as Map<String, dynamic>;
        if (type == 'bulletList') {
          buffer.write('* ');
        } else {
          buffer.write('${i + 1}. ');
        }
        _adfNodeToText(item, buffer);
        buffer.write('\n');
      }
      break;
      
    case 'listItem':
      final content = node['content'] as List? ?? [];
      for (final child in content) {
        _adfNodeToText(child as Map<String, dynamic>, buffer);
      }
      break;
  }
}


