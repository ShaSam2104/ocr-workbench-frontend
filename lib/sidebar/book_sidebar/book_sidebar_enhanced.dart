import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/schema/book.dart';
import '/backend/schema/chapter.dart';
import '/components/modals/new_chapter_dialog.dart';
import '/toasts/toast_manager.dart';

class BookSidebarEnhanced extends StatefulWidget {
  const BookSidebarEnhanced({
    super.key,
    required this.onBookSelected,
    required this.onChapterSelected,
    required this.onNewBook,
    required this.onNewChapter,
    required this.onSearch,
    this.selectedBookId,
  });

  final Function(int bookId) onBookSelected;
  final Function(int bookId, int chapterId) onChapterSelected;
  final VoidCallback onNewBook;
  final VoidCallback onNewChapter;
  final VoidCallback onSearch;
  final int? selectedBookId;

  @override
  State<BookSidebarEnhanced> createState() => BookSidebarEnhancedState();
}

class BookSidebarEnhancedState extends State<BookSidebarEnhanced> {
  late FocusNode _focusNode;
  late TextEditingController _searchController;
  int? _selectedBookId;
  int? _selectedChapterId;
  Map<int, bool> _expandedBooks = {};
  Map<int, List<ChapterData>> _chapterCache = {};
  late FocusManager _focusManager;
  int _focusedItemIndex = 0;
  List<NavigationItem> _navigationItems = [];
  List<NavigationItem> _filteredNavigationItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();
    _searchController.addListener(_filterBooks);
    _focusManager = FocusManager(
      onFocusChanged: (index) {
        setState(() => _focusedItemIndex = index);
      },
    );
    _loadBooks();
    // Request focus after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteBook(int bookId, String bookName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: FlutterFlowTheme.of(context).error,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Delete Book?',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Content
                Text(
                  'Are you sure you want to delete "$bookName"?',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: FlutterFlowTheme.of(context).error,
                        size: 16.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'This will permanently delete the book and all its chapters, images, and audios.',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).error,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                          foregroundColor: FlutterFlowTheme.of(context).primaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                              size: 16.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'Delete',
                              style: FlutterFlowTheme.of(context).labelMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
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
      final result = await OCRWorkbenchAPIGroup.deleteBookCall.call(
        bookId: bookId,
        hTTPBearer: token,
      );

