import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/widgets/image_modal_view.dart';
import '/widgets/audio_modal_view.dart';
import '/models/content_item.dart';

class SearchResult {
  final int id;
  final String type; // 'image' or 'audio'
  final String name;
  final String? thumbnailUrl;
  final String? previewText;
  final String? status; // 'completed', 'processing', 'pending', 'failed'
  final dynamic imageData; // Raw image object from API
  final dynamic audioData; // Raw audio object from API

  SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.thumbnailUrl,
    this.previewText,
    this.status,
    this.imageData,
    this.audioData,
  });
}

class SearchModalEnhanced extends StatefulWidget {
  const SearchModalEnhanced({
    super.key,
    this.currentChapterId,
    this.currentBookId,
    required this.onResultSelected,
    this.onClose,
  });

  final int? currentChapterId;
  final int? currentBookId;
  final Function(SearchResult result) onResultSelected;
  final VoidCallback? onClose;

  @override
  State<SearchModalEnhanced> createState() => _SearchModalEnhancedState();
}

class _SearchModalEnhancedState extends State<SearchModalEnhanced> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late FocusNode _resultsFocusNode;

  // Filters
  String _contentType = 'both'; // 'images', 'audios', 'both'
  String _scope = 'global'; // 'chapter', 'book', 'global'

  // Results
  List<SearchResult> _results = [];
  int _selectedResultIndex = -1;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _resultsFocusNode = FocusNode();

    // Focus on search input by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _resultsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 576;
    final isTablet = MediaQuery.of(context).size.width >= 576 &&
        MediaQuery.of(context).size.width < 992;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<Intent>(onInvoke: (intent) {
            widget.onClose?.call();
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          focusNode: _resultsFocusNode,
          onKeyEvent: (node, event) => _handleKeyEvent(event),
          child: GestureDetector(
            onTap: () {
              widget.onClose?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent taps from closing the dialog
                child: Container(
                  width: isMobile ? double.infinity : (isTablet ? 580 : 640),
                  height: MediaQuery.of(context).size.height * 0.7,
                  margin: EdgeInsets.all(isMobile ? 16 : 40),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.alternate.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Minimal Header with close button
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
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
                              'Search',
                              style: theme.titleMedium.override(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  widget.onClose?.call();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.primaryBackground.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search Input - Clean and minimal
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Focus(
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent && 
                                      event.logicalKey == LogicalKeyboardKey.escape) {
                                    widget.onClose?.call();
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                  hintText: 'Search OCR text, transcripts...',
                                  hintStyle: theme.bodyMedium.copyWith(
                                    color: theme.secondaryText,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: theme.secondaryText,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            _searchController.clear();
                                            setState(() {});
                                            _performSearch();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: theme.secondaryText,
                                          ),
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: theme.alternate),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: theme.alternate),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: theme.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: theme.primaryBackground,
                                ),
                                style: theme.bodyMedium.override(fontSize: 14),
                                onChanged: (_) {
                                  setState(() {});
                                  _performSearch();
                                },
                              ),
                            ),
                            ),
                          ],
                        ),
                      ),
                      // Filters - Clean chip-based design
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Content type filter
                            Text(
                              'Content Type',
                              style: theme.labelMedium.override(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 0,
                                children: [
                                  _buildFilterChip('images', 'Images',
                                      Icons.image_outlined, theme),
                                  _buildFilterChip('audios', 'Audios',
                                      Icons.audiotrack_outlined, theme),
                                  _buildFilterChip(
                                      'both', 'Both', Icons.select_all, theme),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Search scope
                            Text(
                              'Search Scope',
                              style: theme.labelMedium.override(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 0,
                                children: [
                                  if (widget.currentChapterId != null)
                                    _buildScopeChip(
                                        'chapter', 'Current Chapter', theme),
                                  if (widget.currentBookId != null)
                                    _buildScopeChip(
                                        'book', 'Current Book', theme),
                                  _buildScopeChip('global', 'Global', theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Results
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: theme.primary,
                                ),
                              )
                            : _errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: theme.error,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _errorMessage ?? 'Unknown error',
                                          style: theme.bodyMedium.copyWith(
                                            color: theme.error,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _performSearch,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : _results.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No results found',
                                          style: theme.bodyMedium.copyWith(
                                            color: theme.secondaryText,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        itemCount: _results.length,
                                        separatorBuilder: (_, __) =>
                                            Divider(color: theme.alternate),
                                        itemBuilder: (context, index) {
                                          final result = _results[index];
                                          final isSelected =
                                              _selectedResultIndex == index;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 8,
                                            ),
                                            child: InkWell(
                                              onTap: () => _openResultModal(result),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 12,
                                                ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? theme.primary
                                                        .withValues(alpha: 0.1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Thumbnail
                                                  if (result.thumbnailUrl !=
                                                      null)
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: theme.alternate,
                                                      ),
                                                      child: Image.network(
                                                        result.thumbnailUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Center(
                                                            child: Icon(
                                                              result.type ==
                                                                      'image'
                                                                  ? Icons.image
                                                                  : Icons
                                                                      .audio_file,
                                                              color: theme
                                                                  .secondaryText,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: theme.alternate,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          result.type == 'image'
                                                              ? Icons.image
                                                              : Icons
                                                                  .audio_file,
                                                          color: theme
                                                              .secondaryText,
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(width: 12),
                                                  // Content
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Title with type badge
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                result.name,
                                                                style: theme
                                                                    .bodyMedium
                                                                    .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: result
                                                                            .type ==
                                                                        'image'
                                                                    ? Colors
                                                                        .blue
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2)
                                                                    : Colors
                                                                        .orange
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Text(
                                                                result.type
                                                                    .toUpperCase(),
                                                                style: theme
                                                                    .bodySmall
                                                                    .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: result
                                                                              .type ==
                                                                          'image'
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .orange,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        // Preview text
                                                        if (result
                                                                .previewText !=
                                                            null)
                                                          Text(
                                                            result.previewText!,
                                                            style: theme
                                                                .bodySmall
                                                                .copyWith(
                                                              color: theme
                                                                  .secondaryText,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        const SizedBox(
                                                            height: 4),
                                                        // Status badge
                                                        if (result.status !=
                                                            null)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: _getStatusColor(
                                                                      result
                                                                          .status!)
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              result.status!
                                                                  .toUpperCase(),
                                                              style: theme
                                                                  .bodySmall
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: _getStatusColor(
                                                                    result
                                                                        .status!),
                                                              ),
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
                                        },
                                      ),
                      ),
                      // Footer with hint
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: theme.alternate,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Click to open  Esc to close',
                          style: theme.bodySmall.copyWith(
                            color: theme.secondaryText,
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
      ),
    );
  }

  Widget _buildFilterChip(
      String value, String label, IconData icon, FlutterFlowTheme theme) {
    final isActive = _contentType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _contentType = value;
          _performSearch();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : theme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? theme.primary : theme.alternate,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : theme.secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.labelMedium.override(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : theme.secondaryText,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScopeChip(String value, String label, FlutterFlowTheme theme) {
    final isActive = _scope == value;
    return InkWell(
      onTap: () {
        setState(() {
          _scope = value;
          _performSearch();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : theme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? theme.primary : theme.alternate,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.labelMedium.override(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : theme.secondaryText,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _results = [];
        _selectedResultIndex = -1;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulated API calls - replace with actual calls
      final results = await _searchWithFilters();

      setState(() {
        _results = results;
        _selectedResultIndex = -1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<List<SearchResult>> _searchWithFilters() async {
    return await _searchByText();
  }

  Future<List<SearchResult>> _searchByText() async {
    final List<SearchResult> results = [];
    final String query = _searchController.text;
    final String token = currentAuthenticationToken ?? '';

    try {
      // Search images by text if content type includes images
      if (_contentType == 'images' || _contentType == 'both') {
        final imageResponse =
            await OCRWorkbenchAPIGroup.searchImagesByTextCall.call(
          textQuery: query,
          hTTPBearer: token,
        );

        if (imageResponse.succeeded) {
          final List<dynamic> imageResults =
              imageResponse.jsonBody is List ? imageResponse.jsonBody : [];

          for (final item in imageResults) {
            if (item is Map<String, dynamic>) {
              final imageData = item['image'] as Map<String, dynamic>?;
              final excerpt = item['excerpt'] as String?;
              final imageUrl = item['image_url'] as String?;

              if (imageData != null) {
                final status = imageData['ocr_status'] as String? ?? 'pending';

                results.add(
                  SearchResult(
                    id: imageData['id'] as int? ?? 0,
                    type: 'image',
                    name: imageData['filename'] as String? ?? 'Unknown Image',
                    thumbnailUrl: imageUrl,
                    previewText: excerpt,
                    status: status,
                    imageData: imageData,
                  ),
                );
              }
            }
          }
        }
      }

      // Search audios by text if content type includes audios
      if (_contentType == 'audios' || _contentType == 'both') {
        final audioResponse =
            await OCRWorkbenchAPIGroup.searchAudiosByTextCall.call(
          textQuery: query,
          hTTPBearer: token,
        );

        if (audioResponse.succeeded) {
          final List<dynamic> audioResults =
              audioResponse.jsonBody is List ? audioResponse.jsonBody : [];

          for (final item in audioResults) {
            if (item is Map<String, dynamic>) {
              final audioData = item['audio'] as Map<String, dynamic>?;
              final excerpt = item['excerpt'] as String?;
              final audioUrl = item['audio_url'] as String?;

              if (audioData != null) {
                final status =
                    audioData['transcription_status'] as String? ?? 'pending';

                results.add(
                  SearchResult(
                    id: audioData['id'] as int? ?? 0,
                    type: 'audio',
                    name: audioData['filename'] as String? ?? 'Unknown Audio',
                    thumbnailUrl: audioUrl, // Store audio URL for later use
                    previewText: excerpt,
                    status: status,
                    audioData: audioData,
                  ),
                );
              }
            }
          }
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Escape to close
      if (key == LogicalKeyboardKey.escape) {
        widget.onClose?.call();
        return KeyEventResult.handled;
      }

      // Arrow down to navigate results
      if (key == LogicalKeyboardKey.arrowDown) {
        if (_selectedResultIndex < _results.length - 1) {
          setState(() {
            _selectedResultIndex++;
          });
        }
        return KeyEventResult.handled;
      }

      // Arrow up to navigate results
      if (key == LogicalKeyboardKey.arrowUp) {
        if (_selectedResultIndex > 0) {
          setState(() {
            _selectedResultIndex--;
          });
        }
        return KeyEventResult.handled;
      }

      // Enter to open selected result
      if (key == LogicalKeyboardKey.enter && _selectedResultIndex >= 0) {
        _openResult(_results[_selectedResultIndex]);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  Future<void> _openResultModal(SearchResult result) async {
    try {
      final token = currentAuthenticationToken ?? '';
      
      if (result.type == 'image') {
        // Fetch full image data
        final imageTextResponse = 
            await OCRWorkbenchAPIGroup.getImageTextCall.call(
          imageId: result.id,
          hTTPBearer: token,
        );
        
        if (!mounted) return;
        
        if (imageTextResponse.succeeded) {
          final textData = imageTextResponse.jsonBody as Map<String, dynamic>?;
          
          // Prefer edited text if available, otherwise use raw text
          final ocrText = (textData?['edited_text_with_formatting'] as String?) ??
              (textData?['raw_text_with_formatting'] as String?);
          final imageUrl = textData?['image_url'] as String?;
          
          // Create ContentItem from search result and fetched data
          final contentItem = ContentItem(
            id: result.id,
            name: result.name,
            sequence: 0, // Will be updated from context
            type: ContentType.image,
            url: imageUrl, // Use the image URL from API
            thumbnailUrl: imageUrl, // Use the same URL for thumbnail
            ocrStatus: result.status,
            ocrText: ocrText,
            rawOcrText: textData?['plain_text'] as String?,
          );
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => ImageModalView(
                item: contentItem,
                bookId: widget.currentBookId ?? 0,
                chapterId: widget.currentChapterId ?? 0,
                onUpdate: () {
                  // Handle update
                },
              ),
            );
          }
        }
      } else if (result.type == 'audio') {
        // Fetch full audio data
        final audioTranscriptResponse =
            await OCRWorkbenchAPIGroup.getAudioTranscriptCall.call(
          audioId: result.id,
          hTTPBearer: token,
        );
        
        if (!mounted) return;
        
        if (audioTranscriptResponse.succeeded) {
          final transcriptData = audioTranscriptResponse.jsonBody as Map<String, dynamic>?;
          
          // Prefer edited text if available, otherwise use raw text
          final transcript = (transcriptData?['edited_text_with_formatting'] as String?) ??
              (transcriptData?['raw_text_with_formatting'] as String?);
          final audioUrl = transcriptData?['audio_url'] as String?;
          
          // Create ContentItem from search result and fetched data
          final contentItem = ContentItem(
            id: result.id,
            name: result.name,
            sequence: 0, // Will be updated from context
            type: ContentType.audio,
            url: audioUrl, // Use the audio URL from API
            thumbnailUrl: result.thumbnailUrl,
            transcriptionStatus: result.status,
            transcript: transcript,
            rawTranscript: transcriptData?['plain_text'] as String?,
          );
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AudioModalView(
                item: contentItem,
                bookId: widget.currentBookId ?? 0,
                chapterId: widget.currentChapterId ?? 0,
                onUpdate: () {
                  // Handle update
                },
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error opening result modal: $e');
    }
  }

  void _openResult(SearchResult result) {
    widget.onResultSelected(result);
    widget.onClose?.call();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
