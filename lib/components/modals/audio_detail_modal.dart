import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/utils/formatted_text_widget.dart';

class AudioDetailModal extends StatefulWidget {
  const AudioDetailModal({
    super.key,
    required this.audioId,
    required this.audioName,
    required this.audioUrl,
    required this.duration,
    this.onDelete,
    this.onNavigate,
  });

  final int audioId;
  final String audioName;
  final String audioUrl;
  final int duration; // in seconds
  final VoidCallback? onDelete;
  final Function(int)? onNavigate; // 1 for next, -1 for previous

  @override
  State<AudioDetailModal> createState() => _AudioDetailModalState();
}

class _AudioDetailModalState extends State<AudioDetailModal> {
  String? _transcript;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isPlaying = false;
  int _currentPosition = 0;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadTranscript();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTranscript() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response =
          await OCRWorkbenchAPIGroup.getAudioTranscriptCall.call(
        audioId: widget.audioId,
      );

      if (response.succeeded) {
        final jsonBody = response.jsonBody as Map<String, dynamic>?;
        final transcript =
            jsonBody?['transcript'] as String? ?? 'No transcript available';

        setState(() {
          _transcript = transcript;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load transcript';
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
    if (_transcript != null) {
      await Clipboard.setData(ClipboardData(text: _transcript!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcript copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteWithConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio'),
        content: Text(
          'Are you sure you want to delete "${widget.audioName}"?',
        ),
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
    } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                            widget.audioName,
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
                          // Audio Player
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Waveform visualization
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: theme.primaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: _WaveformPainter(
                                      color: theme.primary,
                                      progress: widget.duration > 0
                                          ? _currentPosition /
                                              widget.duration
                                          : 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Player Controls
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: theme.bodySmall,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_currentPosition > 0) {
                                              setState(() {
                                                _currentPosition =
                                                    (_currentPosition - 5)
                                                        .clamp(
                                                          0,
                                                          widget.duration,
                                                        );
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.replay_5),
                                          iconSize: 28,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: theme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isPlaying = !_isPlaying;
                                              });
                                            },
                                            icon: Icon(
                                              _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                            iconSize: 32,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (_currentPosition <
                                                widget.duration) {
                                              setState(() {
                                                _currentPosition =
                                                    (_currentPosition + 5)
                                                        .clamp(
                                                          0,
                                                          widget.duration,
                                                        );
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.forward_5),
                                          iconSize: 28,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDuration(widget.duration),
                                      style: theme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Slider
                                Slider(
                                  value: widget.duration > 0
                                      ? _currentPosition /
                                          widget.duration
                                      : 0,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentPosition =
                                          (value * widget.duration).toInt();
                                    });
                                  },
                                  activeColor: theme.primary,
                                  inactiveColor: theme.primary
                                      .withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                          ),
                          // Transcript
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
                                      'Transcript',
                                      style: theme.labelLarge,
                                    ),
                                    if (_transcript != null && !_isLoading)
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
                                          onPressed: _loadTranscript,
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
                                      text: _transcript ?? '',
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
                            '← Prev  (Space to play/pause, ESC to close, Ctrl+C to copy)  Next →',
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

class _WaveformPainter extends CustomPainter {
  final Color color;
  final double progress;

  _WaveformPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / 20;
    const barSpacing = 2.0;
    final centerY = size.height / 2;

    for (int i = 0; i < 20; i++) {
      final xPos = i * (barWidth + barSpacing) + barSpacing;
      final heightFactor = (i % 7 + 1) / 7; // Varying heights
      final barHeight = size.height * heightFactor * 0.7;

      final currentPaint = (i / 20) < progress ? paint : progressPaint;

      canvas.drawLine(
        Offset(xPos, centerY - barHeight / 2),
        Offset(xPos, centerY + barHeight / 2),
        currentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
