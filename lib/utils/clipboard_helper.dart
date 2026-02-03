/// Platform-agnostic clipboard helper
/// Uses the clipboard package for cross-platform HTML/rich text support
library;

import 'package:clipboard/clipboard.dart';

/// Copy text to clipboard
Future<void> copyToClipboard(String text) async {
  await FlutterClipboard.copy(text);
}

/// Copy HTML and plain text to clipboard with rich text formatting
/// This is the preferred method for copying formatted text that needs to
/// preserve formatting when pasted into applications like Adobe InDesign
///
/// [html] is the HTML content (with formatting like <u>, <strong>, etc.)
/// [plainText] is the fallback plain text content
///
/// This works on all platforms (Web, Mac, Windows, iOS, Android, Linux)
/// Uses FlutterClipboard.copyRichText() which provides native HTML clipboard
/// support via platform channels and proper web implementation using ClipboardItem API
Future<void> copyHtmlToClipboard(String html, String plainText) async {
  await FlutterClipboard.copyRichText(
    text: plainText,
    html: html,
  );
}

