import '/components/chat/chat_bubble/chat_bubble_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chat_request_widget.dart' show ChatRequestWidget;
import 'package:flutter/material.dart';

class ChatRequestModel extends FlutterFlowModel<ChatRequestWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for ChatBubble component.
  late ChatBubbleModel chatBubbleModel;

  @override
  void initState(BuildContext context) {
    chatBubbleModel = createModel(context, () => ChatBubbleModel());
  }

  @override
  void dispose() {
    chatBubbleModel.dispose();
  }
}
