// Web-specific export functionality
// This file is only included in web builds

import 'dart:js_interop';
import 'package:web/web.dart';
import 'dart:typed_data';

/// Downloads a file on web by creating a blob and triggering browser download
void downloadFileOnWeb(Uint8List fileBytes, String fileName, String mimeType) {
  // Create a blob from the bytes
  // In package:web, Blob accepts a JSArray of BlobPart
  // We convert Uint8List to a JS-compatible array
  final blob = Blob(
    [fileBytes.buffer.toJS].toJS,
    BlobPropertyBag(type: mimeType),
  );

  // Create object URL for the blob
  final url = URL.createObjectURL(blob);

  // Create anchor element and trigger download
  final anchor = document.createElement('a') as HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';

  // Add to DOM, click, and remove
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  // Clean up the object URL after a short delay
  Future.delayed(const Duration(milliseconds: 100), () {
    URL.revokeObjectURL(url);
  });
}

/// Gets the default download directory message for web browsers
String getWebDownloadLocationMessage() {
  // On web, files are downloaded to the browser's default download folder
  // The location depends on the browser and OS settings
  return 'File saved to your browser\'s default download folder. '
      'Check your Downloads folder or browser settings to change the default location.';
}
