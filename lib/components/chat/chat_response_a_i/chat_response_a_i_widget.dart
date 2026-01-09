import '/components/chat/chat_response_feedback/chat_response_feedback_widget.dart';
import '/components/skeletons/image_skeleton/image_skeleton_widget.dart';
import '/components/skeletons/text_skeleton/text_skeleton_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_response_a_i_model.dart';
export 'chat_response_a_i_model.dart';

class ChatResponseAIWidget extends StatefulWidget {
  const ChatResponseAIWidget({
    super.key,
    String? content,
    bool? isResponding,
  })  : this.content = content ?? 'This is AI response.',
        this.isResponding = isResponding ?? false;

  final String content;
  final bool isResponding;

  @override
  State<ChatResponseAIWidget> createState() => _ChatResponseAIWidgetState();
}

class _ChatResponseAIWidgetState extends State<ChatResponseAIWidget> {
  late ChatResponseAIModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatResponseAIModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(-1.0, 0.0),
      child: Container(
        decoration: BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Image.asset(
                'assets/images/AI_Icon.png',
                width: 32.0,
                height: 32.0,
                fit: BoxFit.cover,
              ),
            ),
            Builder(
              builder: (context) {
                if (widget.isResponding) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: _model.textSkeletonModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TextSkeletonWidget(
                          text: 'Thinking...',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.imageSkeletonModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ImageSkeletonWidget(),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 520.0,
                        ),
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: SelectionArea(
                              child: Text(
                            widget.content,
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                      lineHeight: 1.5,
                                    ),
                          )),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 300.0,
                        ),
                        decoration: BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://s3-alpha-sig.figma.com/img/8edc/82de/970652999e82613f3c3525d1db5fb12e?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=ZRj5dT~6d7fDMVwj3YUz-pSV4HXvCFKdDKg2YFXBx-Lvkc7tSbdyrr-AD544XC9ZhBsUKWRLXdkjPgQbXhJ-X7m~RvzTBoGt0d~n2Yf1WWfKe2p1dnGEMFpGfQFpc509M14xzsAWE2gOqevBrwirDkMA4S3Xkul0zobeqJQioE8hpZfJu-N6AEzPhs~zKruKlKQc9Vxo4mqqxEQ3aoqX-UMo~AM7yNpICK0N1MURBZOA22LXwNBWsLLwzzb~4S0CgosDHwy~XX~jM-f0JaKQ4S4MumfUjIqo8-9PvKBb3A6QQHiJ8k8n8fl9MabqUvJF71xP8ihoRjjqjkHevtgzOA__',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      wrapWithModel(
                        model: _model.chatResponseFeedbackModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ChatResponseFeedbackWidget(),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  );
                }
              },
            ),
          ].divide(SizedBox(width: 16.0)),
        ),
      ),
    );
  }
}
