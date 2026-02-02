/// Mobile/Desktop clipboard implementation (iOS, Android, Windows, macOS, Linux)
/// This file is used when NOT building for web
library;

import 'package:flutter/services.dart';

/// Copy text to clipboard on mobile/desktop platforms
Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}

/// Copy HTML and plain text to clipboard on desktop/mobile platforms
/// Note: HTML clipboard support varies by platform
///
/// [html] is the HTML content (may not be supported on all platforms)
/// [plainText] is the fallback plain text content
///
/// Currently falls back to plain text on most desktop/mobile platforms
/// as Flutter's Clipboard API doesn't fully support HTML across all platforms.
/// Web platform has full HTML support - see clipboard_helper_web.dart
Future<void> copyHtmlToClipboard(String html, String plainText) async {
  // For desktop/mobile, we currently fall back to plain text
  // because Flutter's clipboard API doesn't have built-in HTML support
  // on all platforms.
  //
  // Future enhancement: Use platform channels for native HTML clipboard support:
  // - Windows: CF_HTML format
  // - macOS: NSHTMLPboardType
  // - Linux: text/html mimetype
  await Clipboard.setData(ClipboardData(text: plainText));
}
