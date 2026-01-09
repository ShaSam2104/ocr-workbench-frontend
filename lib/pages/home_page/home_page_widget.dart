import '/components/chat/empty_chat_state/empty_chat_state_widget.dart';
import '/components/modals/search_modal/search_modal_widget.dart';
import '/components/modals/keyboard_shortcuts_modal.dart';
import '/components/utils/attachments/attachments_widget.dart';
import '/components/utils/global_keyboard_shortcuts.dart';
import '/components/utils/base_input_field/base_input_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/sidebar/book_sidebar/book_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return GlobalKeyboardShortcuts(
      onCtrlK: () {
        // Ctrl+K: Focus search modal
        _model.showSearchModal = true;
        safeSetState(() {});
      },
      onCtrlF: () {
        // Ctrl+F: Focus search modal
        _model.showSearchModal = true;
        safeSetState(() {});
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
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
                  children: [
                    wrapWithModel(
                      model: _model.bookSidebarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: BookSidebarWidget(
                        onNewBook: () async {
                          _model.showEmptyChat = true;
                          safeSetState(() {});
                        },
                        onItemSelect: () async {
                          _model.showEmptyChat = false;
                          _model.showResponseLoading = false;
                          safeSetState(() {});
                        },
                        onSearch: () async {
                          _model.showSearchModal = true;
                          safeSetState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 24.0, 24.0, 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Tooltip(
                                  message: 'Keyboard shortcuts (Ctrl + ?)',
                                  child: IconButton(
                                    icon: const Icon(Icons.help_outline),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const KeyboardShortcutsModal(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'Share',
                                  icon: Icon(
                                    Icons.share,
                                    size: 16.0,
                                  ),
                                options: FFButtonOptions(
                                  height: 36.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).accent4,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                              Container(
                                width: 36.0,
                                height: 36.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/Ellipse_1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(),
                            child: wrapWithModel(
                              model: _model.emptyChatStateModel,
                              updateCallback: () => safeSetState(() {}),
                              child: EmptyChatStateWidget(
                                onItemPress: () async {
                                  _model.showEmptyChat = false;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (_model.showAttachments)
                                    wrapWithModel(
                                      model: _model.attachmentsModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AttachmentsWidget(
                                        onFileDelete: () async {
                                          _model.showAttachments = false;
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  wrapWithModel(
                                    model: _model.baseInputFieldModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: BaseInputFieldWidget(
                                      onNewMessage: () async {
                                        _model.showEmptyChat = false;
                                        _model.showResponseLoading = true;
                                        safeSetState(() {});
                                        safeSetState(() {
                                          _model.baseInputFieldModel
                                              .textController
                                              ?.clear();
                                        });
                                        await Future.delayed(
                                          Duration(
                                            milliseconds: 5000,
                                          ),
                                        );
                                        _model.showResponseLoading = false;
                                        safeSetState(() {});
                                      },
                                      onNewFileAttached: () async {
                                        _model.showAttachments = true;
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                              Text(
                                'ChatCalda can make mistakes. Check important info.',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: Color(0x80FFFFFF),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ],
              ),
              if (_model.showSearchModal ?? true)
                wrapWithModel(
                  model: _model.searchModalModel,
                  updateCallback: () => safeSetState(() {}),
                  child: SearchModalWidget(
                    onClose: () async {
                      _model.showSearchModal = false;
                      safeSetState(() {});
                    },
                    onItemSelect: () async {
                      _model.showEmptyChat = false;
                      _model.showResponseLoading = false;
                      safeSetState(() {});
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
