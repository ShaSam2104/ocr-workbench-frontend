import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/utils/formatted_text_widget.dart';

class ImageDetailModal extends StatefulWidget {
  const ImageDetailModal({
    super.key,
    required this.imageId,
    required this.imageName,
    required this.imageUrl,
    required this.sequence,
    this.onDelete,
    this.onSequenceChanged,
    this.onNavigate,
  });

  final int imageId;
  final String imageName;
  final String imageUrl;
  final int sequence;
  final VoidCallback? onDelete;
  final Function(int)? onSequenceChanged;
  final Function(int)? onNavigate; // 1 for next, -1 for previous

  @override
  State<ImageDetailModal> createState() => _ImageDetailModalState();
}

class _ImageDetailModalState extends State<ImageDetailModal> {
  late TextEditingController _sequenceController;
  String? _ocrText;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _sequenceController = TextEditingController(
      text: widget.sequence.toString(),
    );
    _focusNode = FocusNode();
    _loadOcrText();
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadOcrText() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response =
          await OCRWorkbenchAPIGroup.getImageTextCall.call(
        imageId: widget.imageId,
      );

      if (response.succeeded) {
        final jsonBody = response.jsonBody as Map<String, dynamic>?;
        final text = jsonBody?['text'] as String? ?? 'No OCR text available';

        setState(() {
          _ocrText = text;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load OCR text';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_ocrText != null) {
      await Clipboard.setData(ClipboardData(text: _ocrText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteWithConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: Text('Are you sure you want to delete "${widget.imageName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete?.call();
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      if (Navigator.canPop(context)) Navigator.pop(context);
    } else if (event.isKeyPressed(LogicalKeyboardKey.keyC) &&
        HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.controlLeft)) {
      _copyToClipboard();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      widget.onNavigate?.call(1);
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      widget.onNavigate?.call(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => Navigator.pop(context),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            color: Color(0xB31E1E1F),
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {},
            child: Container(
              width: isMobile ? double.infinity : null,
              margin: isMobile
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 40,
                      vertical: 32,
                    ),
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 900,
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              ),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: isMobile
                    ? BorderRadius.zero
                    : BorderRadius.circular(12),
                border: isMobile
                    ? null
                    : Border.all(
                        color: theme.primary.withValues(alpha: 0.2),
                      ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.imageName,
                            style: theme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.borderColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.primary.withValues(alpha: 0.1),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            width: double.infinity,
                            color: Colors.black12,
                            constraints: const BoxConstraints(
                              minHeight: 300,
                              maxHeight: 500,
                            ),
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: theme.borderColor,
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Failed to load image'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Metadata
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sequence number
                                Row(
                                  children: [
                                    Text(
                                      'Sequence: ',
                                      style: theme.labelLarge,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          controller: _sequenceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (value) {
                                            final newSequence =
                                                int.tryParse(value);
                                            if (newSequence != null) {
                                              widget.onSequenceChanged
                                                  ?.call(newSequence);
                                            }
                                          },
                                          style: theme.bodyMedium,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          // OCR Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'OCR Text',
                                      style: theme.labelLarge,
                                    ),
                                    if (_ocrText != null && !_isLoading)
                                      IconButton(
                                        onPressed: _copyToClipboard,
                                        icon: const Icon(Icons.content_copy),
                                        tooltip: 'Copy (Ctrl+C)',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_isLoading)
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          theme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (_hasError)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.error,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _errorMessage ?? 'Unknown error',
                                          style: theme.bodySmall.copyWith(
                                            color: theme.error,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: _loadOcrText,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.error,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.primaryBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            theme.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: FormattedTextWidget(
                                      text: _ocrText ?? '',
                                      selectable: true,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Footer Actions
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _deleteWithConfirmation,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.1),
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement export/download
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Export feature coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.primary.withValues(alpha: 0.1),
                              foregroundColor: theme.primary,
                              side: BorderSide(color: theme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Navigation hints
                  if (!isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '← Prev  (ESC to close, Ctrl+C to copy)  Next →',
                            style: theme.bodySmall.copyWith(
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
        ),
      ),
    );
  }
}
