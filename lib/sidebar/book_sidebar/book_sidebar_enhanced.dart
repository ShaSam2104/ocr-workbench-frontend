import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';

class BookSidebarEnhanced extends StatefulWidget {
  const BookSidebarEnhanced({
    super.key,
    required this.onBookSelected,
    required this.onChapterSelected,
    required this.onNewBook,
    required this.onNewChapter,
    required this.onSearch,
  });

  final Function(int bookId) onBookSelected;
  final Function(int bookId, int chapterId) onChapterSelected;
  final VoidCallback onNewBook;
  final VoidCallback onNewChapter;
  final VoidCallback onSearch;

  @override
  State<BookSidebarEnhanced> createState() => _BookSidebarEnhancedState();
}

class _BookSidebarEnhancedState extends State<BookSidebarEnhanced> {
  late FocusNode _focusNode;
  int? _selectedBookId;
  int? _selectedChapterId;
  Map<int, bool> _expandedBooks = {};
  Map<int, List<ChapterData>> _chapterCache = {};
  late FocusManager _focusManager;
  int _focusedItemIndex = 0;
  List<NavigationItem> _navigationItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusManager = FocusManager(
      onFocusChanged: (index) {
        setState(() => _focusedItemIndex = index);
      },
    );
    _loadBooks();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      setState(() => _isLoading = true);
      final result = await OCRWorkbenchAPIGroup.listBooksCall.call();
      
      if (result.succeeded) {
        final books = result.jsonBody as List?;
        if (books != null) {
          _buildNavigationItems(books);
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading books: $e');
      setState(() => _isLoading = false);
    }
  }

  void _buildNavigationItems(List<dynamic> books) {
    _navigationItems = [];
    for (var book in books) {
      final bookId = book['id'] as int;
      final bookName = book['name'] as String? ?? 'Untitled Book';
      final imageCount = book['image_count'] as int? ?? 0;
      final audioCount = book['audio_count'] as int? ?? 0;
      final chapterCount = book['chapter_count'] as int? ?? 0;

      _navigationItems.add(
        NavigationItem(
          id: bookId,
          name: bookName,
          imageCount: imageCount,
          audioCount: audioCount,
          chapterCount: chapterCount,
          itemType: ItemType.book,
          isExpandable: chapterCount > 0,
        ),
      );
    }
  }

