import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/toasts/toast_manager.dart';

// Conditional import for web functionality
import 'export_modal_web.dart' if (dart.library.html) 'export_modal_web.dart';

class ExportConfig {
  final String format; // 'docx', 'txt'
  final bool includeImages;
  final bool includeTranscripts;
  final bool includePageBreaks;
  final int? chapterId; // null for "All Chapters"

  ExportConfig({
    required this.format,
    required this.includeImages,
    required this.includeTranscripts,
    required this.includePageBreaks,
    this.chapterId,
  });
}

class ExportModal extends StatefulWidget {
  const ExportModal({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapters,
    required this.onExportComplete,
    required this.onClose,
  });

  final int bookId;
  final String bookName;
  final List<ChapterItem> chapters;
  final VoidCallback onExportComplete;
  final VoidCallback onClose;

  @override
  State<ExportModal> createState() => _ExportModalState();
}

class ChapterItem {
  final int id;
  final String name;

  ChapterItem({required this.id, required this.name});
}

class _ExportModalState extends State<ExportModal> {
  String _selectedFormat = 'docx';
  bool _includeImages = true;
  bool _includeTranscripts = true;
  bool _includePageBreaks = true;
  int? _selectedChapterId; // null for "All Chapters"
  bool _isExporting = false;
  String? _exportProgress;

