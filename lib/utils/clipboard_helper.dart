/// Platform-agnostic clipboard helper
/// Uses super_clipboard for robust cross-platform HTML/rich text support
library;

import 'package:super_clipboard/super_clipboard.dart';

/// Copy text to clipboard
Future<void> copyToClipboard(String text) async {
  final item = DataWriterItem();
  item.add(Formats.plainText(text));
  await SystemClipboard.instance?.write([item]);
}

/// Copy HTML and plain text to clipboard with rich text formatting
/// This is the preferred method for copying formatted text that needs to
/// preserve formatting when pasted into applications like Adobe InDesign
///
/// [html] is the HTML content (with formatting like <u>, <strong>, etc.)
/// [plainText] is the fallback plain text content
///
/// This works on all platforms (Web, Mac, Windows, iOS, Android, Linux)
/// Uses super_clipboard which provides native HTML clipboard support
/// via Rust internals and proper web implementation using ClipboardItem API
Future<void> copyHtmlToClipboard(String html, String plainText) async {
  final item = DataWriterItem();

  // Add HTML content first (higher priority)
  item.add(Formats.htmlText(html));

  // Add plain text as fallback (required)
  item.add(Formats.plainText(plainText));

  // Write to clipboard
  await SystemClipboard.instance?.write([item]);
}

