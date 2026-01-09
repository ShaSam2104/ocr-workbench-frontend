import '/flutter_flow/flutter_flow_util.dart';
import 'chat_response_feedback_widget.dart' show ChatResponseFeedbackWidget;
import 'package:flutter/material.dart';

class ChatResponseFeedbackModel
    extends FlutterFlowModel<ChatResponseFeedbackWidget> {
  ///  Local state fields for this component.

  bool isLiked = false;

  bool isDisliked = false;

  bool isCopied = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Action blocks.
  /// Runs when user presses like button
  Future likeResponse(BuildContext context) async {
    isLiked = !isLiked;
    if ((isLiked == true) && (isDisliked == true)) {
      isDisliked = false;
    }
  }

  Future dislikeResponse(BuildContext context) async {
    isDisliked = !isDisliked;
    if ((isLiked == true) && (isDisliked == true)) {
      isLiked = false;
    }
  }
}
