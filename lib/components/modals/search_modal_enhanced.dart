import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SearchResult {
  final int id;
  final String type; // 'image' or 'audio'
  final String name;
  final String? thumbnailUrl;
  final String? previewText;
  final String? status; // 'completed', 'processing', 'pending', 'failed'

  SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.thumbnailUrl,
    this.previewText,
    this.status,
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

  // Search mode: 'number' or 'text'
  String _searchMode = 'text';

  // Filters
  String _contentType = 'both'; // 'images', 'audios', 'both'
  String _status =
      'all'; // 'all', 'completed', 'processing', 'pending', 'failed'
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
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.alternate,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
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
                              style: theme.headlineMedium.override(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                widget.onClose?.call();
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: theme.secondaryText,
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
                            const SizedBox(width: 12),
                            // Filter toggle button
                            Tooltip(
                              message: 'Toggle search mode',
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _searchMode = _searchMode == 'number'
                                        ? 'text'
                                        : 'number';
                                    _searchController.clear();
                                    _results.clear();
                                    _selectedResultIndex = -1;
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.primaryBackground,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: theme.alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _searchMode == 'number'
                                        ? Icons.tag
                                        : Icons.text_fields,
                                    size: 20,
                                    color: theme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filters - Clean chip-based design
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Content type filter
                            Text(
                              'Content Type',
                              style: theme.labelMedium.override(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFilterChip('images', 'Images',
                                    Icons.image_outlined, theme),
                                _buildFilterChip('audios', 'Audios',
                                    Icons.audiotrack_outlined, theme),
                                _buildFilterChip(
                                    'both', 'Both', Icons.select_all, theme),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Status filter
                            Text(
                              'Status',
                              style: theme.labelMedium.override(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: theme.alternate,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _status,
                                underline: const SizedBox.shrink(),
                                isExpanded: true,
                                style: theme.bodyMedium.override(fontSize: 13),
                                icon: Icon(Icons.keyboard_arrow_down,
                                    size: 20, color: theme.secondaryText),
                                onChanged: (value) {
                                  setState(() {
                                    _status = value ?? 'all';
                                    _performSearch();
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text('All Status'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'completed',
                                    child: Text('Completed'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'processing',
                                    child: Text('Processing'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pending',
                                    child: Text('Pending'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'failed',
                                    child: Text('Failed'),
                                  ),
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
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
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

                                          return InkWell(
                                            onTap: () => _selectResult(index),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
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
                          _selectedResultIndex >= 0
                              ? '↓ to navigate  Enter to open  Esc to close'
                              : '↓ to select results  Esc to close',
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
    // This is a placeholder - implement actual API calls based on search mode and filters
    // For now, return empty results to demonstrate structure
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation:
    // if (_searchMode == 'number') {
    //   return await _searchByNumber();
    // } else {
    //   return await _searchByText();
    // }

    return [];
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

  void _selectResult(int index) {
    setState(() {
      _selectedResultIndex = index;
    });
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
