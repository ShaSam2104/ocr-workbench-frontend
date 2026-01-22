import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';
import 'package:image/image.dart' as img;

class PDFProcessor {
  /// Converts PDF file or bytes to list of images (one per page)
  /// Can accept either pdfPath (for mobile/desktop) or pdfBytes (for web)
  /// Returns list of image bytes
  static Future<List<Uint8List>> extractImagesFromPDF(
    String? pdfPath, {
    double dpi = 150.0,
    Uint8List? pdfBytes,
  }) async {
    try {
      final pdfDocument = pdfBytes != null
          ? await PdfDocument.openData(pdfBytes)
          : await PdfDocument.openFile(pdfPath!);
      final List<Uint8List> images = [];

      for (int i = 0; i < pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i + 1);
        
        // Render page to image with specified DPI
        final pageImage = await page.render(
          width: (page.width * dpi / 72).toDouble(),
          height: (page.height * dpi / 72).toDouble(),
        );

        if (pageImage != null) {
          images.add(pageImage.bytes);
        }

        await page.close();
      }

      await pdfDocument.close();
      return images;
    } catch (e) {
      print('Error extracting images from PDF: $e');
      rethrow;
    }
  }

  /// Converts Uint8List image to JPEG format with quality adjustment
  static Uint8List convertToJPEG(Uint8List imageBytes, {int quality = 90}) {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Encode as JPEG with specified quality
      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      print('Error converting image to JPEG: $e');
      return imageBytes; // Return original if conversion fails
    }
  }

  /// Compress image while maintaining aspect ratio
  static Uint8List compressImage(
    Uint8List imageBytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize if necessary
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height > image.width ? maxHeight : null,
          interpolation: img.Interpolation.cubic,
        );
      }

      // Encode as JPEG
      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes;
    }
  }
}
