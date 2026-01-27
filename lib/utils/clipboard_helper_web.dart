/// Web-specific clipboard implementation using package:web
/// This file is only used when building for web
library;

import 'dart:js_interop';
import 'package:web/web.dart';

/// Copy text to clipboard on web platforms
Future<void> copyToClipboard(String text) async {
  // Try modern Clipboard API first (Chrome, Edge, Safari 13+)
  try {
    final clipboard = window.navigator.clipboard;
    // Use promiseToFuture to convert JS Promise to Dart Future
    await clipboard.writeText(text).toDart;
    return;
  } catch (_) {
    // Fall through to execCommand method
  }

  // Fallback: Use textarea + execCommand for older browsers
  final textArea = document.createElement('textarea') as HTMLTextAreaElement;
  textArea.value = text;
  textArea.style.position = 'absolute';
  textArea.style.left = '-9999px';
  textArea.setAttribute('readonly', '');

  document.body?.append(textArea);
  textArea.select();
  textArea.setSelectionRange(0, 99999); // For mobile devices

  try {
    final successful = document.execCommand('copy');
    if (!successful) {
      throw Exception('execCommand failed');
    }
  } finally {
    textArea.remove();
  }
}
