import '/components/modals/keyboard_shortcuts_modal.dart';
import '/components/modals/image_detail_modal.dart';
import '/components/modals/audio_detail_modal.dart';
import '/components/modals/confirm_dialog.dart';
import '/components/modals/search_modal_enhanced.dart';
import '/components/modals/new_book_dialog.dart';
import '/components/utils/global_keyboard_shortcuts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/sidebar/book_sidebar/book_sidebar_enhanced.dart';
import '/pages/book_page/book_page_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/book.dart';
import '/backend/schema/chapter.dart';
import '/auth/custom_auth/auth_util.dart';
import '/toasts/toast_manager.dart';
import '/components/modals/export_modal.dart' show ChapterItem, ExportModal;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<BookSidebarEnhancedState> _sidebarKey = GlobalKey();
  int? _selectedBookId;
  int? _selectedChapterId;

  String get _modifierKey => defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Ctrl';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage: Building with showSearchModal=${_model.showSearchModal}');
    
    return GlobalKeyboardShortcuts(
      onCtrlK: () {
        print('🔍 HomePage: onCtrlK callback triggered!');
        print('🔍 Before: showSearchModal=${_model.showSearchModal}');
        _model.showSearchModal = true;
        print('🔍 After: showSearchModal=${_model.showSearchModal}');
        safeSetState(() {});
        print('🔍 safeSetState called');
      },
      onCtrlF: () {
        print('🔍 HomePage: onCtrlF callback triggered!');
        print('🔍 Before: showSearchModal=${_model.showSearchModal}');
        _model.showSearchModal = true;
        print('🔍 After: showSearchModal=${_model.showSearchModal}');
        safeSetState(() {});
        print('🔍 safeSetState called');
      },
      onToggleTheme: () {
        print('🎨 HomePage: onToggleTheme callback triggered!');
        final currentBrightness = Theme.of(context).brightness;
        print('🎨 Current brightness: $currentBrightness');
        final newMode = currentBrightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
        print('🎨 Setting new mode: $newMode');
        setDarkModeSetting(context, newMode);
        print('🎨 Theme change completed');
      },
      onShowHelp: () {
        print('❓ HomePage: onShowHelp callback triggered!');
        showDialog(
          context: context,
          builder: (context) => const KeyboardShortcutsModal(),
        );
        print('❓ Dialog shown');
      },
      child: GestureDetector(
        onTap: () {
          // Only unfocus if there's an active text field
          final currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
          if (currentFocus != null && currentFocus.hasFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Sidebar
                    BookSidebarEnhanced(
                      key: _sidebarKey,
                      selectedBookId: _selectedBookId,
                      selectedChapterId: _selectedChapterId,
                      onBookSelected: (bookId) {
                        setState(() {
                          _selectedBookId = bookId;
                          _selectedChapterId = null; // Clear chapter selection when switching books
                        });
                      },
                      onChapterSelected: (bookId, chapterId) {
                        print('Chapter selected: $chapterId in book: $bookId');
                        setState(() {
                          _selectedBookId = bookId;
                          _selectedChapterId = chapterId;
                        });
                      },
                      onNewBook: () {
                        showDialog(
                          context: context,
                          builder: (context) => NewBookDialog(
                            onCreated: (bookId, name) async {
                              print('Book created successfully: $name (ID: $bookId)');
                              // Refresh sidebar to show the new book
                              await _sidebarKey.currentState?.refreshBooks();
                            },
                          ),
                        );
                      },
                      onNewChapter: () {
                        print('New chapter clicked');
                        // TODO: Open new chapter dialog
                      },
                      onSearch: () {
                        _model.showSearchModal = true;
                        safeSetState(() {});
                      },
                      onExport: () {
                        if (_selectedBookId != null) {
                          _model.showExportModal = true;
                          safeSetState(() {});
                        }
                      },
                      onShare: () {
                        if (_selectedChapterId != null) {
                          print('Share tapped for chapter: $_selectedChapterId');
                          // TODO: Implement share functionality
                        }
                      },
                      onShowHelp: () {
                        showDialog(
                          context: context,
                          builder: (context) => const KeyboardShortcutsModal(),
                        );
                      },
                    ),
                    // Main Content Area
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Main Content - Show book page if selected, otherwise empty state
                          Expanded(
                            child: _selectedBookId != null
                                ? BookPageWidget(
                                    bookId: _selectedBookId!,
                                    selectedChapterId: _selectedChapterId,
                                    onChapterCreated: () {
                                      _sidebarKey.currentState?.refreshBooks();
                                    },
                                  )
                                : Container(
                                    width: double.infinity,
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Book icon
                                          Container(
                                            width: 80.0,
                                            height: 80.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context)
                                                  .accent1
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: Icon(
                                              Icons.auto_stories_outlined,
                                              size: 40.0,
                                              color: FlutterFlowTheme.of(context)
                                                  .primary
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          SizedBox(height: 24.0),
                                          // Title
                                          Text(
                                            'Your workspace is empty',
                                            style: FlutterFlowTheme.of(context)
                                                .headlineMedium
                                                .override(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.5,
                                                ),
                                          ),
                                          SizedBox(height: 12.0),
                                          // Subtitle
                                          Text(
                                            'Select a book from the sidebar to get started',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontSize: 14.0,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                ),
                                          ),
                                          SizedBox(height: 24.0),
                                          // Keyboard shortcut hint
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 10.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.search,
                                                  size: 16.0,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'Press ',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontSize: 13.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                          ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                    vertical: 2.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme
                                                            .of(context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .alternate,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _modifierKey,
                                                    style: FlutterFlowTheme
                                                            .of(context)
                                                        .bodySmall
                                                        .override(
                                                          fontSize: 11.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  '+',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontSize: 13.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                          ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                    vertical: 2.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme
                                                            .of(context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .alternate,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'K',
                                                    style: FlutterFlowTheme
                                                            .of(context)
                                                        .bodySmall
                                                        .override(
                                                          fontSize: 11.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'to search',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontSize: 13.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
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
                        ],
                      ),
                    ),
                  ],
                ),
              if (_model.showSearchModal ?? false)
                SearchModalEnhanced(
                  onResultSelected: (result) {
                    print('Search result selected: ${result.name}');
                    if (result.type == 'image') {
                      _model.selectedImageId = result.id;
                      _model.selectedImageUrl = result.thumbnailUrl ?? '';
                      _model.showImageDetailModal = true;
                    } else if (result.type == 'audio') {
                      _model.selectedAudioId = result.id;
                      _model.selectedAudioUrl = result.thumbnailUrl ?? '';
                      _model.showAudioDetailModal = true;
                    }
                    _model.showSearchModal = false;
                    safeSetState(() {});
                  },
                  onClose: () {
                    _model.showSearchModal = false;
                    safeSetState(() {});
                  },
                ),
              // Image Detail Modal
              if (_model.showImageDetailModal)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: ImageDetailModal(
                    imageId: _model.selectedImageId ?? 0,
                    imageName: 'Image',
                    imageUrl: _model.selectedImageUrl ?? '',
                    sequence: 1,
                    onDelete: () {
                      _model.showImageDetailModal = false;
                      safeSetState(() {});
                    },
                  ),
                ),
              // Audio Detail Modal
              if (_model.showAudioDetailModal)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: AudioDetailModal(
                    audioId: _model.selectedAudioId ?? 0,
                    audioName: 'Audio',
                    audioUrl: _model.selectedAudioUrl ?? '',
                    duration: 0,
                    onDelete: () {
                      _model.showAudioDetailModal = false;
                      safeSetState(() {});
                    },
                  ),
                ),
              // Export Modal
              if (_model.showExportModal)
                ExportModalWrapper(
                  bookId: _selectedBookId!,
                  onExportComplete: () {
                    _model.showExportModal = false;
                    safeSetState(() {});
                  },
                  onClose: () {
                    _model.showExportModal = false;
                    safeSetState(() {});
                  },
                ),
              // Confirm Dialog (for example, delete confirmation)
              if (_model.showConfirmDialog)
                ConfirmDialog(
                  title: 'Confirm Action',
                  message: 'Are you sure?',
                  confirmText: 'Confirm',
                  cancelText: 'Cancel',
                  onConfirm: () {
                    // TODO: Handle confirmation
                    _model.showConfirmDialog = false;
                    safeSetState(() {});
                  },
                  onCancel: () {
                    _model.showConfirmDialog = false;
                    safeSetState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// Wrapper widget to fetch book and chapters data for ExportModal
class ExportModalWrapper extends StatefulWidget {
  const ExportModalWrapper({
    super.key,
    required this.bookId,
    required this.onExportComplete,
    required this.onClose,
  });

  final int bookId;
  final VoidCallback onExportComplete;
  final VoidCallback onClose;

  @override
  State<ExportModalWrapper> createState() => _ExportModalWrapperState();
}

class _ExportModalWrapperState extends State<ExportModalWrapper> {
  Book? _book;
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookAndChapters();
  }

  Future<void> _loadBookAndChapters() async {
    try {
      final authToken = currentAuthenticationToken ?? '';

      // Load book details
      final bookResult = await OCRWorkbenchAPIGroup.getBookCall.call(
        bookId: widget.bookId,
        hTTPBearer: authToken,
      );

      if (bookResult.succeeded) {
        _book = Book.fromJson(bookResult.jsonBody as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load book');
      }

      // Load chapters
      final chaptersResult = await OCRWorkbenchAPIGroup.listChaptersCall.call(
        bookId: widget.bookId,
        page: 1,
        pageSize: 100,
        hTTPBearer: authToken,
      );

      if (chaptersResult.succeeded) {
        final paginatedResponse = PaginatedChaptersResponse.fromJson(
          chaptersResult.jsonBody as Map<String, dynamic>,
        );
        _chapters = paginatedResponse.items;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load book data: $e';
          _isLoading = false;
        });
        ToastManager.showError('Failed to load book data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading book data...'),
            ],
          ),
        ),
      );
    }

    if (_error != null || _book == null) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(_error ?? 'Failed to load book data'),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onExportComplete();
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    // Use the actual ExportModal from export_modal.dart
    // Convert Chapter list to ChapterItem list
    final chapterItems = _chapters
        .map((ch) => ChapterItem(id: ch.id, name: ch.name))
        .toList();

    return ExportModal(
      bookId: widget.bookId,
      bookName: _book!.name,
      chapters: chapterItems,
      onExportComplete: widget.onExportComplete,
      onClose: widget.onClose,
    );
  }
}
