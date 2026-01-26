/// Web-specific clipboard implementation using dart:html
/// This file is only used when building for web
library;

import 'dart:html' as html;

/// Copy text to clipboard on web platforms
Future<void> copyToClipboard(String text) async {
  // Try modern Clipboard API first (Chrome, Edge, Safari 13+)
  try {
    if (html.window.navigator.clipboard != null &&
        html.window.navigator.clipboard?.writeText != null) {
      await html.window.navigator.clipboard!.writeText(text);
      return;
    }
  } catch (_) {
    // Fall through to execCommand method
  }

  // Fallback: Use textarea + execCommand for older browsers
  final textArea = html.TextAreaElement();
  textArea.value = text;
  textArea.style.position = 'absolute';
  textArea.style.left = '-9999px';
  textArea.setAttribute('readonly', '');

  html.document.body?.append(textArea);
  textArea.select();
  textArea.setSelectionRange(0, 99999); // For mobile devices

  try {
    final successful = html.document.execCommand('copy', false, null);
    if (!successful) {
      throw Exception('execCommand failed');
    }
  } finally {
    textArea.remove();
  }
}
