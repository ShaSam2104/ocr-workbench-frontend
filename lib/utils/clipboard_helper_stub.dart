/// Mobile/Desktop clipboard implementation (iOS, Android, Windows, macOS, Linux)
/// This file is used when NOT building for web
library;

import 'package:flutter/services.dart';

/// Copy text to clipboard on mobile/desktop platforms
Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}
