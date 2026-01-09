import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';

class ContentArea extends StatefulWidget {
  const ContentArea({
    super.key,
    required this.bookId,
    required this.chapterId,
    required this.onItemsChanged,
  });

  final int bookId;
  final int chapterId;
  final VoidCallback onItemsChanged;

  @override
  State<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  late FocusNode _focusNode;
  List<ContentItem> _items = [];
  Set<int> _selectedIndices = {};
  int? _focusedIndex;
  bool _isLoading = true;
  int? _editingSequenceIndex;
  late TextEditingController _sequenceEditController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _sequenceEditController = TextEditingController();
    _loadContent();
  }

  @override
  void didUpdateWidget(ContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId ||
        oldWidget.bookId != widget.bookId) {
      _selectedIndices.clear();
      _focusedIndex = null;
      _loadContent();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _sequenceEditController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);

      // For now, use mock data or fetch from chapter details
      // In a real implementation, these API calls would be:
      // - OCRWorkbenchAPIGroup.listImagesCall
      // - OCRWorkbenchAPIGroup.listAudiosCall
      
      // Loading chapter data to get images/audios
      final chapterResult = await OCRWorkbenchAPIGroup.getChapterCall.call(
        chapterId: widget.chapterId,
      );

      final newItems = <ContentItem>[];

      if (chapterResult.succeeded) {
        final chapterData = chapterResult.jsonBody as Map?;
        
        // Parse images from chapter data
        final images = chapterData?['images'] as List? ?? [];
        for (var img in images) {
          newItems.add(ContentItem(
            id: img['id'] as int,
            name: img['name'] as String? ?? 'Image',
            sequence: img['sequence'] as int? ?? 0,
            type: ContentType.image,
            url: img['url'] as String?,
            thumbnailUrl: img['thumbnail_url'] as String?,
            ocrStatus: _getOCRStatus(img['id'] as int),
            sizeBytes: img['size_bytes'] as int?,
          ));
        }

        // Parse audios from chapter data
        final audios = chapterData?['audios'] as List? ?? [];
        for (var audio in audios) {
          newItems.add(ContentItem(
            id: audio['id'] as int,
            name: audio['name'] as String? ?? 'Audio',
            sequence: audio['sequence'] as int? ?? 0,
            type: ContentType.audio,
            url: audio['url'] as String?,
            durationSeconds: audio['duration_seconds'] as int?,
            transcriptionStatus:
                _getTranscriptionStatus(audio['id'] as int),
            sizeBytes: audio['size_bytes'] as int?,
          ));
        }
      }

      // Sort by sequence
      newItems.sort((a, b) => a.sequence.compareTo(b.sequence));

      setState(() {
        _items = newItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getOCRStatus(int imageId) {
    // Get OCR status from the app state or API
    // For now, return pending as default
    return 'pending';
  }

  String _getTranscriptionStatus(int audioId) {
    // Get transcription status from the app state or API
    // For now, return pending as default
    return 'pending';
  }

  void _handleKeyEvent(KeyEvent event) {
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.keyA) &&
        HardwareKeyboard.instance.isControlPressed) {
      setState(() {
        _selectedIndices =
            Set.from(List.generate(_items.length, (i) => i));
      });
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.delete)) {
      _deleteSelected();
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
      setState(() => _selectedIndices.clear());
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.arrowDown)) {
      _moveFocus(1);
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.arrowUp)) {
      _moveFocus(-1);
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
      if (_focusedIndex != null) {
        _showItemDetail(_focusedIndex!);
      }
    } else if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.tab)) {
      _moveFocus(HardwareKeyboard.instance.isShiftPressed ? -1 : 1);
    }
  }

  void _moveFocus(int direction) {
    if (_items.isEmpty) return;
    final currentIndex = _focusedIndex ?? 0;
    final newIndex =
        (currentIndex + direction).clamp(0, _items.length - 1);
    setState(() => _focusedIndex = newIndex);
  }

  void _deleteSelected() async {
    if (_selectedIndices.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedIndices.length} item(s)?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TODO: Implement API calls when available
      // await OCRWorkbenchAPIGroup.deleteImageCall.call(imageId: item.id)
      // or
      // await OCRWorkbenchAPIGroup.deleteAudioCall.call(audioId: item.id)

      setState(() {
        final indexesToRemove = _selectedIndices.toList()
          ..sort((a, b) => b.compareTo(a));
        for (final index in indexesToRemove) {
          if (index < _items.length) {
            _items.removeAt(index);
          }
        }
        _selectedIndices.clear();
      });

      widget.onItemsChanged();
    } catch (e) {
      print('Error deleting items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting items')),
        );
      }
    }
  }

  void _showItemDetail(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];

    if (item.type == ContentType.image) {
      _showImageModal(item);
    } else {
      _showAudioModal(item);
    }
  }

  void _showImageModal(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Image #${item.sequence}: ${item.name}',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            // Image
            if (item.url != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Image.network(item.url!),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Icon(Icons.image_not_supported, size: 64),
              ),
            Divider(),
            // Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OCR Status:',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                      _buildStatusBadge(item.ocrStatus),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (item.ocrStatus == 'completed')
                    _buildOCRTextSection(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioModal(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Audio #${item.sequence}: ${item.name}',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            // Player
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (item.url != null)
                    AudioPlayerWidget(audioUrl: item.url!)
                  else
                    Icon(Icons.audio_file, size: 64),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transcription Status:',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                      _buildStatusBadge(item.transcriptionStatus),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (item.transcriptionStatus == 'completed')
                    _buildTranscriptSection(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOCRTextSection(ContentItem item) {
    return FutureBuilder<ApiCallResponse>(
      future: OCRWorkbenchAPIGroup.getImageTextCall.call(
        imageId: item.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data?.succeeded != true) {
          return Text('Failed to load OCR text');
        }

        final jsonBody = snapshot.data?.jsonBody;
        final text = jsonBody is Map ? jsonBody['text'] as String? : null;

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Text(text ?? 'No text extracted'),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptSection(ContentItem item) {
    return FutureBuilder<ApiCallResponse>(
      future: OCRWorkbenchAPIGroup.getAudioTranscriptCall.call(
        audioId: item.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data?.succeeded != true) {
          return Text('Failed to load transcript');
        }

        final jsonBody = snapshot.data?.jsonBody;
        final transcript = jsonBody is Map ? jsonBody['transcript'] as String? : null;

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Text(transcript ?? 'No transcript available'),
          ),
        );
      },
    );
  }

  void _startEditingSequence(int index) {
    if (index >= 0 && index < _items.length) {
      setState(() {
        _editingSequenceIndex = index;
        _sequenceEditController.text = _items[index].sequence.toString();
      });
    }
  }

  void _confirmSequenceEdit() async {
    if (_editingSequenceIndex == null) return;
    
    try {
      final newSequence = int.tryParse(_sequenceEditController.text);
      if (newSequence == null || newSequence < 1) return;
      
      // TODO: Implement API calls when available
      // if (item.type == ContentType.image) {
      //   await OCRWorkbenchAPIGroup.updateImageSequenceCall.call(
      //     imageId: item.id,
      //     sequence: newSequence,
      //   );
      // } else {
      //   await OCRWorkbenchAPIGroup.updateAudioSequenceCall.call(
      //     audioId: item.id,
      //     sequence: newSequence,
      //   );
      // }

      // For now, just update locally
      setState(() {
        _items[_editingSequenceIndex!].sequence = newSequence;
        _items.sort((a, b) => a.sequence.compareTo(b.sequence));
      });

      widget.onItemsChanged();
    } catch (e) {
      print('Error updating sequence: $e');
    } finally {
      setState(() => _editingSequenceIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
    final crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          // Toolbar
          if (_selectedIndices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedIndices.length} selected',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: _deleteSelected,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () =>
                            setState(() => _selectedIndices.clear()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: _isLoading
                ? _buildSkeletonLoader()
                : _items.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) =>
                            _buildGridItem(context, index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64.0,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No content in this chapter',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Upload images or audio files to get started',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final item = _items[index];
    final isSelected = _selectedIndices.contains(index);
    final isFocused = _focusedIndex == index;
    final isEditing = _editingSequenceIndex == index;

    return GestureDetector(
      onTap: () {
        if (HardwareKeyboard.instance.isShiftPressed) {
          // Range select
          if (_selectedIndices.isEmpty) {
            setState(() => _selectedIndices.add(index));
          } else {
            final min = _selectedIndices.reduce((a, b) => a < b ? a : b);
            final max = _selectedIndices.reduce((a, b) => a > b ? a : b);
            final start = min < index ? min : index;
            final end = max > index ? max : index;
            setState(() {
              for (int i = start; i <= end; i++) {
                _selectedIndices.add(i);
              }
            });
          }
        } else if (HardwareKeyboard.instance.isControlPressed) {
          // Toggle select
          setState(() {
            if (isSelected) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
          });
        } else {
          // Show detail
          _showItemDetail(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
              : FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isFocused
                ? FlutterFlowTheme.of(context).primary
                : isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).alternate,
            width: isFocused ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (item.type == ContentType.image &&
                        item.thumbnailUrl != null)
                      Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    else if (item.type == ContentType.audio)
                      _buildAudioWaveform()
                    else
                      Icon(
                        item.type == ContentType.image
                            ? Icons.image
                            : Icons.audio_file,
                        size: 48.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sequence number (editable)
                  if (isEditing)
                    TextFormField(
                      controller: _sequenceEditController,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) => _confirmSequenceEdit(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        border: OutlineInputBorder(),
                        hintText: 'Sequence',
                      ),
                    )
                  else
                    InkWell(
                      onDoubleTap: () => _startEditingSequence(index),
                      child: Text(
                        '#${item.sequence}',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontWeight: FontWeight.w600,
                              fontSize: 10.0,
                            ),
                      ),
                    ),
                  SizedBox(height: 4.0),
                  // Status badges
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusBadge(
                          item.type == ContentType.image
                              ? item.ocrStatus
                              : item.transcriptionStatus,
                        ),
                      ),
                      if (item.type == ContentType.audio &&
                          item.durationSeconds != null)
                        SizedBox(width: 4.0),
                      if (item.type == ContentType.audio &&
                          item.durationSeconds != null)
                        Text(
                          '${item.durationSeconds! ~/ 60}:${(item.durationSeconds! % 60).toString().padLeft(2, '0')}',
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                fontSize: 9.0,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return CustomPaint(
      painter: WaveformPainter(
        color: FlutterFlowTheme.of(context).primary,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildStatusBadge(String? status) {
    String icon = '⏸️';
    Color color = Colors.grey;

    if (status == 'completed') {
      icon = '✅';
      color = Colors.green;
    } else if (status == 'processing') {
      icon = '⏳';
      color = Colors.orange;
    } else if (status == 'failed') {
      icon = '❌';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 10.0)),
          SizedBox(width: 2.0),
          Text(
            status ?? 'Unknown',
            style: TextStyle(fontSize: 8.0, color: color),
          ),
        ],
      ),
    );
  }
}

class ContentItem {
  final int id;
  final String name;
  int sequence;
  final ContentType type;
  final String? url;
  final String? thumbnailUrl;
  final String? ocrStatus;
  final String? transcriptionStatus;
  final int? durationSeconds;
  final int? sizeBytes;

  ContentItem({
    required this.id,
    required this.name,
    required this.sequence,
    required this.type,
    this.url,
    this.thumbnailUrl,
    this.ocrStatus = 'pending',
    this.transcriptionStatus = 'pending',
    this.durationSeconds,
    this.sizeBytes,
  });
}

enum ContentType { image, audio }

class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final height = size.height;
    final width = size.width;
    final centerY = height / 2;
    final barWidth = width / 12;

    for (int i = 0; i < 12; i++) {
      final randomHeight = (5 + (i * 7) % 15).toDouble();
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, centerY - randomHeight / 2),
        Offset(x, centerY + randomHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => false;
}

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CustomPaint(
            painter: WaveformPainter(
              color: FlutterFlowTheme.of(context).primary,
            ),
            size: Size(300, 60),
          ),
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() => _isPlaying = !_isPlaying);
                // TODO: Implement actual audio playback
              },
            ),
          ],
        ),
      ],
    );
  }
}
