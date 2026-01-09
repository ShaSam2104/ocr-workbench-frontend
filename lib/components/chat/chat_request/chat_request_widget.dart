import '/components/chat/chat_bubble/chat_bubble_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'chat_request_model.dart';
export 'chat_request_model.dart';

class ChatRequestWidget extends StatefulWidget {
  const ChatRequestWidget({
    super.key,
    this.text,
  });

  final String? text;

  @override
  State<ChatRequestWidget> createState() => _ChatRequestWidgetState();
}

class _ChatRequestWidgetState extends State<ChatRequestWidget> {
  late ChatRequestModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatRequestModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        wrapWithModel(
          model: _model.chatBubbleModel,
          updateCallback: () => safeSetState(() {}),
          child: ChatBubbleWidget(
            text: widget.text,
          ),
        ),
        Align(
          alignment: AlignmentDirectional(1.0, 0.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 220.0,
            ),
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(1.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  'https://s3-alpha-sig.figma.com/img/8edc/82de/970652999e82613f3c3525d1db5fb12e?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=ZRj5dT~6d7fDMVwj3YUz-pSV4HXvCFKdDKg2YFXBx-Lvkc7tSbdyrr-AD544XC9ZhBsUKWRLXdkjPgQbXhJ-X7m~RvzTBoGt0d~n2Yf1WWfKe2p1dnGEMFpGfQFpc509M14xzsAWE2gOqevBrwirDkMA4S3Xkul0zobeqJQioE8hpZfJu-N6AEzPhs~zKruKlKQc9Vxo4mqqxEQ3aoqX-UMo~AM7yNpICK0N1MURBZOA22LXwNBWsLLwzzb~4S0CgosDHwy~XX~jM-f0JaKQ4S4MumfUjIqo8-9PvKBb3A6QQHiJ8k8n8fl9MabqUvJF71xP8ihoRjjqjkHevtgzOA__',
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ].divide(SizedBox(height: 8.0)),
    );
  }
}
