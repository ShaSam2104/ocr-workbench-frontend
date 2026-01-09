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
  });

  final int? currentChapterId;
  final int? currentBookId;
  final Function(SearchResult result) onResultSelected;

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
  String _status = 'all'; // 'all', 'completed', 'processing', 'pending', 'failed'
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
    final isTablet =
        MediaQuery.of(context).size.width >= 576 && MediaQuery.of(context).size.width < 992;

    return RawKeyboardListener(
      focusNode: _resultsFocusNode,
      onKey: _handleKeyEvent,
      child: Dialog(
        insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Container(
          width: isMobile ? double.infinity : (isTablet ? 600 : 800),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
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
                      'Search',
                      style: theme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search Input & Mode Selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search mode selector
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: _searchMode == 'number'
                                  ? 'Enter sequence: 1, 3, 5-7, 10'
                                  : 'Search OCR text, transcripts...',
                              hintStyle: theme.bodyMedium.copyWith(
                                color: theme.secondaryText,
                              ),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _performSearch();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.alternate),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.alternate),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {});
                              _performSearch();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mode toggle
                        Tooltip(
                          message: 'Toggle search mode',
                          child: IconButton(
                            icon: Icon(
                              _searchMode == 'number' ? Icons.tag : Icons.text_fields,
                              color: theme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchMode = _searchMode == 'number' ? 'text' : 'number';
                                _searchController.clear();
                                _results.clear();
                                _selectedResultIndex = -1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content type filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Type',
                          style: theme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterButton('images', 'Images', theme),
                              const SizedBox(width: 8),
                              _buildFilterButton('audios', 'Audios', theme),
                              const SizedBox(width: 8),
                              _buildFilterButton('both', 'Both', theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: theme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value ?? 'all';
                              _performSearch();
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Status', style: theme.bodyMedium),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed', style: theme.bodyMedium),
                            ),
                            DropdownMenuItem(
                              value: 'processing',
                              child: Text('Processing', style: theme.bodyMedium),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending', style: theme.bodyMedium),
                            ),
                            DropdownMenuItem(
                              value: 'failed',
                              child: Text('Failed', style: theme.bodyMedium),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search scope
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Scope',
                          style: theme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (widget.currentChapterId != null)
                                _buildScopeButton('chapter', 'Current Chapter', theme),
                              if (widget.currentChapterId != null) const SizedBox(width: 8),
                              if (widget.currentBookId != null)
                                _buildScopeButton('book', 'Current Book', theme),
                              if (widget.currentBookId != null) const SizedBox(width: 8),
                              _buildScopeButton('global', 'Global', theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _results.length,
                                separatorBuilder: (_, __) =>
                                    Divider(color: theme.alternate),
                                itemBuilder: (context, index) {
                                  final result = _results[index];
                                  final isSelected = _selectedResultIndex == index;

                                  return InkWell(
                                    onTap: () => _selectResult(index),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.primary.withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Thumbnail
                                          if (result.thumbnailUrl != null)
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: theme.alternate,
                                              ),
                                              child: Image.network(
                                                result.thumbnailUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Center(
                                                    child: Icon(
                                                      result.type == 'image'
                                                          ? Icons.image
                                                          : Icons.audio_file,
                                                      color: theme.secondaryText,
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
                                                    BorderRadius.circular(8),
                                                color: theme.alternate,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  result.type == 'image'
                                                      ? Icons.image
                                                      : Icons.audio_file,
                                                  color: theme.secondaryText,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title with type badge
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        result.name,
                                                        style: theme.bodyMedium.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: result.type ==
                                                                'image'
                                                            ? Colors.blue
                                                                .withValues(
                                                                    alpha: 0.2)
                                                            : Colors.orange
                                                                .withValues(
                                                                    alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                      ),
                                                      child: Text(
                                                        result.type
                                                            .toUpperCase(),
                                                        style: theme.bodySmall.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: result.type ==
                                                                  'image'
                                                              ? Colors.blue
                                                              : Colors.orange,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                // Preview text
                                                if (result.previewText != null)
                                                  Text(
                                                    result.previewText!,
                                                    style: theme.bodySmall.copyWith(
                                                      color: theme.secondaryText,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                const SizedBox(height: 4),
                                                // Status badge
                                                if (result.status != null)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getStatusColor(
                                                              result.status!)
                                                              .withValues(
                                                                  alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      result.status!
                                                          .toUpperCase(),
                                                      style: theme.bodySmall.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _getStatusColor(
                                                            result.status!),
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
    );
  }

  Widget _buildFilterButton(String value, String label, FlutterFlowTheme theme) {
    final isActive = _contentType == value;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {
        setState(() {
          _contentType = value;
          _performSearch();
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: theme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isActive ? theme.primary : theme.alternate,
        width: isActive ? 2 : 1,
      ),
      labelStyle: theme.bodySmall.copyWith(
        color: isActive ? theme.primary : theme.secondaryText,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildScopeButton(String value, String label, FlutterFlowTheme theme) {
    final isActive = _scope == value;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {
        setState(() {
          _scope = value;
          _performSearch();
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: theme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isActive ? theme.primary : theme.alternate,
        width: isActive ? 2 : 1,
      ),
      labelStyle: theme.bodySmall.copyWith(
        color: isActive ? theme.primary : theme.secondaryText,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Escape to close
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }

      // Arrow down to navigate results
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_selectedResultIndex < _results.length - 1) {
          setState(() {
            _selectedResultIndex++;
          });
        }
      }

      // Arrow up to navigate results
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_selectedResultIndex > 0) {
          setState(() {
            _selectedResultIndex--;
          });
        }
      }

      // Enter to open selected result
      if (event.logicalKey == LogicalKeyboardKey.enter &&
          _selectedResultIndex >= 0) {
        _openResult(_results[_selectedResultIndex]);
      }
    }
  }

  void _selectResult(int index) {
    setState(() {
      _selectedResultIndex = index;
    });
  }

  void _openResult(SearchResult result) {
    widget.onResultSelected(result);
    Navigator.pop(context);
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
