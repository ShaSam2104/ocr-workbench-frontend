import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/uploaded_file.dart';

/// Wrapper to handle file selection across platforms
class SelectedFile {
  final String name;
  final int size;
  final File? file; // For desktop
  final Uint8List? bytes; // For web

  SelectedFile({
    required this.name,
    required this.size,
    this.file,
    this.bytes,
  });

  bool get isWeb => bytes != null;
  bool get isDesktop => file != null;
}

/// Import service for handling JSON import operations
class ImportService {
  /// Upload and import a JSON export file
  ///
  /// Returns the import summary with counts of created/updated/skipped items
  static Future<ImportSummary> importJsonFile(
    SelectedFile selectedFile, {
    String mergeStrategy = 'skip_duplicates',
    bool preserveUuids = false,
  }) async {
    final authToken = currentAuthenticationToken ?? '';

    if (authToken.isEmpty) {
      throw Exception('Not authenticated');
    }

    // Create FFUploadedFile from SelectedFile
    final uploadedFile = FFUploadedFile(
      name: selectedFile.name,
      bytes: selectedFile.isWeb
          ? selectedFile.bytes!
          : await selectedFile.file!.readAsBytes(),
    );

    // Make API call
    final response = await OCRWorkbenchAPIGroup.importJsonCall.call(
      hTTPBearer: authToken,
      mergeStrategy: mergeStrategy,
      preserveUuids: preserveUuids,
      file: uploadedFile,
    );

    if (response.succeeded) {
      return ImportSummary.fromJson(response.jsonBody);
    } else {
      final error = response.bodyText.isNotEmpty ? response.bodyText : 'Unknown error';
      throw Exception('Import failed: $error');
    }
  }

  /// Export books/chapters to JSON
  ///
  /// Returns the JSON data as a string
  static Future<String> exportToJson({
    List<int>? bookIds,
    List<int>? chapterIds,
    bool includeBinaryFiles = true,
  }) async {
    final authToken = currentAuthenticationToken ?? '';

    if (authToken.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await OCRWorkbenchAPIGroup.exportJsonCall.call(
      hTTPBearer: authToken,
      bookIdsList: bookIds,
      chapterIdsList: chapterIds,
      includeBinaryFiles: includeBinaryFiles,
    );

    if (response.succeeded) {
      // IMPORTANT: Use bodyText directly for large responses to avoid truncation
      // bodyText returns the raw response body as a String without JSON parsing
      return response.bodyText;
    } else {
      final error = response.bodyText.isNotEmpty ? response.bodyText : 'Unknown error';
      throw Exception('Export failed: $error');
    }
  }

  /// Get export/import information
  static Future<Map<String, dynamic>> getInfo() async {
    final authToken = currentAuthenticationToken ?? '';

    if (authToken.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await OCRWorkbenchAPIGroup.exportImportInfoCall.call(
      hTTPBearer: authToken,
    );

    if (response.succeeded) {
      return response.jsonBody as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get info');
    }
  }
}

/// Import summary data class
class ImportSummary {
  final int booksCreated;
  final int booksUpdated;
  final int booksSkipped;
  final int chaptersCreated;
  final int chaptersUpdated;
  final int chaptersSkipped;
  final int imagesCreated;
  final int imagesSkipped;
  final int audiosCreated;
  final int audiosSkipped;
  final List<String> errors;

  ImportSummary({
    required this.booksCreated,
    required this.booksUpdated,
    required this.booksSkipped,
    required this.chaptersCreated,
    required this.chaptersUpdated,
    required this.chaptersSkipped,
    required this.imagesCreated,
    required this.imagesSkipped,
    required this.audiosCreated,
    required this.audiosSkipped,
    required this.errors,
  });

  factory ImportSummary.fromJson(Map<String, dynamic> json) {
    return ImportSummary(
      booksCreated: json['books_created'] as int? ?? 0,
      booksUpdated: json['books_updated'] as int? ?? 0,
      booksSkipped: json['books_skipped'] as int? ?? 0,
      chaptersCreated: json['chapters_created'] as int? ?? 0,
      chaptersUpdated: json['chapters_updated'] as int? ?? 0,
      chaptersSkipped: json['chapters_skipped'] as int? ?? 0,
      imagesCreated: json['images_created'] as int? ?? 0,
      imagesSkipped: json['images_skipped'] as int? ?? 0,
      audiosCreated: json['audios_created'] as int? ?? 0,
      audiosSkipped: json['audios_skipped'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Get total count of all items
  int get totalItems =>
      booksCreated +
      booksUpdated +
      chaptersCreated +
      chaptersUpdated +
      imagesCreated +
      audiosCreated;

  /// Get total count of skipped items
  int get totalSkipped =>
      booksSkipped + chaptersSkipped + imagesSkipped + audiosSkipped;

  /// Whether the import had any errors
  bool get hasErrors => errors.isNotEmpty;

  /// Whether any items were created or updated
  bool get hasChanges => totalItems > 0;
}
