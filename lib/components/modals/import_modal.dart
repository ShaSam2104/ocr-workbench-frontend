import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/services/import_service.dart';

/// Merge strategy options
enum MergeStrategy {
  skipDuplicates('Skip Duplicates', 'Only import items that don\'t already exist'),
  merge('Merge', 'Update existing items and create new ones'),
  replace('Replace', 'Delete existing data and import fresh'),
  ;

  final String label;
  final String description;

  const MergeStrategy(this.label, this.description);

  String get value => name == 'skipDuplicates' ? 'skip_duplicates' : name;
}

/// Import modal for importing JSON exports
class ImportModal extends StatefulWidget {
  final Function() onImportComplete;

  const ImportModal({
    super.key,
    required this.onImportComplete,
  });

  @override
  State<ImportModal> createState() => _ImportModalState();
}

class _ImportModalState extends State<ImportModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  SelectedFile? _selectedFile;
  MergeStrategy _mergeStrategy = MergeStrategy.skipDuplicates;
  bool _isImporting = false;
  ImportSummary? _importSummary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb, // Load bytes on web
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;

        if (kIsWeb) {
          // On web, use bytes
          if (platformFile.bytes != null) {
            setState(() {
              _selectedFile = SelectedFile(
                name: platformFile.name,
                size: platformFile.size,
                bytes: platformFile.bytes,
              );
              _errorMessage = null;
              _importSummary = null;
            });
          }
        } else {
          // On desktop, use path
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            setState(() {
              _selectedFile = SelectedFile(
                name: platformFile.name,
                size: platformFile.size,
                file: file,
              );
              _errorMessage = null;
              _importSummary = null;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _handleImport() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Please select a file to import');
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
      _importSummary = null;
    });

    try {
      final summary = await ImportService.importJsonFile(
        _selectedFile!,
        mergeStrategy: _mergeStrategy.value,
        preserveUuids: false,
      );

      setState(() {
        _importSummary = summary;
        _isImporting = false;
      });

      // If successful and no errors, close modal after a delay
      if (!summary.hasErrors && summary.hasChanges) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          widget.onImportComplete();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isImporting = false;
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 560,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.alternate.withValues(alpha: 0.3),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(theme),

                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: theme.alternate.withValues(alpha: 0.3),
                ),

                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File picker
                        _buildFilePicker(theme),

                        const SizedBox(height: 20.0),

                        // Merge strategy
                        _buildMergeStrategy(theme),

                        // Error message
                        if (_errorMessage != null) _buildErrorMessage(theme),

                        // Import summary
                        if (_importSummary != null) _buildImportSummary(theme),

                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),

                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: theme.alternate.withValues(alpha: 0.3),
                ),

                // Footer
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.upload_file,
                  size: 18,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Import Archive',
                style: theme.headlineSmall.override(
                  fontFamily: 'Inter',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: _isImporting ? null : () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: 18.0,
                color: theme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select File',
          style: theme.bodyMedium.override(
            fontFamily: 'Inter',
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: _isImporting ? null : _pickFile,
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              border: Border.all(
                color: _selectedFile != null
                    ? theme.primary
                    : theme.alternate.withValues(alpha: 0.5),
                width: _selectedFile != null ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: _selectedFile != null
                ? Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile!.name,
                              style: theme.bodyMedium.override(
                                fontFamily: 'Inter',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatFileSize(_selectedFile!.size),
                              style: theme.bodySmall.override(
                                fontFamily: 'Inter',
                                fontSize: 12.0,
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _isImporting
                            ? null
                            : () {
                                setState(() {
                                  _selectedFile = null;
                                  _importSummary = null;
                                });
                              },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: theme.secondaryText.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to select a JSON file',
                        style: theme.bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 13.0,
                          color: theme.secondaryText,
                        ),
                      ),
                      Text(
                        'or drag and drop',
                        style: theme.bodySmall.override(
                          fontFamily: 'Inter',
                          fontSize: 12.0,
                          color: theme.secondaryText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMergeStrategy(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merge Strategy',
          style: theme.bodyMedium.override(
            fontFamily: 'Inter',
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8.0),
        ...MergeStrategy.values.map((strategy) {
          final isSelected = _mergeStrategy == strategy;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: _isImporting
                  ? null
                  : () {
                      setState(() => _mergeStrategy = strategy);
                    },
              borderRadius: BorderRadius.circular(4.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary.withValues(alpha: 0.08)
                      : theme.secondaryBackground,
                  border: Border.all(
                    color: isSelected
                        ? theme.primary
                        : theme.alternate.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: isSelected ? theme.primary : theme.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strategy.label,
                            style: theme.bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 14.0,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? theme.primary
                                  : theme.primaryText,
                            ),
                          ),
                          Text(
                            strategy.description,
                            style: theme.bodySmall.override(
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildErrorMessage(FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: theme.error.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.bodySmall.override(
                fontFamily: 'Inter',
                fontSize: 12.0,
                color: theme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSummary(FlutterFlowTheme theme) {
    final summary = _importSummary!;

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: summary.hasErrors
            ? theme.warning.withValues(alpha: 0.08)
            : theme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: summary.hasErrors
              ? theme.warning.withValues(alpha: 0.2)
              : theme.success.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                summary.hasErrors ? Icons.warning_amber_rounded : Icons.check_circle,
                size: 16,
                color: summary.hasErrors ? theme.warning : theme.success,
              ),
              const SizedBox(width: 8),
              Text(
                summary.hasErrors ? 'Import completed with warnings' : 'Import successful',
                style: theme.bodySmall.override(
                  fontFamily: 'Inter',
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: summary.hasErrors ? theme.warning : theme.success,
                ),
              ),
            ],
          ),
          if (summary.hasChanges) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Books created', summary.booksCreated, theme),
            if (summary.booksUpdated > 0)
              _buildSummaryRow('Books updated', summary.booksUpdated, theme),
            if (summary.booksSkipped > 0)
              _buildSummaryRow('Books skipped', summary.booksSkipped, theme),
            _buildSummaryRow('Chapters created', summary.chaptersCreated, theme),
            if (summary.chaptersUpdated > 0)
              _buildSummaryRow('Chapters updated', summary.chaptersUpdated, theme),
            _buildSummaryRow('Images created', summary.imagesCreated, theme),
            _buildSummaryRow('Audios created', summary.audiosCreated, theme),
          ],
          if (summary.hasErrors) ...[
            const SizedBox(height: 8),
            Text(
              'Errors:',
              style: theme.bodySmall.override(
                fontFamily: 'Inter',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.warning,
              ),
            ),
            const SizedBox(height: 4),
            ...summary.errors.take(3).map((error) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    '• $error',
                    style: theme.bodySmall.override(
                      fontFamily: 'Inter',
                      fontSize: 11.0,
                      color: theme.warning,
                    ),
                  ),
                )),
            if (summary.errors.length > 3)
              Text(
                '...and ${summary.errors.length - 3} more errors',
                style: theme.bodySmall.override(
                  fontFamily: 'Inter',
                  fontSize: 11.0,
                  color: theme.warning,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.bodySmall.override(
              fontFamily: 'Inter',
              fontSize: 12.0,
              color: theme.secondaryText,
            ),
          ),
          Text(
            value.toString(),
            style: theme.bodySmall.override(
              fontFamily: 'Inter',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            child: Text(
              'Cancel',
              style: theme.bodyMedium.override(
                fontFamily: 'Inter',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: theme.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          TextButton(
            onPressed: (_selectedFile == null || _isImporting) ? null : _handleImport,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              backgroundColor: (_selectedFile == null || _isImporting)
                  ? theme.alternate.withValues(alpha: 0.5)
                  : theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            child: _isImporting
                ? const SizedBox(
                    width: 60,
                    height: 16,
                    child: Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                : Text(
                    'Import',
                    style: theme.bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
