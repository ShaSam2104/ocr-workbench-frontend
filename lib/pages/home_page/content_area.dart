import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/toasts/toast_manager.dart';
import '/models/content_item.dart';
import '/enums/scroll_direction.dart';
import '/widgets/image_modal_view.dart';
import '/widgets/audio_modal_view.dart';
import '/painters/waveform_painter.dart';

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

class _ContentAreaState extends State<ContentArea> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late ScrollController _imageScrollController;
  late ScrollController _audioScrollController;
  
  // Tab management
  int _selectedTab = 0; // 0 = images, 1 = audio
  
  // Image-specific state
  List<ContentItem> _imageItems = [];
  Set<int> _imageSelectedIndices = {};
  bool _imageIsLoading = true;
  bool _imageIsLoadingMore = false;
  int _imageCurrentPage = 1;
  int _imageTotalItems = 0;
  bool _imageHasMore = true;
  
  // Audio-specific state
  List<ContentItem> _audioItems = [];
  Set<int> _audioSelectedIndices = {};
  bool _audioIsLoading = true;
  bool _audioIsLoadingMore = false;
  int _audioCurrentPage = 1;
  int _audioTotalItems = 0;
  bool _audioHasMore = true;
  
  // Shared state
  Set<int> _selectedIndices = {};
  int? _focusedIndex;
  double _zoomLevel = 1.0; // 0.5 to 2.0 range
  
  // Reorder state
  bool _isReorderMode = false;
  int? _draggedIndex;
  int? _dragOverIndex;
  bool _isApiCallInProgress = false;

  // Smooth auto-scroll with Ticker
  Ticker? _autoScrollTicker;
  ScrollDirection _currentScrollDirection = ScrollDirection.none;
  double _scrollVelocity = 0.0;
  double _targetScrollVelocity = 0.0;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _imageScrollController = ScrollController();
    _audioScrollController = ScrollController();
    _imageScrollController.addListener(_onScroll);
    _audioScrollController.addListener(_onScroll);
    _loadImagesContent();
    // Request focus after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(ContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId ||
        oldWidget.bookId != widget.bookId) {
      _selectedIndices.clear();
      _imageSelectedIndices.clear();
      _audioSelectedIndices.clear();
      _focusedIndex = null;
      _imageCurrentPage = 1;
      _audioCurrentPage = 1;
      _imageHasMore = true;
      _audioHasMore = true;
      _imageItems.clear();
      _audioItems.clear();
      _loadImagesContent();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _imageScrollController.dispose();
    _audioScrollController.dispose();
    _autoScrollTicker?.dispose();
    super.dispose();
  }

  Future<void> _loadImagesContent({bool loadMore = false}) async {
    if (loadMore && (_imageIsLoadingMore || !_imageHasMore)) return;
    
    try {
      setState(() {
        if (loadMore) {
          _imageIsLoadingMore = true;
        } else {
          _imageIsLoading = true;
          _imageCurrentPage = 1;
          _imageItems.clear();
        }
      });

      final token = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.getChapterImagesCall.call(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        page: _imageCurrentPage,
        pageSize: 20,
        hTTPBearer: token,
      );

      final newItems = <ContentItem>[];

      if (result.succeeded) {
        final responseData = result.jsonBody as Map<String, dynamic>?;
        final imagesData = responseData?['images'] as Map<String, dynamic>?;
        
        if (imagesData != null) {
          final imageItems = imagesData['items'] as List<dynamic>? ?? [];
          for (var img in imageItems) {
            final imageMap = img as Map<String, dynamic>;
            final ocrTextMap = imageMap['ocr_text'] as Map<String, dynamic>?;
            newItems.add(ContentItem(
              id: imageMap['id'] as int,
              name: 'Image ${imageMap['sequence_number']}',
              sequence: imageMap['sequence_number'] as int? ?? 0,
              type: ContentType.image,
              url: imageMap['image_url'] as String?,
              thumbnailUrl: imageMap['image_url'] as String?,
              ocrStatus: imageMap['ocr_status'] as String? ?? 'pending',
              ocrText: ocrTextMap?['edited_text_with_formatting'] as String?,
              rawOcrText: ocrTextMap?['raw_text_with_formatting'] as String?,
            ));
          }
          
          _imageTotalItems = imagesData['total'] as int? ?? 0;
          final loadedCount = _imageItems.length + newItems.length;
          _imageHasMore = loadedCount < _imageTotalItems;
        }
      }

      newItems.sort((a, b) => a.sequence.compareTo(b.sequence));

      setState(() {
        if (loadMore) {
          _imageItems.addAll(newItems);
          _imageIsLoadingMore = false;
        } else {
          _imageItems = newItems;
          _imageIsLoading = false;
        }
        if (_imageHasMore) _imageCurrentPage++;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _imageIsLoading = false;
        _imageIsLoadingMore = false;
      });
    }
  }

  Future<void> _loadAudiosContent({bool loadMore = false}) async {
    if (loadMore && (_audioIsLoadingMore || !_audioHasMore)) return;
    
    try {
      setState(() {
        if (loadMore) {
          _audioIsLoadingMore = true;
        } else {
          _audioIsLoading = true;
          _audioCurrentPage = 1;
          _audioItems.clear();
        }
      });

      final token = currentAuthenticationToken ?? '';

      final result = await OCRWorkbenchAPIGroup.getChapterAudiosCall.call(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        page: _audioCurrentPage,
        pageSize: 20,
        hTTPBearer: token,
      );
      final newItems = <ContentItem>[];

      if (result.succeeded) {
        final responseData = result.jsonBody as Map<String, dynamic>?;
        
        final audiosData = responseData?['audios'] as Map<String, dynamic>?;
        
        if (audiosData != null) {
          final audioItems = audiosData['items'] as List<dynamic>? ?? [];
          print('Audio items count: ${audioItems.length}');
          print('Total from API: ${audiosData['total']}');
          
          for (var audio in audioItems) {
            try {
              final audioMap = audio as Map<String, dynamic>;
              final transcriptMap = audioMap['transcript'] as Map<String, dynamic>?;
              final newItem = ContentItem(
                id: audioMap['id'] as int,
                name: 'Audio ${audioMap['sequence_number']}',
                sequence: audioMap['sequence_number'] as int? ?? 0,
                type: ContentType.audio,
                durationSeconds: audioMap['duration_seconds'] as int?,
                transcriptionStatus: audioMap['transcription_status'] as String? ?? 'pending',
                transcript: transcriptMap?['edited_text_with_formatting'] as String?,
                rawTranscript: transcriptMap?['raw_text_with_formatting'] as String?,
              );
              newItems.add(newItem);
              print('Added audio item: ${newItem.name} (ID: ${newItem.id})');
            } catch (e) {
              print('Error parsing audio item: $e');
            }
          }
          
          _audioTotalItems = audiosData['total'] as int? ?? 0;
          final loadedCount = _audioItems.length + newItems.length;
          _audioHasMore = loadedCount < _audioTotalItems;
          print('Total items: $_audioTotalItems, Loaded: $loadedCount, Has more: $_audioHasMore');
        } else {
          print('ERROR: audiosData is null');
        }
      } else {
        print('ERROR: API call failed with status ${result.statusCode}');
        print('Error response: ${result.jsonBody}');
      }

      newItems.sort((a, b) => a.sequence.compareTo(b.sequence));

      setState(() {
        if (loadMore) {
          _audioItems.addAll(newItems);
          _audioIsLoadingMore = false;
        } else {
          _audioItems = newItems;
          _audioIsLoading = false;
        }
        if (_audioHasMore) _audioCurrentPage++;
        print('After setState: _audioItems.length = ${_audioItems.length}');
      });
    } catch (e, st) {
      print('===== AUDIO LOAD ERROR =====');
      print('Error: $e');
      print('Stack trace: $st');
      setState(() {
        _audioIsLoading = false;
        _audioIsLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_selectedTab == 0) {
      // Images tab
      if (_imageScrollController.position.pixels >= _imageScrollController.position.maxScrollExtent - 200) {
        _loadImagesContent(loadMore: true);
      }
    } else {
      // Audio tab
      if (_audioScrollController.position.pixels >= _audioScrollController.position.maxScrollExtent - 200) {
        _loadAudiosContent(loadMore: true);
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isModifierPressed = HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;

    // Zoom in: Cmd/Ctrl + Plus or Cmd/Ctrl + Equal
    if (isModifierPressed && 
        (event.logicalKey == LogicalKeyboardKey.equal || 
         event.logicalKey == LogicalKeyboardKey.add ||
         event.logicalKey == LogicalKeyboardKey.numpadAdd)) {
      setState(() {
        _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 2.0);
      });
      print('Zoom In: $_zoomLevel');
    }
    // Zoom out: Cmd/Ctrl + Minus
    else if (isModifierPressed && 
             (event.logicalKey == LogicalKeyboardKey.minus ||
              event.logicalKey == LogicalKeyboardKey.numpadSubtract)) {
      setState(() {
        _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 2.0);
      });
      print('Zoom Out: $_zoomLevel');
    }
    // Reset zoom: Cmd/Ctrl + 0
    else if (isModifierPressed && 
             (event.logicalKey == LogicalKeyboardKey.digit0 ||
              event.logicalKey == LogicalKeyboardKey.numpad0)) {
      setState(() {
        _zoomLevel = 1.0;
      });
      print('Zoom Reset: $_zoomLevel');
    }
    else if (event.logicalKey == LogicalKeyboardKey.keyA && isModifierPressed) {
      final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
      setState(() {
        _selectedIndices = Set.from(List.generate(currentItems.length, (i) => i));
      });
    } else if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      _deleteSelected();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _selectedIndices.clear());
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _moveFocus(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _moveFocus(1);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_focusedIndex != null) {
        _showItemDetail(_focusedIndex!);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      _moveFocus(HardwareKeyboard.instance.isShiftPressed ? -1 : 1);
    }
  }

  void _moveFocus(int direction) {
    final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
    if (currentItems.isEmpty) return;
    final currentIndex = _focusedIndex ?? 0;
    final newIndex =
        (currentIndex + direction).clamp(0, currentItems.length - 1);
    setState(() => _focusedIndex = newIndex);
  }

  void _deleteSelected() async {
    if (_selectedIndices.isEmpty) return;

    final itemType = _selectedTab == 0 ? 'image' : 'audio';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
                        'Delete ${_selectedIndices.length} $itemType(s)?',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  'This action cannot be undone.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontSize: 12.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 14.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Delete',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
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

    if (confirmed != true) return;

    try {
      final token = currentAuthenticationToken ?? '';
      final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
      final itemsToDelete = _selectedIndices.map((i) => currentItems[i]).toList();

      // Delete each item via API
      for (final item in itemsToDelete) {
        if (_selectedTab == 0) {
          await OCRWorkbenchAPIGroup.deleteImageCall.call(
            imageId: item.id,
            hTTPBearer: token,
          );
        } else {
          await OCRWorkbenchAPIGroup.deleteAudioCall.call(
            audioId: item.id,
            hTTPBearer: token,
          );
        }
      }

      // Remove from local state
      setState(() {
        final indexesToRemove = _selectedIndices.toList()
          ..sort((a, b) => b.compareTo(a));
        if (_selectedTab == 0) {
          for (final index in indexesToRemove) {
            if (index < _imageItems.length) {
              _imageItems.removeAt(index);
              _imageTotalItems--;
            }
          }
        } else {
          for (final index in indexesToRemove) {
            if (index < _audioItems.length) {
              _audioItems.removeAt(index);
              _audioTotalItems--;
            }
          }
        }
        _selectedIndices.clear();
      });

      widget.onItemsChanged();

      if (mounted) {
        ToastManager.showSuccess('Deleted ${itemsToDelete.length} $itemType(s)');
      }
    } catch (e) {
      print('Error deleting items: $e');
      if (mounted) {
        ToastManager.showError('Error deleting items: $e');
      }
    }
  }

  Future<void> _deleteAllInChapter() async {
    final itemType = _selectedTab == 0 ? 'images' : 'audios';
    final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
    
    if (currentItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
                        'Delete All $itemType?',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  'This will delete all ${currentItems.length} $itemType. This action cannot be undone.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontSize: 12.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 14.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Delete All',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
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

    if (confirmed != true) return;

    try {
      final token = currentAuthenticationToken ?? '';

      // Call bulk delete API
      if (_selectedTab == 0) {
        await OCRWorkbenchAPIGroup.deleteAllImagesInChapterCall.call(
          chapterId: widget.chapterId,
          hTTPBearer: token,
        );
      } else {
        await OCRWorkbenchAPIGroup.deleteAllAudiosInChapterCall.call(
          chapterId: widget.chapterId,
          hTTPBearer: token,
        );
      }

      // Clear local state
      setState(() {
        if (_selectedTab == 0) {
          _imageItems.clear();
          _imageTotalItems = 0;
        } else {
          _audioItems.clear();
          _audioTotalItems = 0;
        }
        _selectedIndices.clear();
      });

      widget.onItemsChanged();

      if (mounted) {
        ToastManager.showSuccess('Deleted all $itemType in chapter');
      }
    } catch (e) {
      print('Error deleting all $itemType: $e');
      if (mounted) {
        ToastManager.showError('Error deleting all $itemType: $e');
      }
    }
  }

  Future<void> _processItem(ContentItem item) async {
    final token = currentAuthenticationToken ?? '';
    
    try {
      if (item.type == ContentType.image) {
        final result = await OCRWorkbenchAPIGroup.processImagesOcrCall.call(
          imageIdsList: [item.id],
          hTTPBearer: token,
        );
        
        if (result.succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OCR processing started for ${item.name}'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh content to show updated status
          await _loadImagesContent();
        } else {
          throw Exception('Failed to start OCR processing');
        }
      } else {
        final result = await OCRWorkbenchAPIGroup.transcribeAudiosCall.call(
          audioIdsList: [item.id],
          hTTPBearer: token,
        );
        
        if (result.succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcription started for ${item.name}'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh content to show updated status
          await _loadAudiosContent();
        } else {
          throw Exception('Failed to start transcription');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
      if (!_isReorderMode) {
        _draggedIndex = null;
        _dragOverIndex = null;
      }
    });
  }

  void _onItemDragStarted(int index) {
    setState(() {
      _draggedIndex = index;
    });
  }

  void _onItemDragEnded() {
    setState(() {
      _draggedIndex = null;
      _dragOverIndex = null;
    });
    _stopAutoScroll();
  }

  void _onItemDragOver(int index) {
    if (_draggedIndex == null || _draggedIndex == index) return;
    
    setState(() {
      _dragOverIndex = index;
    });
  }

  void _onItemDropped(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || _isApiCallInProgress) return;

    setState(() {
      final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
      
      // Reorder the list locally (optimistic update)
      final item = currentItems.removeAt(oldIndex);
      currentItems.insert(newIndex, item);
      
      // Update sequence numbers (1-indexed for backend compatibility)
      for (int i = 0; i < currentItems.length; i++) {
        currentItems[i].sequence = i + 1;
      }
    });

    // Send API call immediately
    _sendReorderToBackend(oldIndex + 1, newIndex + 1);
  }

  Future<void> _sendReorderToBackend(int currentSeqNum, int newSeqNum) async {
    if (_isApiCallInProgress) return;

    try {
      setState(() => _isApiCallInProgress = true);

      final token = currentAuthenticationToken ?? '';

      if (_selectedTab == 0) {
        // Images reorder
        await OCRWorkbenchAPIGroup.updateImageOrderCall.call(
          chapterId: widget.chapterId,
          hTTPBearer: token,
          reordersList: [
            {
              'currentSequenceNumber': currentSeqNum,
              'newSequenceNumber': newSeqNum,
            }
          ],
        );
      } else {
        // Audios reorder
        await OCRWorkbenchAPIGroup.updateAudiosOrderCall.call(
          chapterId: widget.chapterId,
          hTTPBearer: token,
          reordersList: [
            {
              'currentSequenceNumber': currentSeqNum,
              'newSequenceNumber': newSeqNum,
            }
          ],
        );
      }

      if (mounted) {
        print('[REORDER] Successfully moved item from $currentSeqNum to $newSeqNum');
      }
    } catch (e) {
      print('[REORDER ERROR] Failed to reorder: $e');
      if (mounted) {
        ToastManager.showError('Reorder failed. Reloading...');
        // Reload and exit reorder mode on failure
        setState(() => _isReorderMode = false);
        if (_selectedTab == 0) {
          await _loadImagesContent();
        } else {
          await _loadAudiosContent();
        }
      }
    } finally {
      setState(() => _isApiCallInProgress = false);
    }
  }

  void _handleDragAutoScroll(Offset globalPosition) {
    final scrollController = _selectedTab == 0 ? _imageScrollController : _audioScrollController;
    if (!scrollController.hasClients) return;

    // Get the render box of the entire ContentArea widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    try {
      // Convert global position to local coordinates relative to this widget
      final Offset localPosition = renderBox.globalToLocal(globalPosition);
      final Size widgetSize = renderBox.size;
      
      // Get screen height for better trigger zone calculation
      final double screenHeight = MediaQuery.of(context).size.height;
      
      // More generous trigger zones
      const double topTriggerZone = 120.0; // Larger top trigger zone
      const double bottomTriggerZone = 100.0; // Bottom trigger zone
      const double maxVelocityDistance = 80.0; // Distance for max velocity
      
      // Calculate trigger boundaries relative to the widget
      // For top: allow scrolling up when dragging anywhere in upper portion (including tab bar area)
      final double topTrigger = topTriggerZone;
      final double bottomTrigger = widgetSize.height - bottomTriggerZone;
      
      // Calculate normalized distance into trigger zone (0.0 to 1.0)
      ScrollDirection newDirection = ScrollDirection.none;
      double velocityFactor = 0.0;

      // Check for upward scroll trigger (more generous - includes tab bar area)
      if (localPosition.dy < topTrigger) {
        // Near top - scroll up
        newDirection = ScrollDirection.up;
        final distanceIntoZone = topTrigger - localPosition.dy;
        velocityFactor = (distanceIntoZone / maxVelocityDistance).clamp(0.0, 1.0);
      }
      // Check for downward scroll trigger
      else if (localPosition.dy > bottomTrigger && localPosition.dy < widgetSize.height) {
        // Near bottom - scroll down (only when still within widget bounds)
        newDirection = ScrollDirection.down;
        final distanceIntoZone = localPosition.dy - bottomTrigger;
        velocityFactor = (distanceIntoZone / maxVelocityDistance).clamp(0.0, 1.0);
      }
      // Stop scrolling if drag moves completely outside reasonable bounds
      else if (localPosition.dy > widgetSize.height + 50 || 
               localPosition.dx < -50 || localPosition.dx > widgetSize.width + 50) {
        _stopAutoScroll();
        return;
      }

      // Calculate target velocity with exponential curve for smoother feel
      // Base speed: 200 px/s, Max speed: 800 px/s (slightly reduced for better control)
      const double baseSpeed = 200.0;
      const double maxSpeed = 800.0;
      final double targetVelocity = baseSpeed + (maxSpeed - baseSpeed) * (velocityFactor * velocityFactor);

      final double newTargetVelocity = newDirection == ScrollDirection.up ? -targetVelocity :
                                       newDirection == ScrollDirection.down ? targetVelocity : 0.0;

      // Only update if direction changed or stopped
      if (_currentScrollDirection != newDirection) {
        _targetScrollVelocity = newTargetVelocity;
        
        if (newDirection != ScrollDirection.none && _autoScrollTicker == null) {
          _startAutoScrollTicker(scrollController);
        } else if (newDirection == ScrollDirection.none) {
          _stopAutoScroll();
        }
        
        _currentScrollDirection = newDirection;
      } else if (newDirection != ScrollDirection.none) {
        // Update velocity smoothly if still in same direction
        _targetScrollVelocity = newTargetVelocity;
      }
    } catch (e) {
      // If coordinate conversion fails, stop auto-scroll
      _stopAutoScroll();
    }
  }

  void _startAutoScrollTicker(ScrollController scrollController) {
    _autoScrollTicker = createTicker((elapsed) {
      if (!scrollController.hasClients) {
        _stopAutoScroll();
        return;
      }

      final now = DateTime.now();
      final dt = _lastFrameTime != null
          ? now.difference(_lastFrameTime!).inMicroseconds / 1000000.0
          : 1.0 / 60.0;
      _lastFrameTime = now;

      // Clamp dt to reasonable bounds to prevent jumps
      final clampedDt = dt.clamp(1.0 / 120.0, 1.0 / 30.0);

      // More responsive velocity interpolation for stopping
      const double velocityLerpFactor = 12.0; // Higher for faster response to stops
      _scrollVelocity = _scrollVelocity + (_targetScrollVelocity - _scrollVelocity) * velocityLerpFactor * clampedDt;

      // Stop if target velocity is 0 and current velocity is very low
      if (_targetScrollVelocity == 0.0 && _scrollVelocity.abs() < 5.0) {
        _stopAutoScroll();
        return;
      }
      
      // Stop if velocity is negligible
      if (_scrollVelocity.abs() < 0.5) {
        _scrollVelocity = 0.0;
        _stopAutoScroll();
        return;
      }

      final currentScroll = scrollController.position.pixels;
      final maxScroll = scrollController.position.maxScrollExtent;
      final minScroll = scrollController.position.minScrollExtent;

      // Calculate new position with delta time
      final deltaScroll = _scrollVelocity * clampedDt;
      final newScroll = (currentScroll + deltaScroll).clamp(minScroll, maxScroll);

      // Check if we've hit a boundary and stop auto-scroll
      if ((newScroll <= minScroll && _scrollVelocity < 0) || 
          (newScroll >= maxScroll && _scrollVelocity > 0)) {
        _stopAutoScroll();
        return;
      }

      // Use jumpTo for instant, smooth updates
      scrollController.jumpTo(newScroll);
    });

    _autoScrollTicker!.start();
  }

  void _stopAutoScroll() {
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
    _scrollVelocity = 0.0;
    _targetScrollVelocity = 0.0;
    _currentScrollDirection = ScrollDirection.none;
    _lastFrameTime = null;
  }

  void _showItemDetail(int index) {
    final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
    if (index < 0 || index >= currentItems.length) return;
    final item = currentItems[index];

    if (item.type == ContentType.image) {
      _showImageModal(item);
    } else {
      _showAudioModal(item);
    }
  }

  void _showImageModal(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => ImageModalView(
        item: item,
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        onUpdate: widget.onItemsChanged,
      ),
    );
  }

  void _showAudioModal(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => AudioModalView(
        item: item,
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        onUpdate: widget.onItemsChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Calculate cross axis count based on zoom level
    // Base: 3 columns at 1.0 zoom
    // 0.5 zoom = 6 columns (smaller thumbnails, more per row)
    // 2.0 zoom = 2 columns (larger thumbnails, fewer per row)
    int baseCrossAxisCount = isMobile ? 2 : 3;
    int crossAxisCount = (baseCrossAxisCount / _zoomLevel).round().clamp(1, 8);

    // Get current tab items
    final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
    final isLoading = _selectedTab == 0 ? _imageIsLoading : _audioIsLoading;
    final isLoadingMore = _selectedTab == 0 ? _imageIsLoadingMore : _audioIsLoadingMore;
    final scrollController = _selectedTab == 0 ? _imageScrollController : _audioScrollController;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            // Custom Tab Bar at top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                border: Border(
                  bottom: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    label: 'Images',
                    icon: Icons.image,
                    count: _imageItems.length,
                    isSelected: _selectedTab == 0,
                    onPressed: () {
                      setState(() {
                        _selectedTab = 0;
                        _selectedIndices.clear();
                        _focusedIndex = null;
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  _buildTabButton(
                    label: 'Audio',
                    icon: Icons.audio_file,
                    count: _audioItems.length,
                    isSelected: _selectedTab == 1,
                    onPressed: () async {
                      setState(() {
                        _selectedTab = 1;
                        _selectedIndices.clear();
                        _focusedIndex = null;
                      });
                      // Load audios if not already loaded
                      if (_audioItems.isEmpty) {
                        await _loadAudiosContent();
                      }
                    },
                  ),
                  Spacer(),
                  // Reorder toggle button
                  if (currentItems.isNotEmpty)
                    Tooltip(
                      message: _isReorderMode ? 'Done reordering' : 'Start reordering',
                      child: IconButton(
                        onPressed: _toggleReorderMode,
                        icon: Icon(
                          _isReorderMode ? Icons.done : Icons.drag_handle,
                          color: _isReorderMode
                              ? FlutterFlowTheme.of(context).success
                              : FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                  // Delete All button
                  if (currentItems.isNotEmpty)
                    Tooltip(
                      message: 'Delete all ${_selectedTab == 0 ? 'images' : 'audios'} in chapter',
                      child: TextButton.icon(
                        onPressed: _deleteAllInChapter,
                        icon: Icon(Icons.delete_sweep, size: 18),
                        label: Text('Delete All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade300,
                        ),
                      ),
                    ),
                  if (isLoadingMore)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Reorder Mode Toolbar
            if (_isReorderMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: FlutterFlowTheme.of(context).warning,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      size: 16,
                      color: FlutterFlowTheme.of(context).warning,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isApiCallInProgress
                            ? 'Saving reorder...'
                            : 'Drag items to reorder. Changes save instantly.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          color: FlutterFlowTheme.of(context).warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (_isApiCallInProgress)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            
            // Selection Toolbar
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
            
            // Content Area
            Expanded(
              child: isLoading
                  ? _buildSkeletonLoader()
                  : currentItems.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          controller: scrollController,
                          shrinkWrap: false,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: currentItems.length,
                          itemBuilder: (context, index) => _buildGridItem(context, index),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required int count,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText,
              ),
              SizedBox(width: 8),
              Text(
                '$label ($count)',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      color: isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
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
    final currentItems = _selectedTab == 0 ? _imageItems : _audioItems;
    if (index < 0 || index >= currentItems.length) return SizedBox();
    
    final item = currentItems[index];
    final isSelected = _selectedIndices.contains(index);
    final isFocused = _focusedIndex == index;
    final isDragOver = _dragOverIndex == index;

    // Build the grid item widget
    Widget gridItemWidget = GestureDetector(
      onTap: () {
        if (_isReorderMode) return; // Don't allow selection in reorder mode
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
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isFocused
                ? FlutterFlowTheme.of(context).primary
                : isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.3),
            width: isFocused ? 2.5 : (isSelected ? 2.0 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12.0 : 8.0,
              offset: Offset(0, isSelected ? 4.0 : 2.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with overlay gradient
            Expanded(
              child: Stack(
                children: [
                  // Main content
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (item.type == ContentType.image && item.thumbnailUrl != null)
                            CachedNetworkImage(
                              imageUrl: item.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: FlutterFlowTheme.of(context).alternate,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                            )
                          else if (item.type == ContentType.audio)
                            Container(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.05),
                              child: _buildAudioWaveform(),
                            )
                          else
                            Center(
                              child: Icon(
                                item.type == ContentType.image
                                    ? Icons.image_outlined
                                    : Icons.audio_file_outlined,
                                size: 56.0,
                                color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Sequence badge overlay (top-left)
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '#${item.sequence}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Drag handle (only in reorder mode)
                  if (_isReorderMode)
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.4),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.drag_handle,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                  // Selection indicator (top-right) - when not in reorder mode
                  else if (isSelected)
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.4),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info section with bold typography
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(
                    item.name,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          letterSpacing: 0.2,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.0),
                  // Status and action button row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusBadge(
                          item.type == ContentType.image
                              ? item.ocrStatus
                              : item.transcriptionStatus,
                        ),
                      ),
                      // Process button
                      if (!_isReorderMode) ...[
                        SizedBox(width: 6.0),
                        InkWell(
                          onTap: () => _processItem(item),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              (item.type == ContentType.image 
                                ? (item.ocrStatus == 'completed' ? Icons.refresh : Icons.play_arrow)
                                : (item.transcriptionStatus == 'completed' ? Icons.refresh : Icons.play_arrow)),
                              size: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Delete button
                        SizedBox(width: 6.0),
                        InkWell(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
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
                                              'Delete ${item.name}?',
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
                              if (item.type == ContentType.image) {
                                await OCRWorkbenchAPIGroup.deleteImageCall.call(
                                  imageId: item.id,
                                  hTTPBearer: token,
                                );
                              } else {
                                await OCRWorkbenchAPIGroup.deleteAudioCall.call(
                                  audioId: item.id,
                                  hTTPBearer: token,
                                );
                              }
                              setState(() {
                                if (item.type == ContentType.image) {
                                  _imageItems.removeWhere((i) => i.id == item.id);
                                  _imageTotalItems--;
                                } else {
                                  _audioItems.removeWhere((i) => i.id == item.id);
                                  _audioTotalItems--;
                                }
                              });
                              widget.onItemsChanged();
                              if (mounted) {
                                ToastManager.showSuccess('${item.name} deleted');
                              }
                            } catch (e) {
                              if (mounted) {
                                ToastManager.showError('Error deleting item: $e');
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).error,
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: [
                              BoxShadow(
                                color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.3),
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.delete_rounded,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        ),
                      ],
                      if (item.type == ContentType.audio && item.durationSeconds != null) ...[
                        SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 10.0,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              SizedBox(width: 3.0),
                              Text(
                                '${item.durationSeconds! ~/ 60}:${(item.durationSeconds! % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with drag-drop if in reorder mode
    if (_isReorderMode) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;
      int baseCrossAxisCount = isMobile ? 2 : 3;
      int crossAxisCount = (baseCrossAxisCount / _zoomLevel).round().clamp(1, 8);
      
      // Calculate item size based on grid layout
      final padding = 16.0 * 2; // horizontal padding on both sides
      final spacing = 12.0 * (crossAxisCount - 1);
      final availableWidth = screenWidth - padding;
      final itemWidth = (availableWidth - spacing) / crossAxisCount;
      final itemHeight = itemWidth / 0.8; // childAspectRatio is 0.8
      
      return Draggable<int>(
        data: index,
        onDragStarted: () => _onItemDragStarted(index),
        onDragEnd: (_) => _onItemDragEnded(),
        onDragUpdate: (DragUpdateDetails details) {
          // Use global position for auto-scroll calculation
          _handleDragAutoScroll(details.globalPosition);
        },
        feedback: SizedBox(
          width: itemWidth,
          height: itemHeight,
          child: Material(
            child: Opacity(
              opacity: 0.7,
              child: Transform.scale(
                scale: 0.9,
                child: gridItemWidget,
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: gridItemWidget,
        ),
        child: DragTarget<int>(
          onMove: (DragTargetDetails<int> details) {
            _onItemDragOver(index);
          },
          onLeave: (_) {
            setState(() => _dragOverIndex = null);
          },
          onAcceptWithDetails: (DragTargetDetails<int> details) {
            final draggedIndex = details.data;
            if (draggedIndex != index) {
              _onItemDropped(draggedIndex, index);
            }
            _onItemDragEnded();
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: [
                gridItemWidget,
                // Drop indicator
                if (candidateData.isNotEmpty || isDragOver)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).success,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return gridItemWidget;
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
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case 'completed':
        icon = Icons.check_circle;
        color = Color(0xFF10B981);
        label = 'Done';
        break;
      case 'processing':
        icon = Icons.sync;
        color = Color(0xFFF59E0B);
        label = 'Processing';
        break;
      case 'failed':
        icon = Icons.error;
        color = Color(0xFFEF4444);
        label = 'Failed';
        break;
      case 'pending':
      default:
        icon = Icons.schedule;
        color = Color(0xFF6B7280);
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.0,
            color: color,
          ),
          SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
