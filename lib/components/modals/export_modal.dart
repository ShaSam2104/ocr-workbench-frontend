import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ExportConfig {
  final String level; // 'chapter', 'book', 'selection'
  final String format; // 'pdf', 'docx', 'txt', 'csv'
  final bool includeImages;
  final bool includeTranscripts;
  final bool includePageBreaks;
  final String language; // 'auto' or language code

  ExportConfig({
    required this.level,
    required this.format,
    required this.includeImages,
    required this.includeTranscripts,
    required this.includePageBreaks,
    required this.language,
  });
}

class ExportModal extends StatefulWidget {
  const ExportModal({
    super.key,
    this.currentChapterId,
    this.currentChaptName,
    this.currentBookId,
    this.currentBookName,
    this.selectedItemsCount = 0,
    required this.onExport,
  });

  final int? currentChapterId;
  final String? currentChaptName;
  final int? currentBookId;
  final String? currentBookName;
  final int selectedItemsCount;
  final Function(ExportConfig config) onExport;

  @override
  State<ExportModal> createState() => _ExportModalState();
}

class _ExportModalState extends State<ExportModal> {
  late String _selectedLevel;
  String _selectedFormat = 'pdf';
  bool _includeImages = true;
  bool _includeTranscripts = true;
  bool _includePageBreaks = true;
  String _selectedLanguage = 'auto';
  bool _isExporting = false;
  String? _exportProgress;

  final List<String> _languages = [
    'auto',
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
    'ar',
  ];

  @override
  void initState() {
    super.initState();
    // Set default export level based on what's available
    if (widget.selectedItemsCount > 0) {
      _selectedLevel = 'selection';
    } else if (widget.currentChapterId != null) {
      _selectedLevel = 'chapter';
    } else if (widget.currentBookId != null) {
      _selectedLevel = 'book';
    } else {
      _selectedLevel = 'book';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 576;
    final isTablet =
        MediaQuery.of(context).size.width >= 576 && MediaQuery.of(context).size.width < 992;

    return Dialog(
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
        child: SingleChildScrollView(
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Export Level Selection
                    Text(
                      'Export Level',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        if (widget.selectedItemsCount > 0)
                          _buildLevelOption(
                            'selection',
                            'Selected Items (${widget.selectedItemsCount})',
                            theme,
                          ),
                        if (widget.selectedItemsCount > 0) const SizedBox(height: 8),
                        if (widget.currentChapterId != null)
                          _buildLevelOption(
                            'chapter',
                            'Current Chapter (${widget.currentChaptName ?? 'Untitled'})',
                            theme,
                          ),
                        if (widget.currentChapterId != null) const SizedBox(height: 8),
                        if (widget.currentBookId != null)
                          _buildLevelOption(
                            'book',
                            'Current Book (${widget.currentBookName ?? 'Untitled'})',
                            theme,
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
                          _buildFormatButton('pdf', 'PDF', theme),
                          const SizedBox(width: 8),
                          _buildFormatButton('docx', 'Word', theme),
                          const SizedBox(width: 8),
                          _buildFormatButton('txt', 'Text', theme),
                          const SizedBox(width: 8),
                          _buildFormatButton('csv', 'CSV', theme),
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
                        setState(() => _includeImages = value);
                      },
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleOption(
                      'Include Transcripts',
                      _includeTranscripts,
                      (value) {
                        setState(() => _includeTranscripts = value);
                      },
                      theme,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFormat == 'pdf' || _selectedFormat == 'docx')
                      _buildToggleOption(
                        'Include Page Breaks',
                        _includePageBreaks,
                        (value) {
                          setState(() => _includePageBreaks = value);
                        },
                        theme,
                      ),
                    const SizedBox(height: 16),
                    // Language Selection
                    Text(
                      'Language',
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value ?? 'auto';
                        });
                      },
                      items: _languages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang == 'auto'
                                    ? 'Auto-detect'
                                    : _getLanguageName(lang),
                                style: theme.bodyMedium,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Preview
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
                            'Preview',
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
              // Footer with buttons
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isExporting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isExporting ? null : _performExport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isExporting
                          ? SizedBox(
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
      ),
    );
  }

  Widget _buildLevelOption(String value, String label, FlutterFlowTheme theme) {
    final isSelected = _selectedLevel == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedLevel,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLevel = newValue;
                  });
                }
              },
              activeColor: theme.primary,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.bodyMedium.copyWith(
                  color: isSelected ? theme.primary : theme.secondaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
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
          activeColor: theme.primary,
        ),
      ],
    );
  }

  String _buildPreviewText() {
    final format = _selectedFormat.toUpperCase();
    final level = _getLevelLabel(_selectedLevel);
    final includes = <String>[];

    if (_includeImages) includes.add('images');
    if (_includeTranscripts) includes.add('transcripts');
    if ((_selectedFormat == 'pdf' || _selectedFormat == 'docx') && _includePageBreaks) {
      includes.add('page breaks');
    }

    final includesText = includes.isNotEmpty ? 'with ${includes.join(', ')}' : 'without content';

    return 'Exporting $level as $format $includesText${_selectedLanguage != 'auto' ? ' (${_getLanguageName(_selectedLanguage)})' : ''}';
  }

  String _generateFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final level = _selectedLevel == 'chapter'
        ? 'chapter'
        : _selectedLevel == 'book'
            ? 'book'
            : 'export';
    final extension = _selectedFormat;

    return '$level\_$timestamp.$extension';
  }

  String _getLevelLabel(String level) {
    switch (level) {
      case 'selection':
        return 'Selected items (${widget.selectedItemsCount})';
      case 'chapter':
        return 'Chapter: ${widget.currentChaptName ?? 'Untitled'}';
      case 'book':
        return 'Book: ${widget.currentBookName ?? 'Untitled'}';
      default:
        return 'Export';
    }
  }

  String _getLanguageName(String code) {
    const languages = {
      'auto': 'Auto-detect',
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
    };
    return languages[code] ?? code;
  }

  Future<void> _performExport() async {
    final config = ExportConfig(
      level: _selectedLevel,
      format: _selectedFormat,
      includeImages: _includeImages,
      includeTranscripts: _includeTranscripts,
      includePageBreaks: _includePageBreaks,
      language: _selectedLanguage,
    );

    setState(() {
      _isExporting = true;
      _exportProgress = 'Preparing export...';
    });

    try {
      // Simulate export progress
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _exportProgress = 'Processing content...');

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _exportProgress = 'Formatting document...');

      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _exportProgress = 'Finalizing export...');

      // Call the callback with export config
      widget.onExport(config);

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _exportProgress = 'Export failed: $e';
        _isExporting = false;
      });
    }
  }
}