  @override
  void initState() {
    super.initState();
    _selectedChapterId = null; // Default to "All Chapters"
    // Register keyboard handler for ESC
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        !_isExporting) {
      widget.onClose();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 576;
    final isTablet = MediaQuery.of(context).size.width >= 576 && MediaQuery.of(context).size.width < 992;

    return Dialog(
      backgroundColor: theme.primaryBackground,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Container(
        width: isMobile ? double.infinity : (isTablet ? 600 : 700),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.alternate,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Export',
                    style: theme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Display (Read-only)
                    Text(
                      'Book',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        border: Border.all(
                          color: theme.alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 20,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.bookName,
                              style: theme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Chapter Selection Dropdown
                    Text(
                      'Chapter',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int?>(
                      value: _selectedChapterId,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedChapterId = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.library_books,
                                size: 18,
                                color: theme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'All Chapters',
                                style: theme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        ...widget.chapters.map(
                          (chapter) => DropdownMenuItem(
                            value: chapter.id,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 18,
                                  color: theme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    chapter.name,
                                    style: theme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Format Selection
                    Text(
                      'Format',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFormatButton('docx', 'Word', theme),
                          const SizedBox(width: 8),
                          _buildFormatButton('txt', 'Text', theme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Options
                    Text(
                      'Options',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleOption(
                      'Include Images',
                      _includeImages,
                      (value) {
                        setState(() {
                          _includeImages = value;
                          setState(() {});
                        });
                        },
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleOption(
                      'Include Transcripts',
                      _includeTranscripts,
                      (value) {
                        setState(() {
                          _includeTranscripts = value;
                          setState(() {});
                        });
                        },
                      theme,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFormat == 'docx')
                      _buildToggleOption(
                        'Include Page Breaks',
                        _includePageBreaks,
                        (value) {
                          setState(() {
                            _includePageBreaks = value;
                            setState(() {});
                          });
                          },
                        theme,
                      ),
                    const SizedBox(height: 16),
                    // Preview info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Summary',
                            style: theme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _buildPreviewText(),
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'File: ${_generateFileName()}',
                            style: theme.bodySmall.copyWith(
                              color: theme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress
                    if (_isExporting)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            color: theme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _exportProgress ?? 'Preparing export...',
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Footer with Export button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.alternate,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isExporting ? null : _performExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Export'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton(String value, String label, FlutterFlowTheme theme) {
    final isSelected = _selectedFormat == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFormat = value;
          setState(() {});
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: theme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected ? theme.primary : theme.alternate,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: theme.bodySmall.copyWith(
        color: isSelected ? theme.primary : theme.secondaryText,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    bool value,
    Function(bool) onChanged,
    FlutterFlowTheme theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodyMedium,
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.primary,
        ),
      ],
    );
  }

  String _buildPreviewText() {
    final format = _selectedFormat.toUpperCase();
    final chapterText = _selectedChapterId == null
        ? 'All Chapters'
        : 'Chapter: ${widget.chapters.firstWhere((c) => c.id == _selectedChapterId, orElse: () => ChapterItem(id: 0, name: 'Unknown')).name}';
    final includes = <String>[];

    if (_includeImages) includes.add('images');
    if (_includeTranscripts) includes.add('transcripts');
    if (_selectedFormat == 'docx' && _includePageBreaks) {
      includes.add('page breaks');
    }

    final includesText = includes.isNotEmpty ? 'with ${includes.join(', ')}' : 'without content';

    return 'Exporting "$chapterText" from "${widget.bookName}" as $format $includesText';
  }

  String _generateFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final chapterName = _selectedChapterId == null
        ? 'all_chapters'
        : widget.chapters
                .firstWhere((c) => c.id == _selectedChapterId, orElse: () => ChapterItem(id: 0, name: 'unknown'))
                .name
                .toLowerCase()
                .replaceAll(' ', '_');
    final extension = _selectedFormat;

    return '${widget.bookName.toLowerCase().replaceAll(' ', '_')}_$chapterName\_$timestamp.$extension';
  }

  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
      _exportProgress = 'Preparing export...';
    });

    try {
      final authToken = currentAuthenticationToken ?? '';

      if (authToken.isEmpty) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      setState(() => _exportProgress = 'Calling export API...');

      // Call the export API
      final result = await OCRWorkbenchAPIGroup.exportFolderCall.call(
        hTTPBearer: authToken,
        bookId: widget.bookId,
        chapterId: _selectedChapterId,
        format: _selectedFormat,
        includeImages: _includeImages,
        includeAudioTranscripts: _includeTranscripts,
        includePageBreaks: _includePageBreaks,
      );

      if (!result.succeeded) {
        final errorDetail = result.jsonBody?['detail'] ?? result.jsonBody?['error'] ?? 'Unknown error';
        throw Exception('Export failed (${result.statusCode}): $errorDetail');
      }

      setState(() => _exportProgress = 'Preparing file save dialog...');

      // Check if backend returned a file directly (FileResponse)
      if (result.jsonBody == null && result.response != null) {
        await _saveBinaryFile(result.response!.bodyBytes);
        return;
      }

      // Check if jsonBody is null or empty
      if (result.jsonBody == null) {
        throw Exception('Empty response from export API');
      }

      // Parse response to get file URL or data
      final responseData = result.jsonBody as Map<String, dynamic>;

      // Check if response contains a download URL or base64 data
      if (responseData.containsKey('download_url')) {
        final downloadUrl = responseData['download_url'] as String;
        await _downloadAndSaveFile(downloadUrl, authToken);
      } else if (responseData.containsKey('file_data')) {
        final fileData = responseData['file_data'] as String;
        await _saveFileData(fileData);
      } else {
        throw Exception('Invalid response format from export API. Expected download_url or file_data.');
      }

      setState(() => _exportProgress = 'Export complete!');

      if (mounted) {
        if (kIsWeb) {
          ToastManager.showSuccess(
            'Export complete! $getWebDownloadLocationMessage()',
            duration: const Duration(seconds: 6),
          );
        } else {
          ToastManager.showSuccess('Export successful!');
        }
        widget.onExportComplete();
      }
    } catch (e) {
      String errorMessage = 'Export failed';

      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Network timeout. Please try again.';
      } else if (e.toString().contains('SocketException') ||
                 e.toString().contains('Connection')) {
        errorMessage = 'Connection error. Please check your network.';
      } else if (e.toString().contains('HttpException') || e.toString().contains('401')) {
        errorMessage = 'Authentication error. Please log in again.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Cannot save file.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      if (mounted) {
        ToastManager.showError(errorMessage);
      }

      setState(() {
        _exportProgress = errorMessage;
        _isExporting = false;
      });

      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _exportProgress = null);
      }
    }
  }

  Future<void> _downloadAndSaveFile(String url, String authToken) async {
    try {
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported file',
        fileName: _generateFileName(),
      );

      if (filePath == null) {
        throw Exception('File save cancelled by user');
      }

      setState(() => _exportProgress = 'Downloading file...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      setState(() => _exportProgress = 'Saving file...');

      final file = await File(filePath).create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      setState(() => _exportProgress = 'Export complete!');

      if (mounted) {
        ToastManager.showSuccess('Export successful!');
        widget.onExportComplete();
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> _saveFileData(String base64Data) async {
    try {
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported file',
        fileName: _generateFileName(),
      );

      if (filePath == null) {
        throw Exception('File save cancelled by user');
      }

      setState(() => _exportProgress = 'Saving file...');

      final bytes = base64Decode(base64Data);
      final file = await File(filePath).create(recursive: true);
      await file.writeAsBytes(bytes);

      setState(() => _exportProgress = 'Export complete!');

      if (mounted) {
        ToastManager.showSuccess('Export successful!');
        widget.onExportComplete();
      }
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> _saveBinaryFile(Uint8List fileBytes) async {
    try {
      final fileName = _generateFileName();

      if (kIsWeb) {
        setState(() => _exportProgress = 'Downloading file...');
        await _downloadFileOnWeb(fileBytes, fileName);
      } else {
        final filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save exported file',
          fileName: fileName,
        );

        if (filePath == null) {
          throw Exception('File save cancelled by user');
        }

        setState(() => _exportProgress = 'Saving file...');

        final file = await File(filePath).create(recursive: true);
        await file.writeAsBytes(fileBytes);
      }

      setState(() => _exportProgress = 'Export complete!');

      if (mounted) {
        if (kIsWeb) {
          ToastManager.showSuccess(
            'Export complete! $getWebDownloadLocationMessage()',
            duration: const Duration(seconds: 6),
          );
        } else {
          ToastManager.showSuccess('Export successful!');
        }
        widget.onExportComplete();
      }
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> _downloadFileOnWeb(Uint8List fileBytes, String fileName) async {
    downloadFileOnWeb(fileBytes, fileName, _getMimeType());
  }

  String _getMimeType() {
    switch (_selectedFormat) {
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
