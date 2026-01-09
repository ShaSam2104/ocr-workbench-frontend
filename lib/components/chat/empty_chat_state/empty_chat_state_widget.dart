import '/components/buttons/book/book_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'empty_chat_state_model.dart';
export 'empty_chat_state_model.dart';

class EmptyChatStateWidget extends StatefulWidget {
  const EmptyChatStateWidget({
    super.key,
    this.onItemPress,
  });

  final Future Function()? onItemPress;

  @override
  State<EmptyChatStateWidget> createState() => _EmptyChatStateWidgetState();
}

class _EmptyChatStateWidgetState extends State<EmptyChatStateWidget> {
  late EmptyChatStateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyChatStateModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 440.0,
          decoration: BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Hey, how can I help?',
                style: FlutterFlowTheme.of(context).headlineLarge.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineLarge
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineLarge
                            .fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).headlineLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                    ),
              ),
              Text(
                'Not sure where to start? Choose a preset question to get started, and we’ll guide you through the process!',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.interTight(
                        fontWeight:
                            FlutterFlowTheme.of(context).labelLarge.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).labelLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    ),
              ),
            ].divide(SizedBox(height: 16.0)),
          ),
        ),
        Container(
          width: 620.0,
          constraints: BoxConstraints(
            maxHeight: 160.0,
          ),
          decoration: BoxDecoration(),
          child: MasonryGridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            itemCount: 4,
            itemBuilder: (context, index) {
              return [
                () => wrapWithModel(
                      model: _model.bookModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: BookWidget(
                        label: 'Write Copy',
                        onClick: () async {
                          await widget.onItemPress?.call();
                        },
                      ),
                    ),
                () => wrapWithModel(
                      model: _model.bookModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: BookWidget(
                        label: 'Generate image',
                        onClick: () async {
                          await widget.onItemPress?.call();
                        },
                      ),
                    ),
                () => wrapWithModel(
                      model: _model.bookModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: BookWidget(
                        label: 'Brainstorm ideas',
                        onClick: () async {
                          await widget.onItemPress?.call();
                        },
                      ),
                    ),
                () => wrapWithModel(
                      model: _model.bookModel4,
                      updateCallback: () => safeSetState(() {}),
                      child: BookWidget(
                        label: 'Write code',
                        onClick: () async {
                          await widget.onItemPress?.call();
                        },
                      ),
                    ),
              ][index]();
            },
          ),
        ),
      ].divide(SizedBox(height: 24.0)),
    );
  }
}
