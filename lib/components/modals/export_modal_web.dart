// Web-specific export functionality
// This file is only included in web builds

import 'dart:html' as html;
import 'dart:typed_data';

/// Downloads a file on web by creating a blob and triggering browser download
void downloadFileOnWeb(Uint8List fileBytes, String fileName, String mimeType) {
  // Create a blob from the bytes
  final blob = html.Blob([fileBytes], mimeType);

  // Create object URL for the blob
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create anchor element and trigger download
  final anchor = html.AnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  // Add to DOM, click, and remove
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  // Clean up the object URL after a short delay
  Future.delayed(const Duration(milliseconds: 100), () {
    html.Url.revokeObjectUrl(url);
  });
}

/// Gets the default download directory message for web browsers
String getWebDownloadLocationMessage() {
  // On web, files are downloaded to the browser's default download folder
  // The location depends on the browser and OS settings
  return 'File saved to your browser\'s default download folder. '
      'Check your Downloads folder or browser settings to change the default location.';
}
