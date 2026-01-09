import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path_util;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/focus_manager.dart';

class FileUploaderWidget extends StatefulWidget {
  /// Callback when files are selected
  final Function(List<File>) onFilesSelected;

  /// Allowed file extensions (jpg, png, jpeg, tiff, pdf, mp3, wav, m4a, ogg, flac)
  final List<String> allowedExtensions;

  /// Whether to allow multiple files
  final bool multiple;

  /// Label for the uploader
  final String? label;

  /// Description or help text
  final String? description;

  /// Callback when upload starts
  final VoidCallback? onUploadStart;

  /// Callback when upload completes
  final VoidCallback? onUploadComplete;

  /// Whether upload is in progress
  final bool isUploading;

  const FileUploaderWidget({
    Key? key,
    required this.onFilesSelected,
    this.allowedExtensions = const [
      'jpg',
      'png',
      'jpeg',
      'tiff',
      'pdf',
      'mp3',
      'wav',
      'm4a',
      'ogg',
      'flac'
    ],
    this.multiple = true,
    this.label,
    this.description,
    this.onUploadStart,
    this.onUploadComplete,
    this.isUploading = false,
  }) : super(key: key);

  @override
  State<FileUploaderWidget> createState() => _FileUploaderWidgetState();
}

class _FileUploaderWidgetState extends State<FileUploaderWidget> {
  late FocusNode _focusNode;
  List<File> _selectedFiles = [];
  int _focusedFileIndex = -1;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    // Enter to open file picker
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
      _openFilePicker();
      return;
    }

    // Delete to remove focused file
    if (HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.delete) &&
        _focusedFileIndex >= 0 &&
        _focusedFileIndex < _selectedFiles.length) {
      _removeFile(_focusedFileIndex);
      return;
    }

    // Tab to navigate through files
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.tab)) {
      if (!HardwareKeyboard.instance.isShiftPressed) {
        // Tab forward
        if (_focusedFileIndex < _selectedFiles.length - 1) {
          setState(() {
            _focusedFileIndex++;
          });
        } else {
          _focusNode.nextFocus();
        }
      } else {
        // Shift+Tab backward
        if (_focusedFileIndex > 0) {
          setState(() {
            _focusedFileIndex--;
          });
        } else {
          _focusNode.previousFocus();
        }
      }
      return;
    }
  }

  Future<void> _openFilePicker() async {
    try {
      widget.onUploadStart?.call();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: widget.allowedExtensions,
        type: FileType.custom,
        allowMultiple: widget.multiple,
      );

      if (result != null) {
        final files = result.paths.map((path) => File(path!)).toList();

        // Validate file types
        final validFiles = files.where((file) {
          final ext =
              path_util.extension(file.path).replaceFirst('.', '').toLowerCase();
          return widget.allowedExtensions.contains(ext);
        }).toList();

        if (validFiles.isNotEmpty) {
          if (widget.multiple) {
            setState(() {
              _selectedFiles.addAll(validFiles);
            });
          } else {
            setState(() {
              _selectedFiles = [validFiles.first];
            });
          }

          widget.onFilesSelected(validFiles);
        }
      }

      widget.onUploadComplete?.call();
    } catch (e) {
      debugPrint('File picker error: $e');
      widget.onUploadComplete?.call();
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_focusedFileIndex >= _selectedFiles.length) {
        _focusedFileIndex = _selectedFiles.length - 1;
      }
    });
    widget.onFilesSelected(_selectedFiles);
  }

  IconData _getFileIcon(String filePath) {
    final ext = path_util.extension(filePath).replaceFirst('.', '').toLowerCase();

    // Image icons
    if (['jpg', 'png', 'jpeg', 'tiff'].contains(ext)) {
      return Icons.image;
    }
    // PDF icon
    if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    }
    // Audio icons
    if (['mp3', 'wav', 'm4a', 'ogg', 'flac'].contains(ext)) {
      return Icons.audio_file;
    }
    // Default file icon
    return Icons.file_present;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null && widget.label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: theme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ),

        // Upload button with focus ring
        FocusRingDecorator.buildFocusRingContainer(
          isFocused: _isFocused && _selectedFiles.isEmpty,
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  _handleKeyEvent(event);
                }
                return KeyEventResult.ignored;
              },
              child: GestureDetector(
                onTap: _openFilePicker,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isFocused && _selectedFiles.isEmpty
                          ? theme.primary
                          : theme.alternate,
                      width: _isFocused && _selectedFiles.isEmpty ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _isFocused && _selectedFiles.isEmpty
                        ? theme.primary.withValues(alpha: 0.05)
                        : Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isUploading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: theme.primary,
                          ),
                        ),
                      Text(
                        widget.isUploading
                            ? 'Uploading...'
                            : 'Click to select files',
                        style: theme.bodyMedium.copyWith(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!widget.isUploading && widget.multiple)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Or drag and drop files here',
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      if (widget.description != null &&
                          widget.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.description!,
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!widget.isUploading)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Enter to select • Esc to cancel',
                            style: theme.bodySmall.copyWith(
                              color: theme.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Selected files list
        if (_selectedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: theme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryText,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      final fileName = path_util.basename(file.path);
                      final fileSize = file.lengthSync();
                      final isFocused = _focusedFileIndex == index;

                      return Focus(
                        focusNode: FocusNode(),
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent) {
                            _handleKeyEvent(event);
                          }
                          return KeyEventResult.ignored;
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isFocused
                                  ? theme.primary
                                  : theme.alternate,
                              width: isFocused ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isFocused
                                ? theme.primary.withValues(alpha: 0.05)
                                : Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // File icon
                                Icon(
                                  _getFileIcon(file.path),
                                  color: theme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                // File info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        style: theme.bodyMedium.copyWith(
                                          color: isFocused
                                              ? theme.primary
                                              : theme.primaryText,
                                          fontWeight: isFocused
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Text(
                                          _formatFileSize(fileSize),
                                          style: theme.bodySmall.copyWith(
                                            color: theme.secondaryText
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove button
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: theme.error,
                                      size: 20,
                                    ),
                                    onPressed: () => _removeFile(index),
                                    tooltip:
                                        'Remove file (Delete key)',
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