      if (result.succeeded) {
        if (mounted) {
          ToastManager.showSuccess('Book "$bookName" deleted');

          if (_selectedBookId == bookId) {
            setState(() {
              _selectedBookId = null;
              _selectedChapterId = null;
            });
          }

          await _loadBooks();
        }
      } else {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showError('Error deleting book: $e');
      }
    }
  }

  Future<void> _deleteChapter(int chapterId, String chapterName, int bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: FlutterFlowTheme.of(context).error,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Delete Chapter?',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Content
              Text(
                'Are you sure you want to delete "$chapterName"?',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: FlutterFlowTheme.of(context).error,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'This will also delete all images and audios in this chapter.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          color: FlutterFlowTheme.of(context).error,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                        foregroundColor: FlutterFlowTheme.of(context).primaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                            size: 16.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Delete',
                            style: FlutterFlowTheme.of(context).labelMedium.override(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
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
      final result = await OCRWorkbenchAPIGroup.deleteChapterCall.call(
        chapterId: chapterId,
        bookId: bookId,
        hTTPBearer: token,
      );

      if (result.succeeded) {
        if (mounted) {
          ToastManager.showSuccess('Chapter "$chapterName" deleted');

          if (_selectedChapterId == chapterId) {
            setState(() {
              _selectedChapterId = null;
            });
          }

          _chapterCache.remove(bookId);
          if (_expandedBooks[bookId] == true) {
            _toggleBookExpansion(bookId, null);
            _toggleBookExpansion(bookId, null);
          }
          
          await _loadBooks();
        }
      } else {
        throw Exception('Failed to delete chapter');
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showError('Error deleting chapter: $e');
      }
    }
  }

  Future<void> _loadBooks() async {
    try {
      setState(() => _isLoading = true);
      
      final authToken = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.listBooksCall.call(
        page: 1,
        pageSize: 50,
        hTTPBearer: authToken,
      );
      
      if (result.succeeded) {
        final paginatedResponse = PaginatedBooksResponse.fromJson(
          result.jsonBody as Map<String, dynamic>,
        );
        _buildNavigationItems(paginatedResponse.items);
        setState(() => _isLoading = false);
      } else {
        print('Failed to load books: ${result.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading books: $e');
      setState(() => _isLoading = false);
    }
  }
  
  // Public method to refresh books list
  Future<void> refreshBooks() async {
    await _loadBooks();
  }

  void _buildNavigationItems(List<Book> books) {
    _navigationItems = [];
    for (var book in books) {
      _navigationItems.add(
        NavigationItem(
          id: book.id,
          name: book.name,
          chapterCount: book.chapterCount ?? 0,
          itemType: ItemType.book,
          isExpandable: true, // Always expandable to show "+ New Chapter" button
        ),
      );
    }
    _filteredNavigationItems = List.from(_navigationItems);
  }

  Future<void> _toggleBookExpansion(int bookId, List<dynamic>? bookData) async {
    final isExpanded = _expandedBooks[bookId] ?? false;

    if (!isExpanded && !_chapterCache.containsKey(bookId)) {
      // Load chapters
      try {
        final authToken = currentAuthenticationToken ?? '';
        final result = await OCRWorkbenchAPIGroup.listChaptersCall.call(
          bookId: bookId,
          page: 1,
          pageSize: 50,
          hTTPBearer: authToken,
        );

        if (result.succeeded) {
          final paginatedResponse = PaginatedChaptersResponse.fromJson(
            result.jsonBody as Map<String, dynamic>,
          );
          final chapterList = paginatedResponse.items
              .map((ch) => ChapterData(
                    id: ch.id,
                    name: ch.name,
                    bookId: bookId,
                  ))
              .toList();
          _chapterCache[bookId] = chapterList;
        }
      } catch (e) {
        print('Error loading chapters: $e');
      }
    }

    setState(() {
      _expandedBooks[bookId] = !isExpanded;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Check if modifier key is pressed (Cmd on Mac, Ctrl on Windows/Linux)
    final isModifierPressed = defaultTargetPlatform == TargetPlatform.macOS
        ? HardwareKeyboard.instance.isMetaPressed
        : HardwareKeyboard.instance.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _focusManager.focusNext(_getVisibleItemCount());
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _focusManager.focusPrevious();
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _handleExpandKey();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _handleCollapseKey();
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _handleSelectKey();
    } else if (event.logicalKey == LogicalKeyboardKey.keyK && isModifierPressed) {
      widget.onSearch();
    }
  }

  void _handleExpandKey() {
    final visibleItems = _getVisibleItems();
    if (_focusedItemIndex < visibleItems.length) {
      final item = visibleItems[_focusedItemIndex];
      if (item.itemType == ItemType.book) {
        final isExpanded = _expandedBooks[item.id] ?? false;
        if (!isExpanded) {
          _toggleBookExpansion(item.id, null);
        }
      }
    }
  }

  void _handleCollapseKey() {
    final visibleItems = _getVisibleItems();
    if (_focusedItemIndex < visibleItems.length) {
      final item = visibleItems[_focusedItemIndex];
      if (item.itemType == ItemType.book) {
        final isExpanded = _expandedBooks[item.id] ?? false;
        if (isExpanded) {
          setState(() => _expandedBooks[item.id] = false);
        }
      } else if (item.itemType == ItemType.chapter && item.bookId != null) {
        // Collapse parent book
        setState(() => _expandedBooks[item.bookId!] = false);
      }
    }
  }

  void _handleSelectKey() {
    final visibleItems = _getVisibleItems();
    if (_focusedItemIndex < visibleItems.length) {
      final item = visibleItems[_focusedItemIndex];
      if (item.itemType == ItemType.book) {
        widget.onBookSelected(item.id);
        setState(() {
          _selectedBookId = item.id;
          _selectedChapterId = null;
        });
      } else if (item.itemType == ItemType.chapter && item.bookId != null) {
        widget.onChapterSelected(item.bookId!, item.id);
        setState(() {
          _selectedBookId = item.bookId;
          _selectedChapterId = item.id;
        });
      } else if (item.itemType == ItemType.newChapterButton && item.bookId != null) {
        _showNewChapterDialog(item.bookId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    final sidebarWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.8
        : isTablet
            ? 300.0
            : 280.0;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: sidebarWidth,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          border: Border(
            right: BorderSide(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Books',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          fontSize: 20.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSearchHint(),
                      ),
                      const SizedBox(width: 8.0),
                      _buildNewBookButton(),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            // Books List
            Expanded(
              child: _isLoading
                  ? _buildSkeletonLoader()
                  : _buildBooksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16.0,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontSize: 13.0,
              ),
              decoration: InputDecoration(
                hintText: 'Search books...',
                hintStyle: FlutterFlowTheme.of(context).labelSmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 13.0,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            InkWell(
              onTap: () {
                _searchController.clear();
              },
              child: Icon(
                Icons.close,
                size: 16.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredNavigationItems = List.from(_navigationItems);
      });
    } else {
      setState(() {
        _filteredNavigationItems = _navigationItems
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Widget _buildNewBookButton() {
    return InkWell(
      onTap: widget.onNewBook,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Icon(
          Icons.add,
          size: 18.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
      itemBuilder: (_, __) => Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildBooksList() {
    final itemsToDisplay = _filteredNavigationItems.isEmpty && _searchController.text.isNotEmpty
        ? [] 
        : (_searchController.text.isEmpty ? _navigationItems : _filteredNavigationItems);
    
    if (itemsToDisplay.isEmpty && _navigationItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 48.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No books yet',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Create a new book to get started',
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
    }
    
    if (itemsToDisplay.isEmpty && _searchController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No books found',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _getVisibleItemCount(),
      itemBuilder: (context, index) {
        final visibleItems = _getVisibleItems();
        if (index >= visibleItems.length) return const SizedBox.shrink();

        final item = visibleItems[index];
        final isFocused = index == _focusedItemIndex;
        final isSelected = item.itemType == ItemType.book
            ? item.id == (widget.selectedBookId ?? _selectedBookId)
            : item.id == _selectedChapterId;

        if (item.itemType == ItemType.book) {
          return _buildBookItem(
            item: item,
            isFocused: isFocused,
            isSelected: isSelected,
          );
        } else if (item.itemType == ItemType.newChapterButton) {
          return _buildNewChapterButton(bookId: item.bookId!);
        } else {
          return _buildChapterItem(
            item: item,
            isFocused: isFocused,
            isSelected: isSelected,
          );
        }
      },
    );
  }

  int _getVisibleItemCount() {
    final itemsToUse = _searchController.text.isEmpty ? _navigationItems : _filteredNavigationItems;
    int count = itemsToUse.length;
    for (var book in itemsToUse) {
      if (_expandedBooks[book.id] == true) {
        final chapterCount = _chapterCache[book.id]?.length ?? 0;
        count += chapterCount + 1; // +1 for "New Chapter" button
      }
    }
    return count;
  }

  List<NavigationItem> _getVisibleItems() {
    final itemsToUse = _searchController.text.isEmpty ? _navigationItems : _filteredNavigationItems;
    final items = <NavigationItem>[];
    for (var book in itemsToUse) {
      items.add(book);
      if (_expandedBooks[book.id] == true) {
        final chapters = _chapterCache[book.id] ?? [];
        for (var chapter in chapters) {
          items.add(NavigationItem(
            id: chapter.id,
            name: chapter.name,
            itemType: ItemType.chapter,
            bookId: chapter.bookId,
          ));
        }
        // Add "New Chapter" button after chapters
        items.add(NavigationItem(
          id: -book.id, // Negative ID to identify as button
          name: '+ New Chapter',
          itemType: ItemType.newChapterButton,
          bookId: book.id,
        ));
      }
    }
    return items;
  }

  Widget _buildBookItem({
    required NavigationItem item,
    required bool isFocused,
    required bool isSelected,
  }) {
    final isExpanded = _expandedBooks[item.id] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
            : isFocused
                ? FlutterFlowTheme.of(context).primaryBackground
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: isSelected
            ? Border(
                left: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 3.0,
                ),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Expand/Collapse arrow - clickable
                  if (item.isExpandable)
                    InkWell(
                      onTap: () {
                        _toggleBookExpansion(item.id, null);
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 20.0,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 28.0),
                  // Book name - clickable to select
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        widget.onBookSelected(item.id);
                        setState(() {
                          _selectedBookId = item.id;
                          _selectedChapterId = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Text(
                        item.name,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.outfit(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              fontSize: 14.0,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (item.chapterCount != null && item.chapterCount! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '${item.chapterCount}',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  const SizedBox(width: 4.0),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18.0),
                    color: FlutterFlowTheme.of(context).error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => _deleteBook(item.id, item.name),
                    tooltip: 'Delete book',
                  ),
                ],
              ),
              // Removed image/audio count badges - not returned by backend
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterItem({
    required NavigationItem item,
    required bool isFocused,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.1)
            : isFocused
                ? FlutterFlowTheme.of(context).primaryBackground
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isFocused
              ? FlutterFlowTheme.of(context).secondary
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (item.bookId != null) {
            widget.onChapterSelected(item.bookId!, item.id);
            setState(() {
              _selectedBookId = item.bookId;
              _selectedChapterId = item.id;
            });
          }
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.description,
                      size: 16.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            fontSize: 13.0,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16.0),
                    color: FlutterFlowTheme.of(context).error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _deleteChapter(item.id, item.name, item.bookId!),
                    tooltip: 'Delete chapter',
                  ),
                ],
              ),
              // Removed image/audio count badges - not returned by backend
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewChapterButton({required int bookId}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 4.0, 8.0, 4.0),
      child: InkWell(
        onTap: () => _showNewChapterDialog(bookId),
        borderRadius: BorderRadius.circular(6.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 16.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 6.0),
              Text(
                'New Chapter',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewChapterDialog(int bookId) {
    showDialog(
      context: context,
      builder: (context) => NewChapterDialog(
        bookId: bookId,
        onSuccess: () {
          // Clear the cache for this book and reload its chapters
          setState(() {
            _chapterCache.remove(bookId);
          });
          // Reload chapters for this book
          _toggleBookExpansion(bookId, null);
        },
      ),
    );
  }
}

class NavigationItem {
  final int id;
  final String name;
  final ItemType itemType;
  final bool isExpandable;
  final int? bookId;
  final int? chapterCount;

  NavigationItem({
    required this.id,
    required this.name,
    required this.itemType,
    this.isExpandable = false,
    this.bookId,
    this.chapterCount,
  });
}

class ChapterData {
  final int id;
  final String name;
  final int bookId;

  ChapterData({
    required this.id,
    required this.name,
    required this.bookId,
  });
}

enum ItemType { book, chapter, newChapterButton }

class FocusManager {
  int _currentFocus = 0;
  final Function(int) onFocusChanged;

  FocusManager({required this.onFocusChanged});

  void focusNext(int itemCount) {
    if (itemCount > 0) {
      _currentFocus = (_currentFocus + 1) % itemCount;
      onFocusChanged(_currentFocus);
    }
  }

  void focusPrevious() {
    if (_currentFocus > 0) {
      _currentFocus--;
    } else {
      _currentFocus = 0;
    }
    onFocusChanged(_currentFocus);
  }

  void setFocus(int index) {
    _currentFocus = index;
    onFocusChanged(_currentFocus);
  }

  int get currentFocus => _currentFocus;
}
