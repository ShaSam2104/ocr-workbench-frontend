import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/toasts/toast_manager.dart';
import '/models/content_item.dart';
import '/widgets/audio_player_widget.dart';
import '/components/modals/transcription_processing_modal.dart';
import '/utils/clipboard_helper.dart';

class AudioModalView extends StatefulWidget {
  final ContentItem item;
  final int bookId;
  final int chapterId;
  final VoidCallback onUpdate;

  const AudioModalView({
    super.key,
    required this.item,
    required this.bookId,
    required this.chapterId,
    required this.onUpdate,
  });

  @override
  State<AudioModalView> createState() => _AudioModalViewState();
}

class _AudioModalViewState extends State<AudioModalView> {
  bool _isEditMode = false;
  late TextEditingController _textController;
  bool _isSaving = false;
  bool _isProcessing = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.item.transcript ?? widget.item.rawTranscript ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveTranscript() async {
    setState(() => _isSaving = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.updateAudioTranscriptCall.call(
        audioId: widget.item.id,
        textWithFormatting: _textController.text,
        plainText: _textController.text,
        hTTPBearer: token,
      );

      if (result.succeeded) {
        ToastManager.showSuccess('Transcript saved successfully');
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ToastManager.showError('Failed to save transcript');
      }
    } catch (e) {
      ToastManager.showError('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _processTranscription() async {
    showDialog(
      context: context,
      builder: (context) => TranscriptionProcessingModal(
        onProcessing: (customPrompt, model, languageHint) async {
          setState(() => _isProcessing = true);
          try {
            final token = currentAuthenticationToken ?? '';
            final result = await OCRWorkbenchAPIGroup.transcribeAudiosCall.call(
              audioIdsList: [widget.item.id],
              model: model,
              customPrompt: customPrompt,
              languageHint: languageHint,
              hTTPBearer: token,
            );

            if (result.succeeded) {
              ToastManager.showSuccess('Transcription started');
              widget.onUpdate();
              Navigator.pop(context);
            } else {
              ToastManager.showError('Failed to start transcription');
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
    final hasTranscript = widget.item.transcript != null || widget.item.rawTranscript != null;
    final displayText = widget.item.transcript ?? widget.item.rawTranscript ?? 'No transcript available';
    final status = widget.item.transcriptionStatus ?? 'pending';

    return Dialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
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
                          'Audio #${widget.item.sequence}',
                          style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Status: ', style: FlutterFlowTheme.of(context).bodySmall),
                            _buildStatusBadge(status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasTranscript) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        key: ValueKey(_isCopied),
                        icon: Icon(
                          _isCopied ? Icons.check_circle : Icons.copy,
                          color: _isCopied ? Colors.green : null,
                        ),
                        onPressed: _isCopied
                            ? null
                            : () async {
                                try {
                                  await copyToClipboard(displayText);
                                  if (mounted) {
                                    setState(() => _isCopied = true);
                                    ToastManager.showSuccess('Transcript copied to clipboard');
                                    Future.delayed(const Duration(seconds: 2), () {
                                      if (mounted) setState(() => _isCopied = false);
                                    });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ToastManager.showError('Failed to copy: ${e.toString()}');
                                  }
                                }
                              },
                        tooltip: 'Copy transcript',
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
                      onPressed: () => setState(() => _isEditMode = !_isEditMode),
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
                          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                                        color: FlutterFlowTheme.of(context).error,
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Text(
                                          'Delete Audio #${widget.item.sequence}?',
                                          style: FlutterFlowTheme.of(context).bodyLarge.override(
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
                                          onPressed: () => Navigator.pop(context, false),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                                            foregroundColor: FlutterFlowTheme.of(context).primaryText,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            backgroundColor: FlutterFlowTheme.of(context).error,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
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
                          await OCRWorkbenchAPIGroup.deleteAudioCall.call(
                            audioId: widget.item.id,
                            hTTPBearer: token,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            widget.onUpdate();
                            ToastManager.showSuccess('Audio deleted');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastManager.showError('Error deleting audio: $e');
                          }
                        }
                      }
                    },
                    tooltip: 'Delete audio',
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Audio Player
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
              child: widget.item.url != null
                  ? AudioPlayerWidget(audioUrl: widget.item.url!)
                  : Icon(Icons.audio_file, size: 64),
            ),
            // Transcript Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: hasTranscript
                    ? (_isEditMode
                        ? TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Edit transcript...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 14,
                            ),
                          )
                        : SingleChildScrollView(
                            child: MarkdownBody(
                              data: displayText,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 14,
                                ),
                                h1: FlutterFlowTheme.of(context).headlineLarge,
                                h2: FlutterFlowTheme.of(context).headlineMedium,
                                h3: FlutterFlowTheme.of(context).headlineSmall,
                                tableHead: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                                tableBody: FlutterFlowTheme.of(context).bodyMedium,
                                tableBorder: TableBorder.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1,
                                ),
                              ),
                            ),
                          ))
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.transcribe,
                              size: 48,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No transcript available yet',
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                          ],
                        ),
                      ),
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
                      onPressed: _isProcessing ? null : _processTranscription,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.play_arrow),
                      label: Text('Process Transcription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (status == 'completed')
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processTranscription,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh),
                      label: Text('Reprocess'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).secondaryText,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (_isEditMode) ...[
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveTranscript,
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
}