  Future<void> _toggleBookExpansion(int bookId, List<dynamic>? bookData) async {
    final isExpanded = _expandedBooks[bookId] ?? false;

    if (!isExpanded && !_chapterCache.containsKey(bookId)) {
      // Load chapters
      try {
        final result = await OCRWorkbenchAPIGroup.listChaptersCall.call(
          bookId: bookId,
        );

        if (result.succeeded) {
          final chapters = result.jsonBody as List?;
          if (chapters != null) {
            final chapterList = chapters
                .map((ch) => ChapterData(
                      id: ch['id'] as int,
                      name: ch['name'] as String? ?? 'Untitled Chapter',
                      imageCount: ch['image_count'] as int? ?? 0,
                      audioCount: ch['audio_count'] as int? ?? 0,
                      bookId: bookId,
                    ))
                .toList();
            _chapterCache[bookId] = chapterList;
          }
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
    if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown)) {
      _focusManager.focusNext(_navigationItems.length);
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp)) {
      _focusManager.focusPrevious();
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowRight)) {
      _handleExpandKey();
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      _handleCollapseKey();
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
      _handleSelectKey();
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyN) &&
        HardwareKeyboard.instance.isControlPressed) {
      widget.onNewBook();
    } else if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyK) &&
        HardwareKeyboard.instance.isControlPressed) {
      widget.onSearch();
    }
  }

  void _handleExpandKey() {
    if (_focusedItemIndex < _navigationItems.length) {
      final item = _navigationItems[_focusedItemIndex];
      if (item.itemType == ItemType.book && item.isExpandable) {
        _toggleBookExpansion(item.id, null);
      }
    }
  }

  void _handleCollapseKey() {
    if (_focusedItemIndex < _navigationItems.length) {
      final item = _navigationItems[_focusedItemIndex];
      if (item.itemType == ItemType.book) {
        final isExpanded = _expandedBooks[item.id] ?? false;
        if (isExpanded) {
          setState(() => _expandedBooks[item.id] = false);
        }
      }
    }
  }

  void _handleSelectKey() {
    if (_focusedItemIndex < _navigationItems.length) {
      final item = _navigationItems[_focusedItemIndex];
      if (item.itemType == ItemType.book) {
        widget.onBookSelected(item.id);
        setState(() => _selectedBookId = item.id);
      } else if (item.itemType == ItemType.chapter && item.bookId != null) {
        widget.onChapterSelected(item.bookId!, item.id);
        setState(() {
          _selectedBookId = item.bookId;
          _selectedChapterId = item.id;
        });
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
                  : SingleChildScrollView(
                      child: _buildBooksList(),
                    ),
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
          const SizedBox(width: 6.0),
          Text(
            'Ctrl+K',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                ),
          ),
        ],
      ),
    );
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
    if (_navigationItems.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _getVisibleItemCount(),
      itemBuilder: (context, index) {
        final visibleItems = _getVisibleItems();
        if (index >= visibleItems.length) return const SizedBox.shrink();

        final item = visibleItems[index];
        final isFocused = index == _focusedItemIndex;
        final isSelected = item.itemType == ItemType.book
            ? item.id == _selectedBookId
            : item.id == _selectedChapterId;

        if (item.itemType == ItemType.book) {
          return _buildBookItem(
            item: item,
            isFocused: isFocused,
            isSelected: isSelected,
          );
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
    int count = _navigationItems.length;
    for (var book in _navigationItems) {
      if (_expandedBooks[book.id] == true) {
        count += _chapterCache[book.id]?.length ?? 0;
      }
    }
    return count;
  }

  List<NavigationItem> _getVisibleItems() {
    final items = <NavigationItem>[];
    for (var book in _navigationItems) {
      items.add(book);
      if (_expandedBooks[book.id] == true) {
        final chapters = _chapterCache[book.id] ?? [];
        for (var chapter in chapters) {
          items.add(NavigationItem(
            id: chapter.id,
            name: chapter.name,
            imageCount: chapter.imageCount,
            audioCount: chapter.audioCount,
            itemType: ItemType.chapter,
            bookId: chapter.bookId,
          ));
        }
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
            ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
            : isFocused
                ? FlutterFlowTheme.of(context).primaryBackground
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isFocused
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (item.isExpandable) {
            _toggleBookExpansion(item.id, null);
          } else {
            widget.onBookSelected(item.id);
            setState(() => _selectedBookId = item.id);
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
                  if (item.isExpandable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 20.0,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    )
                  else
                    const SizedBox(
                      width: 28.0,
                    ),
                  Expanded(
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
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  const SizedBox(width: 28.0),
                  Expanded(
                    child: Wrap(
                      spacing: 12.0,
                      children: [
                        _buildCountBadge(
                          icon: Icons.image,
                          count: item.imageCount,
                          label: 'images',
                        ),
                        _buildCountBadge(
                          icon: Icons.volume_up,
                          count: item.audioCount,
                          label: 'audios',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                ],
              ),
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Wrap(
                  spacing: 12.0,
                  children: [
                    _buildCountBadge(
                      icon: Icons.image,
                      count: item.imageCount,
                      label: 'images',
                      small: true,
                    ),
                    _buildCountBadge(
                      icon: Icons.volume_up,
                      count: item.audioCount,
                      label: 'audios',
                      small: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge({
    required IconData icon,
    required int count,
    required String label,
    bool small = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: small ? 12.0 : 14.0,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
        const SizedBox(width: 4.0),
        Text(
          '$count',
          style: FlutterFlowTheme.of(context).labelSmall.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: small ? 10.0 : 11.0,
              ),
        ),
      ],
    );
  }
}

class NavigationItem {
  final int id;
  final String name;
  final int imageCount;
  final int audioCount;
  final ItemType itemType;
  final bool isExpandable;
  final int? bookId;
  final int? chapterCount;

  NavigationItem({
    required this.id,
    required this.name,
    required this.imageCount,
    required this.audioCount,
    required this.itemType,
    this.isExpandable = false,
    this.bookId,
    this.chapterCount,
  });
}

class ChapterData {
  final int id;
  final String name;
  final int imageCount;
  final int audioCount;
  final int bookId;

  ChapterData({
    required this.id,
    required this.name,
    required this.imageCount,
    required this.audioCount,
    required this.bookId,
  });
}

enum ItemType { book, chapter }

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
