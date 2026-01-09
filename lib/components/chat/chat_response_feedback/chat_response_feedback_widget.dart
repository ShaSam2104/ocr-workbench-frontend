import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'chat_response_feedback_model.dart';
export 'chat_response_feedback_model.dart';

class ChatResponseFeedbackWidget extends StatefulWidget {
  const ChatResponseFeedbackWidget({super.key});

  @override
  State<ChatResponseFeedbackWidget> createState() =>
      _ChatResponseFeedbackWidgetState();
}

class _ChatResponseFeedbackWidgetState
    extends State<ChatResponseFeedbackWidget> {
  late ChatResponseFeedbackModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatResponseFeedbackModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Builder(
          builder: (context) {
            if (_model.isCopied) {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                fillColor: FlutterFlowTheme.of(context).accent4,
                icon: Icon(
                  Icons.file_copy,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () {
                  print('IconButton pressed ...');
                },
              );
            } else {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.content_copy,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () async {
                  _model.isCopied = true;
                  safeSetState(() {});
                  await Future.delayed(
                    Duration(
                      milliseconds: 3000,
                    ),
                  );
                  _model.isCopied = false;
                  safeSetState(() {});
                },
              );
            }
          },
        ),
        Builder(
          builder: (context) {
            if (_model.isLiked) {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.thumb_up_alt,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () async {
                  await _model.likeResponse(context);
                  safeSetState(() {});
                },
              );
            } else {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.thumb_up_alt_outlined,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () async {
                  await _model.likeResponse(context);
                  safeSetState(() {});
                },
              );
            }
          },
        ),
        Builder(
          builder: (context) {
            if (_model.isDisliked) {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.thumb_down_alt,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () async {
                  await _model.dislikeResponse(context);
                  safeSetState(() {});
                },
              );
            } else {
              return FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 32.0,
                hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.thumb_down_alt_outlined,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                onPressed: () async {
                  await _model.dislikeResponse(context);
                  safeSetState(() {});
                },
              );
            }
          },
        ),
        FlutterFlowIconButton(
          borderRadius: 12.0,
          buttonSize: 32.0,
          hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
          icon: Icon(
            Icons.volume_up,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 16.0,
          ),
          onPressed: () {
            print('IconButton pressed ...');
          },
        ),
        FlutterFlowIconButton(
          borderRadius: 12.0,
          buttonSize: 32.0,
          hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
          icon: Icon(
            Icons.replay,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 16.0,
          ),
          onPressed: () {
            print('IconButton pressed ...');
          },
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }
}
