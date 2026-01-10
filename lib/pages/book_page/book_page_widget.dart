import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/schema/book.dart';
import '/backend/schema/chapter.dart';
import '/components/modals/new_chapter_dialog.dart';

class BookPageWidget extends StatefulWidget {
  final int bookId;
  final VoidCallback? onChapterCreated;

  const BookPageWidget({
    Key? key,
    required this.bookId,
    this.onChapterCreated,
  }) : super(key: key);

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  Book? _book;
  List<Chapter> _chapters = [];
  bool _isLoadingBook = true;
  bool _isLoadingChapters = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBook();
    _loadChapters();
  }

  @override
  void didUpdateWidget(BookPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      _loadBook();
      _loadChapters();
    }
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoadingBook = true;
      _error = null;
    });

    try {
      final token = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.getBookCall.call(
        bookId: widget.bookId,
        hTTPBearer: token,
      );

      if (!mounted) return;

      if (result.succeeded && result.jsonBody != null) {
        setState(() {
          _book = Book.fromJson(result.jsonBody as Map<String, dynamic>);
          _isLoadingBook = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load book';
          _isLoadingBook = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingBook = false;
      });
    }
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoadingChapters = true;
    });

    try {
      final token = currentAuthenticationToken ?? '';
      final result = await OCRWorkbenchAPIGroup.listChaptersCall.call(
        bookId: widget.bookId,
        page: 1,
        pageSize: 100,
        hTTPBearer: token,
      );

      if (!mounted) return;

      if (result.succeeded && result.jsonBody != null) {
        final response = PaginatedChaptersResponse.fromJson(
          result.jsonBody as Map<String, dynamic>,
        );
        setState(() {
          _chapters = response.items;
          _isLoadingChapters = false;
        });
      } else {
        setState(() {
          _isLoadingChapters = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingChapters = false;
      });
    }
  }

  void _showNewChapterDialog() {
    showDialog(
      context: context,
      builder: (context) => NewChapterDialog(
        bookId: widget.bookId,
        onSuccess: () {
          _loadChapters();
          widget.onChapterCreated?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBook) {
      return Center(
        child: CircularProgressIndicator(
          color: FlutterFlowTheme.of(context).primary,
        ),
      );
    }

    if (_error != null || _book == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16.0),
            Text(
              _error ?? 'Book not found',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      color: FlutterFlowTheme.of(context).primaryBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              _book!.name,
              style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontWeight: FontWeight.w600,
                    fontSize: 32.0,
                  ),
            ),
            const SizedBox(height: 8.0),

            // Book Description
            if (_book!.description != null && _book!.description!.isNotEmpty)
              Text(
                _book!.description!,
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16.0,
                    ),
              ),
            const SizedBox(height: 32.0),

            // Chapters Header with New Chapter Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chapters',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.0,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _showNewChapterDialog,
                  icon: const Icon(Icons.add, size: 18.0),
                  label: const Text('New Chapter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Chapters List
            if (_isLoadingChapters)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            else if (_chapters.isEmpty)
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 48.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No chapters yet',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Click "New Chapter" to create your first chapter',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 13.0,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _chapters.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return InkWell(
                    onTap: () {
                      // TODO: Navigate to chapter detail
                      print('Chapter tapped: ${chapter.id}');
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32.0,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  chapter.name,
                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0,
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20.0,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ],
                          ),
                          if (chapter.description != null && chapter.description!.isNotEmpty) ...[
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 44.0),
                              child: Text(
                                chapter.description!,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 14.0,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
