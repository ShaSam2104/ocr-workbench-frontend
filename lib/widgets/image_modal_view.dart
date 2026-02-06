import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/toasts/toast_manager.dart';
import '/models/content_item.dart';
import '/components/modals/ocr_processing_modal.dart';
import '/utils/clipboard_helper.dart';
import '/utils/markdown_to_html.dart';
import '/components/utils/formatted_text_widget.dart';

class ImageModalView extends StatefulWidget {
  final ContentItem item;
  final int bookId;
  final int chapterId;
  final VoidCallback onUpdate;

  const ImageModalView({
    super.key,
    required this.item,
    required this.bookId,
    required this.chapterId,
    required this.onUpdate,
  });

  @override
  State<ImageModalView> createState() => _ImageModalViewState();
}

class _ImageModalViewState extends State<ImageModalView> {
  bool _isEditMode = false;
  late TextEditingController _textController;
  bool _isSaving = false;
  bool _isProcessing = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.item.ocrText ?? widget.item.rawOcrText ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(String text) async {
    // Get the raw markdown text
    final rawText = widget.item.ocrText ?? widget.item.rawOcrText ?? '';

    try {
      // Convert markdown to HTML for rich text clipboard (better for Adobe InDesign)
      final html = convertMarkdownToHtml(rawText);

      // Get plain text version as fallback
      final plainText = markdownToPlainText(rawText);

      // Use HTML clipboard for rich text format (preserves underline, etc.)
      await copyHtmlToClipboard(html, plainText);

      if (mounted) {
        setState(() => _isCopied = true);
        ToastManager.showSuccess('Text copied to clipboard (rich text)');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isCopied = false);
        });
      }
    } catch (e) {
      if (mounted) {
        _showCopyErrorDialog(e.toString(), rawText);
      }
    }
  }

  Future<void> _saveText() async {
    setState(() => _isSaving = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.updateImageTextCall.call(
        imageId: widget.item.id,
        textWithFormatting: _textController.text,
        plainText: _textController.text, // For now, same as formatted
        hTTPBearer: token,
      );

      if (result.succeeded) {
        ToastManager.showSuccess('Text saved successfully');
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ToastManager.showError('Failed to save text');
      }
    } catch (e) {
      ToastManager.showError('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _processOCR() async {
    showDialog(
      context: context,
      builder: (context) => OcrProcessingModal(
        onProcessing: (customPrompt, model) async {
          setState(() => _isProcessing = true);
          try {
            final token = currentAuthenticationToken ?? '';
            final result = await OCRWorkbenchAPIGroup.processImagesOcrCall.call(
              imageIdsList: [widget.item.id],
              model: model,
              customPrompt: customPrompt,
              hTTPBearer: token,
            );

            if (result.succeeded) {
              ToastManager.showSuccess('OCR processing started');
              widget.onUpdate();
              Navigator.pop(context);
            } else {
              ToastManager.showError('Failed to start OCR processing');
            }
          } catch (e) {
            ToastManager.showError('Error: $e');
          } finally {
            setState(() => _isProcessing = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText =
        widget.item.ocrText != null || widget.item.rawOcrText != null;
    final rawText =
        widget.item.ocrText ?? widget.item.rawOcrText ?? 'No text extracted';
    final status = widget.item.ocrStatus ?? 'pending';

    return Dialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Image #${widget.item.sequence}',
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Status: ',
                                style: FlutterFlowTheme.of(context).bodySmall),
                            _buildStatusBadge(status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasText) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        key: ValueKey(_isCopied),
                        icon: Icon(
                          _isCopied ? Icons.check_circle : Icons.copy,
                          color: _isCopied ? Colors.green : null,
                        ),
                        onPressed:
                            _isCopied ? null : () => _copyToClipboard(rawText),
                        tooltip: 'Copy text',
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
                      onPressed: () =>
                          setState(() => _isEditMode = !_isEditMode),
                      tooltip: _isEditMode ? 'View Mode' : 'Edit Mode',
                    ),
                  ],
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 320),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Text(
                                          'Delete Image #${widget.item.sequence}?',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.0,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            foregroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          final token = currentAuthenticationToken ?? '';
                          await OCRWorkbenchAPIGroup.deleteImageCall.call(
                            imageId: widget.item.id,
                            hTTPBearer: token,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            widget.onUpdate();
                            ToastManager.showSuccess('Image deleted');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastManager.showError('Error deleting image: $e');
                          }
                        }
                      }
                    },
                    tooltip: 'Delete image',
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Row(
                children: [
                  // Image Preview
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                      ),
                      child: widget.item.url != null
                          ? InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: EdgeInsets.all(20),
                              minScale: 0.5,
                              maxScale: 4,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: widget.item.url!,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                    ),
                  ),
                  // Text Content
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: hasText
                          ? (_isEditMode
                              ? TextField(
                                  controller: _textController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: 'Edit extracted text...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 14,
                                      ),
                                )
                              : SingleChildScrollView(
                                  child: FormattedTextWidget(
                                    text: rawText,
                                    selectable: true,
                                  ),
                                ))
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.text_fields,
                                    size: 48,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No text extracted yet',
                                    style:
                                        FlutterFlowTheme.of(context).bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'pending' || status == 'failed')
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processOCR,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.play_arrow),
                      label: Text('Process OCR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (status == 'completed')
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processOCR,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh),
                      label: Text('Reprocess'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (_isEditMode) ...[
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveText,
                      icon: _isSaving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.save),
                      label: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'completed':
        bgColor = FlutterFlowTheme.of(context).success;
        textColor = Colors.white;
        label = 'Completed';
        break;
      case 'processing':
        bgColor = FlutterFlowTheme.of(context).warning;
        textColor = Colors.white;
        label = 'Processing';
        break;
      case 'failed':
        bgColor = FlutterFlowTheme.of(context).error;
        textColor = Colors.white;
        label = 'Failed';
        break;
      default:
        bgColor = FlutterFlowTheme.of(context).secondaryText;
        textColor = Colors.white;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Readex Pro',
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showCopyErrorDialog(String error, String originalText) {
    final platform = Theme.of(context).platform;
    final errorDetails = '''COPY ERROR DETAILS

Error: $error

Platform: $platform
Text length: ${originalText.length} characters

Original text:
${originalText.length > 500 ? originalText.substring(0, 500) + '...' : originalText}''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: FlutterFlowTheme.of(context).error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Copy Error',
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      errorDetails,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await copyToClipboard(errorDetails);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ToastManager.showSuccess(
                              'Error details copied to clipboard');
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Copy Error'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
