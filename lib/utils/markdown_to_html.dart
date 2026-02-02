/// Utility to convert markdown text to HTML for clipboard copy
/// Optimized for Adobe InDesign compatibility
library;

/// Convert markdown-formatted text to HTML
///
/// Handles:
/// - <u>underline</u> → <u>underline</u>
/// - **bold** → <strong>bold</strong>
/// - *italic* → <em>italic</em>
/// - ~~strikethrough~~ → <del>strikethrough</del>
/// - `code` → <code>code</code>
/// - \n\n (double newline) → paragraph break
/// - \n (single newline) → space (merge lines into continuous text)
///
/// Returns HTML that Adobe InDesign can import with proper formatting
String convertMarkdownToHtml(String markdown) {
  if (markdown.isEmpty) return '';

  // Process text in segments, preserving <u> tags
  final segments = _splitByUnderlineTags(markdown);

  // Process each segment
  final buffer = StringBuffer();
  for (final segment in segments) {
    if (segment.isUnderline) {
      // Process markdown inside the underline tag, then wrap with <u>
      final processed = _processSegmentMarkdown(segment.content);
      buffer.write('<u>$processed</u>');
    } else {
      // Regular text - process markdown
      final processed = _processSegmentMarkdown(segment.content);
      buffer.write(processed);
    }
  }

  // Now handle paragraph breaks
  final html = buffer.toString();

  // Split by double newlines for paragraphs
  final paragraphs = html.split(RegExp(r'\n\n+'));

  // For each paragraph, replace single newlines with spaces
  final processedParagraphs = paragraphs.map((paragraph) {
    // Replace single newlines with spaces to merge lines
    final merged = paragraph.replaceAll('\n', ' ');
    // Also collapse multiple spaces that might result
    final collapsed = merged.replaceAll(RegExp(r'\s+'), ' ');
    return '<p>$collapsed</p>';
  }).join('');

  // Wrap in proper HTML structure
  final fullHtml = '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>OCR Text</title>
</head>
<body>
$processedParagraphs
</body>
</html>''';

  return fullHtml;
}

/// Escape HTML special characters
String _escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

/// Extract plain text from markdown (for fallback)
String markdownToPlainText(String markdown) {
  if (markdown.isEmpty) return '';

  var result = markdown;

  // Remove <u>...</u> tags
  result = result.replaceAll(RegExp(r'<u>(.*?)</u>'), r'\1');

  // Remove **bold**
  result = result.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');

  // Remove *italic*
  result = result.replaceAll(RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'), r'\1');

  // Remove ~~strikethrough~~
  result = result.replaceAll(RegExp(r'~~([^~]+)~~'), r'\1');

  // Remove `code`
  result = result.replaceAll(RegExp(r'`([^`]+)`'), r'\1');

  // Normalize line breaks (convert \n\n to single newline for plain text)
  result = result.replaceAll(RegExp(r'\n\n+'), '\n\n');

  return result;
}

/// Helper class to track text segments
class _TextSegment {
  final String content;
  final bool isUnderline;

  _TextSegment(this.content, this.isUnderline);
}

/// Split text by <u>...</u> tags, preserving the content
List<_TextSegment> _splitByUnderlineTags(String text) {
  final segments = <_TextSegment>[];
  final regex = RegExp(r'<u>(.*?)</u>');

  int lastEnd = 0;
  for (final match in regex.allMatches(text)) {
    // Add text before this match
    if (match.start > lastEnd) {
      segments.add(_TextSegment(text.substring(lastEnd, match.start), false));
    }
    // Add underlined text
    segments.add(_TextSegment(match.group(1)!, true));
    lastEnd = match.end;
  }

  // Add remaining text
  if (lastEnd < text.length) {
    segments.add(_TextSegment(text.substring(lastEnd), false));
  }

  return segments;
}

/// Process markdown for a segment (without <u> tags)
String _processSegmentMarkdown(String text) {
  // First escape HTML special characters in the raw text
  var result = _escapeHtml(text);

  // Process ~~strikethrough~~
  result = result.replaceAllMapped(
    RegExp(r'~~(.*?)~~'),
    (match) => '<del>${match.group(1)}</del>',
  );

  // Process **bold**
  result = result.replaceAllMapped(
    RegExp(r'\*\*(.*?)\*\*'),
    (match) => '<strong>${match.group(1)}</strong>',
  );

  // Process *italic* (but not **bold**)
  result = result.replaceAllMapped(
    RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
    (match) => '<em>${match.group(1)}</em>',
  );

  // Process `code`
  result = result.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (match) => '<code>${match.group(1)}</code>',
  );

  return result;
}
