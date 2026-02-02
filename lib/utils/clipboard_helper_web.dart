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

/// Copy HTML and plain text to clipboard on web platforms
/// This is preferred for rich text applications like Adobe InDesign
///
/// [html] is the HTML content to copy
/// [plainText] is the fallback plain text content
///
/// Uses Clipboard.write() with ClipboardItem for modern browsers,
/// falls back to plain text if HTML is not supported
Future<void> copyHtmlToClipboard(String html, String plainText) async {
  // Try modern Clipboard API with ClipboardItem (Chrome, Edge, Safari 13+)
  try {
    final clipboard = window.navigator.clipboard;

    // Create Blobs using jsify to convert Dart arrays to JS arrays
    final htmlBlob = Blob([html].jsify() as JSArray<JSAny>, BlobPropertyBag(type: 'text/html'));
    final textBlob = Blob([plainText].jsify() as JSArray<JSAny>, BlobPropertyBag(type: 'text/plain'));

    // Create the ClipboardItem data object
    final itemData = ({
      'text/html': htmlBlob,
      'text/plain': textBlob,
    }.jsify() as JSObject);

    final clipboardItem = ClipboardItem(itemData);
    await clipboard.write([clipboardItem].jsify() as JSArray<ClipboardItem>).toDart;
    return;
  } catch (_) {
    // Fall through to plain text copy
  }

  // Fallback to plain text only
  await copyToClipboard(plainText);
}
